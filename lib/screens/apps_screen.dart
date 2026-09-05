import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/guarded_app.dart';
import '../services/settings_controller.dart';
import '../theme.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

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
            Text('Guarded apps',
                style: TextStyle(
                    color: p.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Pick what should trigger a pause.',
                style: TextStyle(color: p.muted, fontSize: 13)),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  for (int i = 0; i < c.apps.length; i++)
                    _AppRow(
                      app: c.apps[i],
                      palette: p,
                      last: i == c.apps.length - 1,
                      onChanged: (v) => c.toggleApp(c.apps[i], v),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  final GuardedApp app;
  final AppPalette palette;
  final bool last;
  final ValueChanged<bool> onChanged;

  const _AppRow({
    required this.app,
    required this.palette,
    required this.last,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: palette.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(app.colorHex),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(app.emoji,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.name,
                    style: TextStyle(
                        color: palette.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(app.guarded ? 'Guarded' : 'Not guarded',
                    style: TextStyle(color: palette.muted, fontSize: 11.5)),
              ],
            ),
          ),
          Switch(
            value: app.guarded,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: palette.teal,
          ),
        ],
      ),
    );
  }
}
