import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:refocus/main.dart';
import 'package:refocus/services/settings_controller.dart';

void main() {
  testWidgets('first run shows onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(RefocusApp(controller: SettingsController(prefs)));
    await tester.pump();

    expect(find.text('Grant access'), findsOneWidget);
  });
}
