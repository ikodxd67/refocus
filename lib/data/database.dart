import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Every pause the app has shown, one row each.
///
/// This is the event log the whole analytics + ML layer is built on: it is
/// append-only, and every derived number in the app is computed from it rather
/// than stored as a running counter.
class InterventionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get timestamp => dateTime()();
  TextColumn get packageName => text().withLength(min: 1, max: 200)();
  TextColumn get appName => text().withLength(min: 1, max: 100)();

  /// Which intention the user tapped (see `PauseReason`).
  TextColumn get reason => text().withLength(min: 1, max: 40)();

  /// `home` (they backed out) or `openedAnyway`.
  TextColumn get outcome => text().withLength(min: 1, max: 40)();

  /// How long the pause locked them out, in seconds (adaptive).
  IntColumn get pauseSeconds => integer()();

  /// What the risk model predicted just before showing the pause, if it had
  /// enough data to predict at all.
  RealColumn get riskScore => real().nullable()();

  // ---- denormalised features, so analytics and training stay cheap ----
  IntColumn get hourOfDay => integer()();
  IntColumn get weekday => integer()(); // 1 = Monday .. 7 = Sunday
  IntColumn get opensBefore => integer()(); // opens of this app earlier today
  IntColumn get minutesSinceLastOpen => integer().nullable()();
}

/// One self-reported focus rating per day, on the same 1-5 scale the diploma's
/// survey used — this is what makes a personal correlation possible.
class DailyCheckins extends Table {
  DateTimeColumn get day => dateTime()(); // normalised to midnight
  IntColumn get focusScore => integer()(); // 1..5
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Real per-app foreground minutes, read from the platform (Android
/// UsageStatsManager). Not a guess — this is what the "cost mirror" shows.
class AppUsageDaily extends Table {
  DateTimeColumn get day => dateTime()();
  TextColumn get packageName => text().withLength(min: 1, max: 200)();
  IntColumn get minutes => integer()();

  @override
  Set<Column> get primaryKey => {day, packageName};
}

/// Persisted weights of the on-device logistic-regression risk model.
class ModelWeights extends Table {
  TextColumn get feature => text().withLength(min: 1, max: 60)();
  RealColumn get weight => real()();
  IntColumn get trainedOn => integer()(); // how many events produced these
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {feature};
}

@DriftDatabase(
  tables: [InterventionEvents, DailyCheckins, AppUsageDaily, ModelWeights],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit tests.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ---------------------------------------------------------------------------
  // Intervention events
  // ---------------------------------------------------------------------------

  Future<int> addEvent(InterventionEventsCompanion event) =>
      into(interventionEvents).insert(event);

  /// Events between [from] (inclusive) and [to] (exclusive), oldest first.
  Future<List<InterventionEvent>> eventsBetween(
    DateTime from,
    DateTime to,
  ) {
    return (select(interventionEvents)
          ..where((e) => e.timestamp.isBiggerOrEqualValue(from))
          ..where((e) => e.timestamp.isSmallerThanValue(to))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .get();
  }

  /// The most recent [limit] events, oldest first — the training window.
  Future<List<InterventionEvent>> recentEvents({int limit = 500}) async {
    final rows = await (select(interventionEvents)
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
          ..limit(limit))
        .get();
    return rows.reversed.toList();
  }

  Future<int> countEvents() async {
    final c = interventionEvents.id.count();
    final row = await (selectOnly(interventionEvents)..addColumns([c]))
        .getSingle();
    return row.read(c) ?? 0;
  }

  /// How many times [packageName] has been paused since [since].
  Future<int> opensSince(String packageName, DateTime since) async {
    final c = interventionEvents.id.count();
    final q = selectOnly(interventionEvents)
      ..addColumns([c])
      ..where(interventionEvents.packageName.equals(packageName) &
          interventionEvents.timestamp.isBiggerOrEqualValue(since));
    final row = await q.getSingle();
    return row.read(c) ?? 0;
  }

  Future<InterventionEvent?> lastEventFor(String packageName) {
    return (select(interventionEvents)
          ..where((e) => e.packageName.equals(packageName))
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Daily focus check-ins
  // ---------------------------------------------------------------------------

  Future<void> saveCheckin(DateTime day, int focusScore) {
    return into(dailyCheckins).insertOnConflictUpdate(
      DailyCheckinsCompanion.insert(
        day: DateTime(day.year, day.month, day.day),
        focusScore: focusScore,
        recordedAt: DateTime.now(),
      ),
    );
  }

  Future<DailyCheckin?> checkinFor(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return (select(dailyCheckins)..where((c) => c.day.equals(d)))
        .getSingleOrNull();
  }

  Future<List<DailyCheckin>> checkinsBetween(DateTime from, DateTime to) {
    return (select(dailyCheckins)
          ..where((c) => c.day.isBiggerOrEqualValue(from))
          ..where((c) => c.day.isSmallerThanValue(to))
          ..orderBy([(c) => OrderingTerm.asc(c.day)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Platform usage telemetry
  // ---------------------------------------------------------------------------

  Future<void> saveUsage(DateTime day, String packageName, int minutes) {
    return into(appUsageDaily).insertOnConflictUpdate(
      AppUsageDailyCompanion.insert(
        day: DateTime(day.year, day.month, day.day),
        packageName: packageName,
        minutes: minutes,
      ),
    );
  }

  Future<List<AppUsageDailyData>> usageBetween(DateTime from, DateTime to) {
    return (select(appUsageDaily)
          ..where((u) => u.day.isBiggerOrEqualValue(from))
          ..where((u) => u.day.isSmallerThanValue(to))
          ..orderBy([(u) => OrderingTerm.asc(u.day)]))
        .get();
  }

  /// Total guarded-app minutes for one day across every tracked package.
  Future<int> minutesOn(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    final sum = appUsageDaily.minutes.sum();
    final q = selectOnly(appUsageDaily)
      ..addColumns([sum])
      ..where(appUsageDaily.day.equals(d));
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Model weights
  // ---------------------------------------------------------------------------

  Future<Map<String, double>> loadWeights() async {
    final rows = await select(modelWeights).get();
    return {for (final r in rows) r.feature: r.weight};
  }

  Future<int> weightsTrainedOn() async {
    final rows = await (select(modelWeights)..limit(1)).get();
    return rows.isEmpty ? 0 : rows.first.trainedOn;
  }

  Future<void> saveWeights(Map<String, double> weights, int trainedOn) async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAllOnConflictUpdate(
        modelWeights,
        [
          for (final e in weights.entries)
            ModelWeightsCompanion.insert(
              feature: e.key,
              weight: e.value,
              trainedOn: trainedOn,
              updatedAt: now,
            ),
        ],
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'refocus.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
