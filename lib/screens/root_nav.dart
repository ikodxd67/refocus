import 'package:flutter/material.dart';

import '../theme.dart';
import 'apps_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// The bottom-tab shell — Home · Apps · Settings.
class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _screens = [HomeScreen(), AppsScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: p.surface,
            indicatorColor: p.tealSoft,
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: p.muted),
            ),
          ),
          child: NavigationBar(
            height: 66,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: p.faint),
                selectedIcon: Icon(Icons.home_rounded, color: p.teal),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, color: p.faint),
                selectedIcon: Icon(Icons.grid_view_rounded, color: p.teal),
                label: 'Apps',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: p.faint),
                selectedIcon: Icon(Icons.settings_rounded, color: p.teal),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
