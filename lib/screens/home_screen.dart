import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_controller.dart';
import '../theme.dart';
import 'pause_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      value: '${c.opensToday}',
                      label: 'Pauses today',
                      palette: p),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                      value: '${c.streakDays}',
                      label: 'Day streak',
                      palette: p),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TryPauseButton(palette: p),
          ],
        ),
      ),
    );
  }
}

class _ShieldCard extends StatelessWidget {
  final SettingsController controller;
  const _ShieldCard({required this.controller});

  @override
  Widget build(BuildContext context) {
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
        color: on ? null : AppPalette.of(context).surface2,
        border: on
            ? null
            : Border.all(color: AppPalette.of(context).line),
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
                        color: on
                            ? Colors.white70
                            : AppPalette.of(context).muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(on ? 'On' : 'Off',
                    style: TextStyle(
                        color:
                            on ? Colors.white : AppPalette.of(context).ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Guarding ${controller.guardedCount} apps',
                    style: TextStyle(
                        color: on
                            ? Colors.white70
                            : AppPalette.of(context).muted,
                        fontSize: 12.5)),
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

/// Lets you experience the pause without native interception wired up —
/// essential while previewing, and a nice "show me how it feels" for users.
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
