import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/guarded_app.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pause_screen.dart';
import 'screens/root_nav.dart';
import 'services/interception_channel.dart';
import 'services/settings_controller.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = SettingsController(prefs);
  runApp(RefocusApp(controller: controller));
}

class RefocusApp extends StatelessWidget {
  final SettingsController controller;
  const RefocusApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<SettingsController>(
        builder: (context, c, _) => MaterialApp(
          title: 'Refocus',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: c.themeMode,
          home: const _Gate(),
        ),
      ),
    );
  }
}

/// Decides between onboarding and the main app, and hosts the native
/// interception listener for the whole session.
class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  final _channel = InterceptionChannel();
  StreamSubscription<String>? _sub;
  bool _pauseVisible = false;
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<SettingsController>();
    _channel.syncGuardedPackages(_controller.guardedPackages);
    _controller.addListener(_syncGuard);
    _sub = _channel.triggers.listen(_onAppOpened);
  }

  void _syncGuard() {
    _channel.syncGuardedPackages(_controller.guardedPackages);
  }

  Future<void> _onAppOpened(String package) async {
    final c = _controller;
    if (_pauseVisible || !c.shouldIntervene(package)) return;
    final app = c.apps.firstWhere(
      (a) => a.packageName == package,
      orElse: () => GuardedApp(
          packageName: package, name: package, emoji: '📱', colorHex: 0xFF334155),
    );
    _pauseVisible = true;
    await PauseScreen.show(
      navigatorKey.currentContext ?? context,
      appName: app.name,
      packageName: package,
    );
    _pauseVisible = false;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.removeListener(_syncGuard);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarded = context.select<SettingsController, bool>(
        (c) => c.onboardingDone);
    return onboarded ? const RootNav() : const OnboardingScreen();
  }
}
