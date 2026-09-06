import 'stats.dart';

// ---------------------------------------------------------------------------
// Inputs — plain domain objects, deliberately independent of the database so
// the analytics engine can be unit-tested without any storage at all.
// ---------------------------------------------------------------------------

/// One pause that was shown, flattened for analysis.
class PauseRecord {
  final DateTime timestamp;
  final String packageName;
  final String appName;
  final String reason;

  /// True when the user backed out instead of continuing into the app.
  final bool wentHome;

  final int hourOfDay;
  final int weekday; // 1 = Monday .. 7 = Sunday
  final int opensBefore;
  final int? minutesSinceLastOpen;
  final double? riskScore;

  const PauseRecord({
    required this.timestamp,
    required this.packageName,
    required this.appName,
    required this.reason,
    required this.wentHome,
    required this.hourOfDay,
    required this.weekday,
    required this.opensBefore,
    this.minutesSinceLastOpen,
    this.riskScore,
  });
}

/// Real foreground minutes for one day (summed across guarded apps).
class DailyUsage {
  final DateTime day;
  final int minutes;
  const DailyUsage({required this.day, required this.minutes});
}

/// Self-reported focus for one day, 1-5 — same scale as the diploma survey.
/// Higher means *better* focus, so a healthy app should show a **negative**
/// correlation between scroll minutes and this score.
class FocusCheckin {
  final DateTime day;
  final int score;
  const FocusCheckin({required this.day, required this.score});
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

class DailyStat {
  final DateTime day;
  final int minutes;
  final int pauses;
  final int wentHome;
  final int? focusScore;

  const DailyStat({
    required this.day,
    required this.minutes,
    required this.pauses,
    required this.wentHome,
    this.focusScore,
  });

  double get successRate => pauses == 0 ? 0 : wentHome / pauses;
}

class HourlyStat {
  final int hour; // 0..23
  final int pauses;
  final int wentHome;

  const HourlyStat({
    required this.hour,
    required this.pauses,
    required this.wentHome,
  });

  double get successRate => pauses == 0 ? 0 : wentHome / pauses;

  /// How often the user pushed through the pause at this hour.
  double get relapseRate => pauses == 0 ? 0 : 1 - successRate;
}

class ReasonStat {
  final String reason;
  final int pauses;
  final int wentHome;

  const ReasonStat({
    required this.reason,
    required this.pauses,
    required this.wentHome,
  });

  double get successRate => pauses == 0 ? 0 : wentHome / pauses;
}

/// Everything the Insights screen (and the future AI report) needs.
class InsightsSummary {
  final List<DailyStat> daily;
  final List<HourlyStat> hourly;
  final List<ReasonStat> byReason;

  /// Personal replication of the thesis statistic: scroll minutes vs. focus.
  final CorrelationResult? usageVsFocus;

  final int totalPauses;
  final int totalWentHome;
  final int currentStreak;

  /// Hours with the worst relapse rate that have enough samples to mean
  /// anything.
  final List<HourlyStat> riskiestHours;

  const InsightsSummary({
    required this.daily,
    required this.hourly,
    required this.byReason,
    required this.usageVsFocus,
    required this.totalPauses,
    required this.totalWentHome,
    required this.currentStreak,
    required this.riskiestHours,
  });

  double get overallSuccessRate =>
      totalPauses == 0 ? 0 : totalWentHome / totalPauses;

  bool get hasEnoughData => totalPauses >= 5;
}
