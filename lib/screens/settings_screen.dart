import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_controller.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = context.watch<SettingsController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings',
                style: TextStyle(
                    color: p.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            const SizedBox(height: 16),

            _Label('Pause frequency', p),
            _Card(p, [
              Text.rich(
                TextSpan(
                  style: TextStyle(color: p.muted, fontSize: 13),
                  children: [
                    const TextSpan(text: 'Pause me at most once every '),
                    TextSpan(
                        text: '${c.minIntervalMinutes} min',
                        style: TextStyle(
                            color: p.ink, fontWeight: FontWeight.w800)),
                    const TextSpan(text: ' per app'),
                  ],
                ),
              ),
              Slider(
                value: c.minIntervalMinutes.toDouble(),
                min: 2,
                max: 30,
                divisions: 28,
                activeColor: p.teal,
                onChanged: (v) => c.setInterval(v.round()),
              ),
            ]),

            const SizedBox(height: 16),
            _Label('Your goal · shown in every pause', p),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _editGoal(context, c),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.line),
                ),
                child: Text(
                  c.goalText.isEmpty
                      ? 'Tap to add your reason to scroll less…'
                      : '“${c.goalText}”',
                  style: AppTheme.serif(
                      size: 16,
                      weight: FontWeight.w500,
                      color: c.goalText.isEmpty ? p.faint : p.ink),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _Label('Personal reframes (AI)', p),
            _Card(p, [
              _Row(
                p,
                icon: '✨',
                title: 'Smart reframes',
                subtitle: 'Gemini · falls back to templates offline',
                trailing: Switch(
                    value: c.aiEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: p.teal,
                    onChanged: c.setAiEnabled),
              ),
              if (c.aiEnabled)
                _Row(
                  p,
                  icon: '🔑',
                  title: 'Gemini API key',
                  subtitle: c.apiKey.isEmpty
                      ? 'Not set — reframes use offline templates'
                      : '•••• ${c.apiKey.substring(c.apiKey.length - 4)} · saved',
                  trailing: TextButton(
                    onPressed: () => _editKey(context, c),
                    child: Text(c.apiKey.isEmpty ? 'Add' : 'Change'),
                  ),
                  last: true,
                ),
            ]),

            const SizedBox(height: 16),
            _Label('Appearance', p),
            _Card(p, [
              for (final mode in ThemeMode.values)
                _Row(
                  p,
                  icon: mode == ThemeMode.system
                      ? '🌗'
                      : mode == ThemeMode.light
                          ? '☀️'
                          : '🌙',
                  title: _modeLabel(mode),
                  trailing: c.themeMode == mode
                      ? Icon(Icons.check, color: p.teal, size: 20)
                      : const SizedBox.shrink(),
                  onTap: () => c.setThemeMode(mode),
                  last: mode == ThemeMode.values.last,
                ),
            ]),

            const SizedBox(height: 16),
            _Label('About', p),
            _Card(p, [
              _Row(p,
                  icon: 'ⓘ',
                  title: 'Refocus',
                  subtitle: 'Version 1.0.0',
                  last: true),
            ]),
          ],
        ),
      ),
    );
  }

  String _modeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'Match system',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Future<void> _editGoal(BuildContext context, SettingsController c) async {
    final result = await _promptText(
      context,
      title: 'Your goal',
      hint: 'e.g. fewer late nights before finals',
      initial: c.goalText,
    );
    if (result != null) c.setGoal(result);
  }

  Future<void> _editKey(BuildContext context, SettingsController c) async {
    final result = await _promptText(
      context,
      title: 'Gemini API key',
      hint: 'Paste your key',
      initial: c.apiKey,
      obscure: true,
    );
    if (result != null) c.setApiKey(result);
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String hint,
    required String initial,
    bool obscure = false,
  }) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }
}

// ---- small building blocks ----

class _Label extends StatelessWidget {
  final String text;
  final AppPalette p;
  const _Label(this.text, this.p);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                color: p.faint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7)),
      );
}

class _Card extends StatelessWidget {
  final AppPalette p;
  final List<Widget> children;
  const _Card(this.p, this.children);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(children: children),
      );
}

class _Row extends StatelessWidget {
  final AppPalette p;
  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;

  const _Row(
    this.p, {
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.tealSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: p.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: TextStyle(color: p.muted, fontSize: 11.5)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
