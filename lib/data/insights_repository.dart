import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../analytics/analytics_engine.dart';
import '../analytics/models.dart';
import '../ml/model_evaluation.dart';
import '../ml/risk_model.dart';
import '../services/usage_stats_channel.dart';
import 'database.dart';

/// Ties the event log, the analytics engine and the risk model together.
///
/// Screens talk to this and nothing else — they never see drift rows, and the
/// analytics/ML layers never see a database.
class InsightsRepository extends ChangeNotifier {
  final AppDatabase db;
  final AnalyticsEngine engine;
  final ModelEvaluator evaluator;
  final UsageStatsChannel usage;

  RiskModel _model = RiskModel.untrained();
  RiskModel get model => _model;

  InsightsRepository({
    required this.db,
    this.engine = const AnalyticsEngine(),
    this.evaluator = const ModelEvaluator(),
    UsageStatsChannel? usage,
  }) : usage = usage ?? UsageStatsChannel();

  /// Load persisted weights; retrain from the log if we have events but no
  /// weights yet (e.g. first run after an update).
  Future<void> init() async {
    final weights = await db.loadWeights();
    if (weights.isNotEmpty) {
      _model = RiskModel(
        weights: weights,
        trainedOn: await db.weightsTrainedOn(),
      );
    } else if (await db.countEvents() >= RiskModel.minObservations) {
      await retrain();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Prediction
  // ---------------------------------------------------------------------------

  /// Assemble everything the model needs to score the moment the user just
  /// told us why they're opening the app.
  Future<PauseContext> contextFor({
    required String packageName,
    required String reason,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final startOfDay = DateTime(at.year, at.month, at.day);

    final opensBefore = await db.opensSince(packageName, startOfDay);
    final last = await db.lastEventFor(packageName);
    final gap = last == null
        ? null
        : at.difference(last.timestamp).inMinutes;

    final recent = await db.recentEvents(limit: 10);
    final relapseRate = recent.isEmpty
        ? 0.0
        : recent.where((e) => e.outcome != 'home').length / recent.length;

    return PauseContext(
      timestamp: at,
      reason: reason,
      opensBefore: opensBefore,
      minutesSinceLastOpen: gap,
      recentRelapseRate: relapseRate,
    );
  }

  /// P(they open it anyway), or null while the model is still abstaining.
  double? riskFor(PauseContext context) =>
      _model.isReady ? _model.predict(context) : null;

  List<FeatureContribution> explain(PauseContext context) =>
      _model.isReady ? _model.explain(context) : const [];

  /// Higher risk earns a longer pause: 15s baseline, 10s when they're likely
  /// to back out anyway, up to 25s when the model expects a slip.
  int adaptivePauseSeconds(double? risk) {
    if (risk == null) return 15;
    return (10 + risk * 15).round().clamp(10, 25);
  }

  // ---------------------------------------------------------------------------
  // Recording
  // ---------------------------------------------------------------------------

  /// Persist the pause that just happened and take one online learning step.
  Future<void> recordPause({
    required PauseContext context,
    required String packageName,
    required String appName,
    required bool wentHome,
    required int pauseSeconds,
    double? riskScore,
  }) async {
    await db.addEvent(InterventionEventsCompanion.insert(
      timestamp: context.timestamp,
      packageName: packageName,
      appName: appName,
      reason: context.reason,
      outcome: wentHome ? 'home' : 'openedAnyway',
      pauseSeconds: pauseSeconds,
      hourOfDay: context.timestamp.hour,
      weekday: context.timestamp.weekday,
      opensBefore: context.opensBefore,
      riskScore: Value(riskScore),
      minutesSinceLastOpen: Value(context.minutesSinceLastOpen),
    ));

    _model = _model.updatedWith(context, !wentHome);
    await db.saveWeights(_model.weights, _model.trainedOn);

    // Once enough history exists, a periodic full retrain keeps the online
    // updates from drifting.
    if (_model.trainedOn % 25 == 0) {
      await retrain();
    }
    notifyListeners();
  }

  /// Full batch retrain over the stored log.
  Future<void> retrain() async {
    final records = (await db.recentEvents(limit: 1000)).map(_toRecord).toList();
    if (records.isEmpty) return;
    _model = RiskModel.train(records);
    await db.saveWeights(_model.weights, _model.trainedOn);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reporting
  // ---------------------------------------------------------------------------

  Future<InsightsSummary> summary({int days = 30, DateTime? now}) async {
    final at = now ?? DateTime.now();
    final to = DateTime(at.year, at.month, at.day).add(const Duration(days: 1));
    final from = to.subtract(Duration(days: days));

    final events = await db.eventsBetween(from, to);
    final usage = await db.usageBetween(from, to);
    final checkins = await db.checkinsBetween(from, to);

    // Sum usage across packages for each day.
    final byDay = <DateTime, int>{};
    for (final u in usage) {
      byDay[u.day] = (byDay[u.day] ?? 0) + u.minutes;
    }

    return engine.summarize(
      records: events.map(_toRecord).toList(),
      usage: [
        for (final e in byDay.entries) DailyUsage(day: e.key, minutes: e.value),
      ],
      checkins: [
        for (final c in checkins)
          FocusCheckin(day: c.day, score: c.focusScore),
      ],
      from: from,
      to: to,
    );
  }

  Future<EvaluationResult?> evaluate() async {
    final records = (await db.recentEvents(limit: 1000)).map(_toRecord).toList();
    return evaluator.evaluate(records);
  }

  // ---------------------------------------------------------------------------
  // Check-ins and usage
  // ---------------------------------------------------------------------------

  Future<void> saveCheckin(int focusScore, {DateTime? day}) async {
    await db.saveCheckin(day ?? DateTime.now(), focusScore);
    notifyListeners();
  }

  Future<int?> todayCheckin() async {
    final row = await db.checkinFor(DateTime.now());
    return row?.focusScore;
  }

  Future<int> minutesToday() => db.minutesOn(DateTime.now());

  Future<int> opensToday(String packageName) {
    final now = DateTime.now();
    return db.opensSince(packageName, DateTime(now.year, now.month, now.day));
  }

  /// Store platform-reported foreground minutes for a day.
  Future<void> ingestUsage(
    DateTime day,
    Map<String, int> minutesByPackage,
  ) async {
    for (final e in minutesByPackage.entries) {
      await db.saveUsage(day, e.key, e.value);
    }
    notifyListeners();
  }

  Future<bool> hasUsageAccess() => usage.hasAccess();

  Future<void> requestUsageAccess() => usage.requestAccess();

  /// Pull the last [days] days of real foreground time for the guarded apps.
  ///
  /// Only guarded packages are stored — the app has no reason to keep a record
  /// of everything else the phone runs. Notifies once at the end, so callers
  /// that listen to this repository can't trigger a refresh loop.
  Future<void> syncUsage({
    required Set<String> packages,
    int days = 7,
  }) async {
    if (packages.isEmpty || !await usage.hasAccess()) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var wrote = false;

    for (var i = 0; i < days; i++) {
      final day = today.subtract(Duration(days: i));
      final minutes =
          await usage.minutesBetween(day, day.add(const Duration(days: 1)));

      for (final e in minutes.entries) {
        if (!packages.contains(e.key)) continue;
        await db.saveUsage(day, e.key, e.value);
        wrote = true;
      }
    }
    if (wrote) notifyListeners();
  }

  static PauseRecord _toRecord(InterventionEvent e) => PauseRecord(
        timestamp: e.timestamp,
        packageName: e.packageName,
        appName: e.appName,
        reason: e.reason,
        wentHome: e.outcome == 'home',
        hourOfDay: e.hourOfDay,
        weekday: e.weekday,
        opensBefore: e.opensBefore,
        minutesSinceLastOpen: e.minutesSinceLastOpen,
        riskScore: e.riskScore,
      );
}
