import 'models.dart';
import 'stats.dart';

/// Turns the raw event log into the numbers the app reports.
///
/// Every method is a pure function of its arguments — no database, no clock
/// except what is passed in — which is what makes the whole layer testable
/// against fixtures with known expected values.
class AnalyticsEngine {
  const AnalyticsEngine();

  /// One row per calendar day in `[from, to)`, including days with no activity
  /// so charts and rolling averages don't silently skip gaps.
  List<DailyStat> daily({
    required List<PauseRecord> records,
    required List<DailyUsage> usage,
    required List<FocusCheckin> checkins,
    required DateTime from,
    required DateTime to,
  }) {
    final minutesByDay = {
      for (final u in usage) _dayKey(u.day): u.minutes,
    };
    final focusByDay = {
      for (final c in checkins) _dayKey(c.day): c.score,
    };

    final pausesByDay = <DateTime, int>{};
    final homeByDay = <DateTime, int>{};
    for (final r in records) {
      final k = _dayKey(r.timestamp);
      pausesByDay[k] = (pausesByDay[k] ?? 0) + 1;
      if (r.wentHome) homeByDay[k] = (homeByDay[k] ?? 0) + 1;
    }

    final out = <DailyStat>[];
    for (var d = _dayKey(from);
        d.isBefore(to);
        d = DateTime(d.year, d.month, d.day + 1)) {
      out.add(DailyStat(
        day: d,
        minutes: minutesByDay[d] ?? 0,
        pauses: pausesByDay[d] ?? 0,
        wentHome: homeByDay[d] ?? 0,
        focusScore: focusByDay[d],
      ));
    }
    return out;
  }

  /// Pauses bucketed into the 24 hours of the day.
  List<HourlyStat> hourly(List<PauseRecord> records) {
    final pauses = List<int>.filled(24, 0);
    final home = List<int>.filled(24, 0);
    for (final r in records) {
      final h = r.hourOfDay;
      if (h < 0 || h > 23) continue;
      pauses[h]++;
      if (r.wentHome) home[h]++;
    }
    return [
      for (var h = 0; h < 24; h++)
        HourlyStat(hour: h, pauses: pauses[h], wentHome: home[h]),
    ];
  }

  /// Which stated intention actually predicts backing out.
  List<ReasonStat> byReason(List<PauseRecord> records) {
    final pauses = <String, int>{};
    final home = <String, int>{};
    for (final r in records) {
      pauses[r.reason] = (pauses[r.reason] ?? 0) + 1;
      if (r.wentHome) home[r.reason] = (home[r.reason] ?? 0) + 1;
    }
    final out = [
      for (final e in pauses.entries)
        ReasonStat(
          reason: e.key,
          pauses: e.value,
          wentHome: home[e.key] ?? 0,
        ),
    ];
    out.sort((a, b) => b.pauses.compareTo(a.pauses));
    return out;
  }

  /// The thesis statistic, computed on the user's own data: Pearson r between
  /// daily scroll minutes and that day's self-reported focus.
  ///
  /// Only days that have both a usage figure and a check-in are paired.
  CorrelationResult? usageVsFocus(List<DailyStat> daily) {
    final x = <double>[];
    final y = <double>[];
    for (final d in daily) {
      final f = d.focusScore;
      if (f == null) continue;
      x.add(d.minutes.toDouble());
      y.add(f.toDouble());
    }
    return pearson(x, y);
  }

  /// Hours where the user pushes through most often, worst first.
  ///
  /// [minSample] keeps a single unlucky 1-of-1 hour from being reported as the
  /// user's "worst time of day".
  List<HourlyStat> riskiestHours(
    List<HourlyStat> hourly, {
    int minSample = 3,
    int take = 3,
  }) {
    final eligible = hourly.where((h) => h.pauses >= minSample).toList()
      ..sort((a, b) {
        final byRate = b.relapseRate.compareTo(a.relapseRate);
        return byRate != 0 ? byRate : b.pauses.compareTo(a.pauses);
      });
    return eligible.take(take).toList();
  }

  /// Consecutive days, counting back from the last day in [daily], on which the
  /// user backed out at least once. Days with no pauses at all break nothing —
  /// they simply weren't days that needed the app.
  int currentStreak(List<DailyStat> daily) {
    var streak = 0;
    for (final d in daily.reversed) {
      if (d.wentHome > 0) {
        streak++;
      } else if (d.pauses > 0) {
        break; // they were tempted and went through every time
      }
      // pauses == 0 -> neutral day, keep looking back
    }
    return streak;
  }

  /// Everything at once, for the Insights screen and the weekly report.
  InsightsSummary summarize({
    required List<PauseRecord> records,
    required List<DailyUsage> usage,
    required List<FocusCheckin> checkins,
    required DateTime from,
    required DateTime to,
  }) {
    final d = daily(
      records: records,
      usage: usage,
      checkins: checkins,
      from: from,
      to: to,
    );
    final h = hourly(records);

    return InsightsSummary(
      daily: d,
      hourly: h,
      byReason: byReason(records),
      usageVsFocus: usageVsFocus(d),
      totalPauses: records.length,
      totalWentHome: records.where((r) => r.wentHome).length,
      currentStreak: currentStreak(d),
      riskiestHours: riskiestHours(h),
    );
  }

  static DateTime _dayKey(DateTime t) => DateTime(t.year, t.month, t.day);
}
