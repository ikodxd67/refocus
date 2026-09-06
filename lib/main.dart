import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'data/insights_repository.dart';
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
  final settings = SettingsController(prefs);

  final database = AppDatabase();
  final insights = InsightsRepository(db: database);
  await insights.init();

  runApp(RefocusApp(settings: settings, insights: insights));
}

class RefocusApp extends StatelessWidget {
  final SettingsController settings;
  final InsightsRepository insights;

  const RefocusApp({
    super.key,
    required this.settings,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: insights),
      ],
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
  late final SettingsController _settings;

  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsController>();
    _channel.syncGuardedPackages(_settings.guardedPackages);
    _settings.addListener(_syncGuard);
    _sub = _channel.triggers.listen(_onAppOpened);

    // Pull real foreground minutes once at launch; never from a listener, so
    // it can't loop with the screens that refresh on repository changes.
    unawaited(
      context
          .read<InsightsRepository>()
          .syncUsage(packages: _settings.guardedPackages),
    );
  }

  void _syncGuard() => _channel.syncGuardedPackages(_settings.guardedPackages);

  Future<void> _onAppOpened(String package) async {
    if (_pauseVisible || !_settings.shouldIntervene(package)) return;

    final app = _settings.appFor(package) ??
        GuardedApp(
          packageName: package,
          name: package,
          emoji: '📱',
          colorHex: 0xFF334155,
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
    _settings.removeListener(_syncGuard);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarded =
        context.select<SettingsController, bool>((c) => c.onboardingDone);
    return onboarded ? const RootNav() : const OnboardingScreen();
  }
}
