import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../analytics/models.dart';
import '../data/insights_repository.dart';
import '../services/settings_controller.dart';
import '../theme.dart';
import 'pause_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final InsightsRepository _repo;
  InsightsSummary? _summary;
  int? _todayFocus;

  @override
  void initState() {
    super.initState();
    _repo = context.read<InsightsRepository>();
    _repo.addListener(_load);
    _load();
  }

  Future<void> _load() async {
    final summary = await _repo.summary(days: 30);
    final focus = await _repo.todayCheckin();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _todayFocus = focus;
    });
  }

  @override
  void dispose() {
    _repo.removeListener(_load);
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = context.watch<SettingsController>();
    final today = _summary?.daily.isNotEmpty == true ? _summary!.daily.last : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting,
                        style: TextStyle(
                            color: p.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Today',
                        style: TextStyle(
                            color: p.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: p.tealSoft,
                child: Text('A',
                    style: TextStyle(
                        color: p.tealInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ShieldCard(controller: c),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                    value: '${today?.pauses ?? 0}',
                    label: 'Pauses today',
                    palette: p),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                    value: '${_summary?.currentStreak ?? 0}',
                    label: 'Day streak',
                    palette: p),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CheckinCard(
            palette: p,
            score: _todayFocus,
            onPick: (v) => _repo.saveCheckin(v),
          ),
          const SizedBox(height: 12),
          _TryPauseButton(palette: p),
        ],
      ),
    );
  }
}

/// The daily focus rating — the other half of the personal correlation.
class _CheckinCard extends StatelessWidget {
  final AppPalette palette;
  final int? score;
  final ValueChanged<int> onPick;

  const _CheckinCard({
    required this.palette,
    required this.score,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final answered = score != null;
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
          Text(answered ? 'Today’s focus' : 'How was your focus today?',
              style: TextStyle(
                  color: palette.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            answered
                ? 'Tap to change. This is what your correlation is built on.'
                : '1 = scattered, 5 = sharp. Takes a second, and it powers Insights.',
            style: TextStyle(color: palette.muted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var v = 1; v <= 5; v++) ...[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onPick(v),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: score == v ? palette.teal : palette.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: score == v ? palette.teal : palette.line,
                        ),
                      ),
                      child: Text('$v',
                          style: TextStyle(
                              color: score == v ? Colors.white : palette.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                if (v < 5) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ShieldCard extends StatelessWidget {
  final SettingsController controller;
  const _ShieldCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final on = controller.protectionOn;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: on
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E7C6B), Color(0xFF0A5A4E)])
            : null,
        color: on ? null : p.surface2,
        border: on ? null : Border.all(color: p.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🛡  Protection',
                    style: TextStyle(
                        color: on ? Colors.white70 : p.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(on ? 'On' : 'Off',
                    style: TextStyle(
                        color: on ? Colors.white : p.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Guarding ${controller.guardedCount} apps',
                    style: TextStyle(
                        color: on ? Colors.white70 : p.muted, fontSize: 12.5)),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: controller.setProtection,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette palette;
  const _StatTile(
      {required this.value, required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(
                  color: palette.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Lets you experience the pause without native interception wired up.
class _TryPauseButton extends StatelessWidget {
  final AppPalette palette;
  const _TryPauseButton({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => PauseScreen.show(
          context,
          appName: 'TikTok',
          packageName: 'com.zhiliaoapp.musically',
        ),
        icon: const Icon(Icons.play_circle_outline, size: 18),
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.teal,
          side: BorderSide(color: palette.line),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        label: const Text('Try a pause now',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
