import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/insights_repository.dart';
import '../ml/risk_model.dart';
import '../models/pause_reason.dart';
import '../services/interception_channel.dart';
import '../services/reframe_service.dart';
import '../services/settings_controller.dart';
import '../theme.dart';
import '../widgets/countdown_ring.dart';

/// How the pause ended, returned to the caller.
enum PauseOutcome { home, openedAnyway }

/// The signature screen. Shown full-screen the moment a guarded app opens.
///
/// Step 1: name the intention. Step 2: a personal reframe plus the real cost,
/// with "go home" locked behind a countdown whose length the on-device risk
/// model chooses.
class PauseScreen extends StatefulWidget {
  final String appName;
  final String packageName;
  final ReframeService reframeService;

  const PauseScreen({
    super.key,
    required this.appName,
    required this.packageName,
    required this.reframeService,
  });

  static Future<PauseOutcome?> show(
    BuildContext context, {
    required String appName,
    required String packageName,
    ReframeService? reframeService,
  }) {
    return Navigator.of(context).push<PauseOutcome>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => PauseScreen(
          appName: appName,
          packageName: packageName,
          reframeService: reframeService ?? ReframeService(),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen> {
  PauseReason? _reason;
  PauseContext? _context;
  double? _risk;
  List<FeatureContribution> _why = const [];

  Reframe? _reframe;
  int _total = 15;
  int _left = 15;
  Timer? _timer;
  bool _recorded = false;

  Future<void> _chooseReason(PauseReason r) async {
    final repo = context.read<InsightsRepository>();
    final settings = context.read<SettingsController>();

    setState(() => _reason = r);
    settings.markIntervened(widget.packageName);

    final ctx = await repo.contextFor(
      packageName: widget.packageName,
      reason: r.id,
    );
    final risk = repo.riskFor(ctx);
    final seconds = repo.adaptivePauseSeconds(risk);

    if (!mounted) return;
    setState(() {
      _context = ctx;
      _risk = risk;
      _why = repo.explain(ctx);
      _total = seconds;
      _left = seconds;
    });
    _startCountdown();
    await _loadReframe(repo, settings, ctx);
  }

  Future<void> _loadReframe(
    InsightsRepository repo,
    SettingsController settings,
    PauseContext ctx,
  ) async {
    final minutes = await repo.minutesToday();
    final rf = await widget.reframeService.build(
      appName: widget.appName,
      reason: _reason!,
      goal: settings.goalText,
      opensToday: ctx.opensBefore,
      minutesToday: minutes,
      aiReady: settings.aiReady,
      apiKey: settings.apiKey,
    );
    if (mounted) setState(() => _reframe = rf);
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 0) {
        t.cancel();
        return;
      }
      setState(() => _left -= 1);
    });
  }

  Future<void> _finish(bool wentHome) async {
    if (_recorded) return;
    _recorded = true;

    final ctx = _context;
    if (ctx != null) {
      await context.read<InsightsRepository>().recordPause(
            context: ctx,
            packageName: widget.packageName,
            appName: widget.appName,
            wentHome: wentHome,
            pauseSeconds: _total,
            riskScore: _risk,
          );
    }
    if (wentHome) await InterceptionChannel().goHome();
    if (!mounted) return;
    Navigator.of(context)
        .pop(wentHome ? PauseOutcome.home : PauseOutcome.openedAnyway);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // no back-button escape hatch
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.1,
              colors: [NightPalette.bgTop, NightPalette.bg],
              stops: [0.0, 0.6],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _reason == null ? _buildIntention() : _buildReframe(),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Step 1: intention ----
  Widget _buildIntention() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text('You’re opening ${widget.appName}',
            style: const TextStyle(
                color: NightPalette.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('What for?',
            style: AppTheme.serif(
                size: 28, weight: FontWeight.w600, color: NightPalette.ink)),
        const SizedBox(height: 28),
        for (final r in PauseReason.values) ...[
          _IntentTile(reason: r, onTap: () => _chooseReason(r)),
          const SizedBox(height: 10),
        ],
        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('One honest tap. It shapes what you see next.',
              style: TextStyle(color: NightPalette.muted, fontSize: 12)),
        ),
      ],
    );
  }

  // ---- Step 2: reframe + countdown ----
  Widget _buildReframe() {
    final unlocked = _left <= 0;
    final risk = _risk;
    final highRisk = risk != null && risk >= 0.6;

    return Column(
      children: [
        const SizedBox(height: 12),
        Text('${_reason!.label} · ${widget.appName} paused',
            style: const TextStyle(
                color: NightPalette.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        CountdownRing(secondsLeft: _left, total: _total),
        if (highRisk) ...[
          const SizedBox(height: 12),
          _RiskBadge(risk: risk, why: _why),
        ],
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: _ReframeCard(reframe: _reframe),
          ),
        ),
        Text(
          unlocked ? 'Your call now 👇' : 'Home unlocks in ${_left}s',
          style: const TextStyle(color: NightPalette.muted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _PauseButton(
          label: 'Not now — take me home',
          filled: true,
          enabled: unlocked,
          onTap: () => _finish(true),
        ),
        const SizedBox(height: 9),
        _PauseButton(
          label: 'Open for 5 min',
          filled: false,
          enabled: true,
          onTap: () => _finish(false),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

/// Surfaces the model's judgement — and, crucially, why it thinks so.
class _RiskBadge extends StatelessWidget {
  final double risk;
  final List<FeatureContribution> why;

  const _RiskBadge({required this.risk, required this.why});

  @override
  Widget build(BuildContext context) {
    final top = why.where((w) => w.contribution > 0).take(2).toList();
    final reason = top.isEmpty
        ? 'this kind of moment'
        : top.map((t) => t.label.toLowerCase()).join(' + ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x22E0A45E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x55E0A45E)),
      ),
      child: Column(
        children: [
          Text('Historically a risky moment for you — ${(risk * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFE0A45E),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(reason,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: NightPalette.muted, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _IntentTile extends StatelessWidget {
  final PauseReason reason;
  final VoidCallback onTap;
  const _IntentTile({required this.reason, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NightPalette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NightPalette.surfaceLine),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Text(reason.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(reason.label,
                  style: const TextStyle(
                      color: NightPalette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReframeCard extends StatelessWidget {
  final Reframe? reframe;
  const _ReframeCard({required this.reframe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: NightPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NightPalette.surfaceLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✦ ',
                  style: TextStyle(color: NightPalette.teal, fontSize: 12)),
              Text(reframe?.fromAi == true ? 'FOR YOU' : 'A THOUGHT',
                  style: const TextStyle(
                      color: NightPalette.teal,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6)),
            ],
          ),
          const SizedBox(height: 11),
          if (reframe == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: NightPalette.teal),
              ),
            )
          else
            Text(reframe!.line,
                style: AppTheme.serif(
                    size: 17.5,
                    weight: FontWeight.w500,
                    color: NightPalette.ink,
                    height: 1.44)),
          if (reframe != null) ...[
            const SizedBox(height: 14),
            const Divider(color: NightPalette.surfaceLine, height: 1),
            const SizedBox(height: 12),
            Text(reframe!.costLine,
                style: const TextStyle(
                    color: NightPalette.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()])),
            if (reframe!.goalLine != null) ...[
              const SizedBox(height: 5),
              Text('Goal: ${reframe!.goalLine}',
                  style: const TextStyle(
                      color: NightPalette.teal,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
            ],
          ],
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;

  const _PauseButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: filled ? NightPalette.teal : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: filled ? null : Border.all(color: NightPalette.surfaceLine),
      ),
      child: Text(label,
          style: TextStyle(
              color: filled ? Colors.white : NightPalette.muted,
              fontSize: 14.5,
              fontWeight: FontWeight.w700)),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: child,
      ),
    );
  }
}
