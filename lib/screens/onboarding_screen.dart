import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/interception_channel.dart';
import '../services/settings_controller.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _goalCtrl = TextEditingController();

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _grant() async {
    final c = context.read<SettingsController>();
    if (_goalCtrl.text.trim().isNotEmpty) c.setGoal(_goalCtrl.text);
    await InterceptionChannel().requestPermissions();
    c.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: p.teal,
                    borderRadius: BorderRadius.circular(19)),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Let’s guard your focus',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Refocus needs permission to notice when a guarded app opens. '
                'Nothing you do is recorded.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 18),
              _Step(p,
                  n: '1',
                  title: 'Detect app launches',
                  desc: 'Accessibility on Android · Screen Time on iOS'),
              _Step(p,
                  n: '2',
                  title: 'Show the pause screen',
                  desc: 'Display over other apps'),
              _Step(p,
                  n: '3',
                  title: 'Stay awake in the background',
                  desc: 'Ignore battery optimisation',
                  last: true),
              const SizedBox(height: 18),
              TextField(
                controller: _goalCtrl,
                textAlign: TextAlign.center,
                style: AppTheme.serif(size: 16, color: p.ink),
                decoration: InputDecoration(
                  hintText: 'In one line — why scroll less? (optional)',
                  hintStyle: TextStyle(
                      color: p.faint,
                      fontStyle: FontStyle.italic,
                      fontSize: 14),
                  filled: true,
                  fillColor: p.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.line),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _grant,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Grant access',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              Text('You can turn everything off any time.',
                  style: TextStyle(color: p.faint, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final AppPalette p;
  final String n;
  final String title;
  final String desc;
  final bool last;
  const _Step(this.p,
      {required this.n,
      required this.title,
      required this.desc,
      this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.tealSoft, borderRadius: BorderRadius.circular(9)),
            child: Text(n,
                style: TextStyle(
                    color: p.tealInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: p.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                Text(desc,
                    style: TextStyle(
                        color: p.muted, fontSize: 11.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
