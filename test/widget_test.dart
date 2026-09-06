import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:refocus/screens/onboarding_screen.dart';
import 'package:refocus/services/settings_controller.dart';
import 'package:refocus/theme.dart';

const _interception = MethodChannel('refocus/interception');

Future<SettingsController> _controller() async {
  SharedPreferences.setMockInitialValues({});
  return SettingsController(await SharedPreferences.getInstance());
}

Future<void> _pumpOnboarding(WidgetTester tester, SettingsController c) {
  return tester.pumpWidget(
    ChangeNotifierProvider<SettingsController>.value(
      value: c,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const OnboardingScreen(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Stand in for the native side so permission requests resolve immediately.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_interception, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_interception, null);
  });

  testWidgets('onboarding explains the permissions and offers to grant them',
      (tester) async {
    await _pumpOnboarding(tester, await _controller());
    await tester.pump();

    expect(find.text('Let’s guard your focus'), findsOneWidget);
    expect(find.text('Detect app launches'), findsOneWidget);
    expect(find.text('Grant access'), findsOneWidget);
  });

  testWidgets('granting access records the goal and completes onboarding',
      (tester) async {
    final c = await _controller();
    expect(c.onboardingDone, isFalse);

    await _pumpOnboarding(tester, c);
    await tester.enterText(find.byType(TextField), 'fewer late nights');
    await tester.tap(find.text('Grant access'));
    await tester.pumpAndSettle();

    expect(c.goalText, 'fewer late nights');
    expect(c.onboardingDone, isTrue);
  });

  testWidgets('the goal stays empty when the field is left blank',
      (tester) async {
    final c = await _controller();
    await _pumpOnboarding(tester, c);
    await tester.tap(find.text('Grant access'));
    await tester.pumpAndSettle();

    expect(c.goalText, '');
    expect(c.onboardingDone, isTrue);
  });
}
