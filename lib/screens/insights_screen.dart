import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../analytics/models.dart';
import '../data/insights_repository.dart';
import '../ml/model_evaluation.dart';
import '../ml/risk_model.dart';
import '../models/pause_reason.dart';
import '../theme.dart';
import '../widgets/bar_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsSummary? _summary;
  EvaluationResult? _evaluation;
  bool _loading = true;
  late final InsightsRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = context.read<InsightsRepository>();
    _repo.addListener(_load);
    _load();
  }

  Future<void> _load() async {
    final summary = await _repo.summary(days: 30);
    final evaluation = await _repo.evaluate();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _evaluation = evaluation;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _repo.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final s = _summary;

    return SafeArea(
      child: _loading
          ? Center(child: CircularProgressIndicator(color: p.teal))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              children: [
                Text('Insights',
                    style: TextStyle(
                        color: p.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                Text('Last 30 days, computed from your own log.',
                    style: TextStyle(color: p.muted, fontSize: 13)),
                const SizedBox(height: 16),
                if (s == null || s.totalPauses == 0)
                  _EmptyState(palette: p)
                else ...[
                  _Totals(summary: s, palette: p),
                  const SizedBox(height: 18),
                  _CorrelationCard(summary: s, palette: p),
                  const SizedBox(height: 18),
                  _DailyMinutesCard(summary: s, palette: p),
                  const SizedBox(height: 18),
                  _HourlyCard(summary: s, palette: p),
                  const SizedBox(height: 18),
                  _ReasonCard(summary: s, palette: p),
                  const SizedBox(height: 18),
                  _ModelCard(
                    evaluation: _evaluation,
                    model: context.watch<InsightsRepository>().model,
                    palette: p,
                  ),
                ],
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final AppPalette palette;

  const _Section({
    required this.title,
    this.subtitle,
    required this.child,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: palette.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: TextStyle(
                    color: palette.muted, fontSize: 12, height: 1.4)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppPalette palette;
  const _EmptyState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        children: [
          Text('No pauses yet',
              style: TextStyle(
                  color: palette.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Every pause you go through is one row in your own dataset. '
            'Come back once you have a few — the numbers here are all computed '
            'from it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  final InsightsSummary summary;
  final AppPalette palette;
  const _Totals({required this.summary, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(
            value: '${summary.totalPauses}',
            label: 'Pauses',
            palette: palette,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            value: '${(summary.overallSuccessRate * 100).round()}%',
            label: 'Backed out',
            palette: palette,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            value: '${summary.currentStreak}',
            label: 'Day streak',
            palette: palette,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette palette;
  const _Tile(
      {required this.value, required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          Text(label,
              style: TextStyle(
                  color: palette.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// The diploma's own statistic, recomputed on the user's personal data.
class _CorrelationCard extends StatelessWidget {
  final InsightsSummary summary;
  final AppPalette palette;
  const _CorrelationCard({required this.summary, required this.palette});

  @override
  Widget build(BuildContext context) {
    final r = summary.usageVsFocus;
    final paired =
        summary.daily.where((d) => d.focusScore != null).length;

    return _Section(
      palette: palette,
      title: 'Scroll time vs. your focus',
      subtitle:
          'Pearson correlation between daily minutes and your own focus rating '
          '— the same statistic the study used, on your data.',
      child: r == null
          ? Text(
              paired == 0
                  ? 'Rate your focus at the end of a few days and this appears.'
                  : 'Need at least 3 days with both numbers — you have $paired.',
              style: TextStyle(color: palette.muted, fontSize: 13, height: 1.5),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('r = ${r.r.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: palette.teal,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                    const SizedBox(width: 10),
                    Text('p = ${r.p.toStringAsFixed(3)} · n = ${r.n} days',
                        style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(_interpret(r.r, r.strength),
                    style: AppTheme.serif(
                        size: 15.5, color: palette.ink, height: 1.45)),
                const SizedBox(height: 8),
                Text(
                  r.isSignificant
                      ? 'Statistically significant (p < 0.05).'
                      : 'Not yet statistically significant — keep checking in.',
                  style: TextStyle(
                      color: r.isSignificant ? palette.teal : palette.faint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
    );
  }

  String _interpret(double r, String strength) {
    if (r < -0.1) {
      return 'A $strength negative link: on days you scrolled more, you rated '
          'your focus lower.';
    }
    if (r > 0.1) {
      return 'A $strength positive link — unusually, your focus rated higher on '
          'heavier days. Worth a look at what else those days had in common.';
    }
    return 'No meaningful link so far in your data.';
  }
}

class _DailyMinutesCard extends StatelessWidget {
  final InsightsSummary summary;
  final AppPalette palette;
  const _DailyMinutesCard({required this.summary, required this.palette});

  @override
  Widget build(BuildContext context) {
    final last14 = summary.daily.length > 14
        ? summary.daily.sublist(summary.daily.length - 14)
        : summary.daily;

    final hasUsage = last14.any((d) => d.minutes > 0);

    return _Section(
      palette: palette,
      title: 'Daily scroll minutes',
      subtitle: hasUsage
          ? 'Measured foreground time in your guarded apps.'
          : 'Grant usage access on Android to fill this in.',
      child: BarChart(
        bars: [
          for (final d in last14)
            Bar(value: d.minutes.toDouble(), label: '${d.day.day}'),
        ],
        labelEvery: 2,
        maxLabel: hasUsage
            ? '${last14.map((d) => d.minutes).reduce((a, b) => a > b ? a : b)} min'
            : null,
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  final InsightsSummary summary;
  final AppPalette palette;
  const _HourlyCard({required this.summary, required this.palette});

  @override
  Widget build(BuildContext context) {
    final risky = summary.riskiestHours.map((h) => h.hour).toSet();

    return _Section(
      palette: palette,
      title: 'When you push through',
      subtitle:
          'Share of pauses at each hour where you opened the app anyway.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarChart(
            bars: [
              for (final h in summary.hourly)
                Bar(
                  value: h.relapseRate,
                  label: h.hour % 4 == 0 ? '${h.hour}' : '',
                  highlight: risky.contains(h.hour),
                ),
            ],
            maxValue: 1,
            maxLabel: '100%',
            height: 100,
          ),
          if (summary.riskiestHours.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in summary.riskiestHours)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: palette.tealSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${h.hour.toString().padLeft(2, '0')}:00 · '
                      '${(h.relapseRate * 100).round()}% slips',
                      style: TextStyle(
                          color: palette.tealInk,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  final InsightsSummary summary;
  final AppPalette palette;
  const _ReasonCard({required this.summary, required this.palette});

  @override
  Widget build(BuildContext context) {
    return _Section(
      palette: palette,
      title: 'Which intention actually holds',
      subtitle: 'How often you backed out, by the reason you tapped.',
      child: Column(
        children: [
          for (final r in summary.byReason)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 108,
                    child: Text(_label(r.reason),
                        style: TextStyle(
                            color: palette.ink,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: r.successRate,
                        minHeight: 8,
                        backgroundColor: palette.line,
                        valueColor: AlwaysStoppedAnimation(palette.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 58,
                    child: Text(
                      '${(r.successRate * 100).round()}% · ${r.pauses}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: palette.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _label(String id) {
    for (final r in PauseReason.values) {
      if (r.id == id) return r.label;
    }
    return id;
  }
}

/// Makes the on-device model inspectable instead of a black box.
class _ModelCard extends StatelessWidget {
  final EvaluationResult? evaluation;
  final RiskModel model;
  final AppPalette palette;

  const _ModelCard({
    required this.evaluation,
    required this.model,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final e = evaluation;
    final weights = model.weights.entries
        .where((w) => w.key != 'bias' && w.value.abs() > 1e-4)
        .toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final top = weights.take(5).toList();
    final maxAbs = top.isEmpty
        ? 1.0
        : top.map((w) => w.value.abs()).reduce((a, b) => a > b ? a : b);

    return _Section(
      palette: palette,
      title: 'Your risk model',
      subtitle: 'Logistic regression trained on this phone from your '
          '${model.trainedOn} events. It predicts whether you will push '
          'through, and sets how long the pause locks.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!model.isReady)
            Text(
              'Still learning — needs ${RiskModel.minObservations} events, '
              'has ${model.trainedOn}. Until then every pause is a flat 15s.',
              style: TextStyle(color: palette.muted, fontSize: 13, height: 1.5),
            )
          else ...[
            if (e != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      value: '${(e.accuracy * 100).round()}%',
                      label: 'Accuracy',
                      palette: palette,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Tile(
                      value: e.auc.toStringAsFixed(2),
                      label: 'ROC AUC',
                      palette: palette,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Tile(
                      value: '${(e.baselineAccuracy * 100).round()}%',
                      label: 'Baseline',
                      palette: palette,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                e.beatsBaseline
                    ? 'Beats always-guess-the-majority by '
                        '${(e.lift * 100).round()} points on ${e.testSize} '
                        'held-out events.'
                    : 'Not beating the majority-class baseline yet on '
                        '${e.testSize} held-out events.',
                style: TextStyle(
                    color: e.beatsBaseline ? palette.teal : palette.faint,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
            ],
            Text('What pushes your risk up and down',
                style: TextStyle(
                    color: palette.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final w in top)
              _WeightRow(
                label: RiskModel.featureLabels[w.key] ?? w.key,
                weight: w.value,
                maxAbs: maxAbs,
                palette: palette,
              ),
          ],
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  final String label;
  final double weight;
  final double maxAbs;
  final AppPalette palette;

  const _WeightRow({
    required this.label,
    required this.weight,
    required this.maxAbs,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (weight.abs() / maxAbs).clamp(0.0, 1.0);
    final pushesUp = weight > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: palette.ink, fontSize: 12)),
          ),
          Expanded(
            child: Row(
              children: [
                // left half = lowers risk, right half = raises it
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: pushesUp ? 0 : ratio,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: palette.teal,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 12, color: palette.line),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pushesUp ? ratio : 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC77A28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
