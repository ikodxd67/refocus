import 'package:flutter_test/flutter_test.dart';
import 'package:refocus/analytics/analytics_engine.dart';
import 'package:refocus/analytics/models.dart';

PauseRecord _rec(
  DateTime at, {
  bool wentHome = true,
  String reason = 'bored',
  String package = 'com.zhiliaoapp.musically',
}) {
  return PauseRecord(
    timestamp: at,
    packageName: package,
    appName: 'TikTok',
    reason: reason,
    wentHome: wentHome,
    hourOfDay: at.hour,
    weekday: at.weekday,
    opensBefore: 0,
  );
}

void main() {
  const engine = AnalyticsEngine();
  final from = DateTime(2026, 3, 1);
  final to = DateTime(2026, 3, 5); // exclusive -> 4 days

  group('daily', () {
    test('emits a row per day including days with no activity', () {
      final stats = engine.daily(
        records: [_rec(DateTime(2026, 3, 1, 20))],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(stats.length, 4);
      expect(stats.map((s) => s.day.day), [1, 2, 3, 4]);
      expect(stats[0].pauses, 1);
      expect(stats[1].pauses, 0, reason: 'gap day still present');
    });

    test('counts pauses and successful back-outs per day', () {
      final stats = engine.daily(
        records: [
          _rec(DateTime(2026, 3, 2, 10)),
          _rec(DateTime(2026, 3, 2, 11), wentHome: false),
          _rec(DateTime(2026, 3, 2, 12)),
        ],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      final day2 = stats.firstWhere((s) => s.day.day == 2);
      expect(day2.pauses, 3);
      expect(day2.wentHome, 2);
      expect(day2.successRate, closeTo(2 / 3, 1e-12));
    });

    test('joins usage minutes and focus check-ins onto the right day', () {
      final stats = engine.daily(
        records: const [],
        usage: [DailyUsage(day: DateTime(2026, 3, 3), minutes: 47)],
        checkins: [FocusCheckin(day: DateTime(2026, 3, 3), score: 2)],
        from: from,
        to: to,
      );
      final day3 = stats.firstWhere((s) => s.day.day == 3);
      expect(day3.minutes, 47);
      expect(day3.focusScore, 2);
      expect(stats.first.focusScore, isNull);
    });

    test('successRate is 0, not NaN, on a day with no pauses', () {
      final stats = engine.daily(
        records: const [],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(stats.first.successRate, 0);
    });
  });

  group('hourly', () {
    test('always returns all 24 buckets', () {
      final h = engine.hourly([_rec(DateTime(2026, 3, 1, 23))]);
      expect(h.length, 24);
      expect(h[23].pauses, 1);
      expect(h[0].pauses, 0);
    });

    test('relapse rate is the complement of success rate', () {
      final h = engine.hourly([
        _rec(DateTime(2026, 3, 1, 22)),
        _rec(DateTime(2026, 3, 1, 22), wentHome: false),
        _rec(DateTime(2026, 3, 2, 22), wentHome: false),
      ]);
      expect(h[22].pauses, 3);
      expect(h[22].successRate, closeTo(1 / 3, 1e-12));
      expect(h[22].relapseRate, closeTo(2 / 3, 1e-12));
    });
  });

  group('byReason', () {
    test('groups and sorts by how often each intention appears', () {
      final stats = engine.byReason([
        _rec(from, reason: 'habit', wentHome: false),
        _rec(from, reason: 'habit', wentHome: false),
        _rec(from, reason: 'bored'),
        _rec(from, reason: 'habit'),
      ]);
      expect(stats.first.reason, 'habit');
      expect(stats.first.pauses, 3);
      expect(stats.first.successRate, closeTo(1 / 3, 1e-12));
      expect(stats.last.reason, 'bored');
      expect(stats.last.successRate, 1);
    });
  });

  group('usageVsFocus', () {
    test('finds the expected negative relationship: more scroll, less focus',
        () {
      final daily = engine.daily(
        records: const [],
        usage: [
          DailyUsage(day: DateTime(2026, 3, 1), minutes: 20),
          DailyUsage(day: DateTime(2026, 3, 2), minutes: 60),
          DailyUsage(day: DateTime(2026, 3, 3), minutes: 100),
          DailyUsage(day: DateTime(2026, 3, 4), minutes: 140),
        ],
        checkins: [
          FocusCheckin(day: DateTime(2026, 3, 1), score: 5),
          FocusCheckin(day: DateTime(2026, 3, 2), score: 4),
          FocusCheckin(day: DateTime(2026, 3, 3), score: 2),
          FocusCheckin(day: DateTime(2026, 3, 4), score: 1),
        ],
        from: from,
        to: to,
      );
      final r = engine.usageVsFocus(daily)!;
      expect(r.r, lessThan(-0.9));
      expect(r.n, 4);
    });

    test('is null until there are at least three days with both numbers', () {
      final daily = engine.daily(
        records: const [],
        usage: [DailyUsage(day: DateTime(2026, 3, 1), minutes: 20)],
        checkins: [FocusCheckin(day: DateTime(2026, 3, 1), score: 5)],
        from: from,
        to: to,
      );
      expect(engine.usageVsFocus(daily), isNull);
    });
  });

  group('riskiestHours', () {
    test('ignores hours without enough samples', () {
      final hourly = engine.hourly([
        // 1 pause at 09:00, failed -> 100% relapse but only one sample
        _rec(DateTime(2026, 3, 1, 9), wentHome: false),
        // 3 pauses at 23:00, 2 failed -> 67% relapse, enough samples
        _rec(DateTime(2026, 3, 1, 23), wentHome: false),
        _rec(DateTime(2026, 3, 2, 23), wentHome: false),
        _rec(DateTime(2026, 3, 3, 23)),
      ]);
      final risky = engine.riskiestHours(hourly, minSample: 3);
      expect(risky.map((h) => h.hour), [23]);
    });

    test('orders worst relapse rate first', () {
      final hourly = engine.hourly([
        for (var i = 0; i < 3; i++)
          _rec(DateTime(2026, 3, 1 + i, 21), wentHome: false),
        for (var i = 0; i < 3; i++) _rec(DateTime(2026, 3, 1 + i, 14)),
        _rec(DateTime(2026, 3, 4, 14), wentHome: false),
      ]);
      final risky = engine.riskiestHours(hourly, minSample: 3);
      expect(risky.first.hour, 21);
      expect(risky.first.relapseRate, 1);
    });
  });

  group('currentStreak', () {
    test('counts consecutive days with at least one back-out', () {
      final daily = engine.daily(
        records: [
          _rec(DateTime(2026, 3, 2, 10)),
          _rec(DateTime(2026, 3, 3, 10)),
          _rec(DateTime(2026, 3, 4, 10)),
        ],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(engine.currentStreak(daily), 3);
    });

    test('a day where every pause was pushed through breaks the streak', () {
      final daily = engine.daily(
        records: [
          _rec(DateTime(2026, 3, 2, 10)),
          _rec(DateTime(2026, 3, 3, 10), wentHome: false),
          _rec(DateTime(2026, 3, 4, 10)),
        ],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(engine.currentStreak(daily), 1);
    });

    test('days with no pauses at all are neutral, not breaks', () {
      final daily = engine.daily(
        records: [
          _rec(DateTime(2026, 3, 2, 10)),
          // nothing on the 3rd — no temptation, no failure
          _rec(DateTime(2026, 3, 4, 10)),
        ],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(engine.currentStreak(daily), 2);
    });
  });

  group('summarize', () {
    test('rolls everything up consistently', () {
      final s = engine.summarize(
        records: [
          _rec(DateTime(2026, 3, 1, 22), wentHome: false),
          _rec(DateTime(2026, 3, 2, 22)),
          _rec(DateTime(2026, 3, 3, 9)),
        ],
        usage: const [],
        checkins: const [],
        from: from,
        to: to,
      );
      expect(s.totalPauses, 3);
      expect(s.totalWentHome, 2);
      expect(s.overallSuccessRate, closeTo(2 / 3, 1e-12));
      expect(s.hourly.length, 24);
      expect(s.daily.length, 4);
      expect(s.hasEnoughData, isFalse);
    });
  });
}
