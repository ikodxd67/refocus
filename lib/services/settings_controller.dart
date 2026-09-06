import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guarded_app.dart';

/// User configuration: what to guard, how often to interrupt, and the AI
/// settings.
///
/// Statistics deliberately do **not** live here — every number the app reports
/// is derived from the event log in the database, so there is a single source
/// of truth. This class only keeps settings plus the last-intervention
/// timestamps that drive the "no more than once every N minutes" rule.
class SettingsController extends ChangeNotifier {
  static const _key = 'refocus_state_v2';

  final SharedPreferences _prefs;

  SettingsController(this._prefs) {
    _load();
  }

  // ---- configuration ----
  bool protectionOn = true;
  List<GuardedApp> apps = GuardedApp.defaults();
  int minIntervalMinutes = 10;
  String goalText = '';
  bool aiEnabled = true;
  String apiKey = '';
  bool onboardingDone = false;
  ThemeMode themeMode = ThemeMode.system;

  final Map<String, int> _lastInterventionMs = {}; // package -> epoch ms

  // ---- derived ----
  int get guardedCount => apps.where((a) => a.guarded).length;

  List<GuardedApp> get guardedApps =>
      apps.where((a) => a.guarded).toList(growable: false);

  Set<String> get guardedPackages =>
      guardedApps.map((a) => a.packageName).toSet();

  bool get aiReady => aiEnabled && apiKey.trim().isNotEmpty;

  GuardedApp? appFor(String packageName) {
    for (final a in apps) {
      if (a.packageName == packageName) return a;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Intervention rule
  // ---------------------------------------------------------------------------

  /// Whether opening [package] right now should trigger a pause.
  bool shouldIntervene(String package) {
    if (!protectionOn) return false;
    if (!guardedPackages.contains(package)) return false;
    final last = _lastInterventionMs[package];
    if (last == null) return true;
    final elapsedMin =
        (DateTime.now().millisecondsSinceEpoch - last) / 60000.0;
    return elapsedMin >= minIntervalMinutes;
  }

  /// Remember that we just interrupted [package], so we don't do it again
  /// before the configured interval has passed.
  void markIntervened(String package) {
    _lastInterventionMs[package] = DateTime.now().millisecondsSinceEpoch;
    _save();
  }

  // ---------------------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------------------

  void setProtection(bool on) {
    protectionOn = on;
    _save();
    notifyListeners();
  }

  void toggleApp(GuardedApp app, bool guarded) {
    app.guarded = guarded;
    _save();
    notifyListeners();
  }

  void setInterval(int minutes) {
    minIntervalMinutes = minutes;
    _save();
    notifyListeners();
  }

  void setGoal(String goal) {
    goalText = goal.trim();
    _save();
    notifyListeners();
  }

  void setAiEnabled(bool on) {
    aiEnabled = on;
    _save();
    notifyListeners();
  }

  void setApiKey(String key) {
    apiKey = key.trim();
    _save();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _save();
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingDone = true;
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      protectionOn = j['protectionOn'] as bool? ?? true;
      minIntervalMinutes = j['minIntervalMinutes'] as int? ?? 10;
      goalText = j['goalText'] as String? ?? '';
      aiEnabled = j['aiEnabled'] as bool? ?? true;
      apiKey = j['apiKey'] as String? ?? '';
      onboardingDone = j['onboardingDone'] as bool? ?? false;
      themeMode = ThemeMode.values[(j['themeMode'] as int? ?? 0)
          .clamp(0, ThemeMode.values.length - 1)];

      final appsJson = j['apps'] as List<dynamic>?;
      if (appsJson != null && appsJson.isNotEmpty) {
        apps = appsJson
            .map((e) => GuardedApp.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final li = j['lastInterventionMs'] as Map<String, dynamic>?;
      if (li != null) {
        _lastInterventionMs
            .addAll(li.map((k, v) => MapEntry(k, (v as num).toInt())));
      }
    } catch (_) {
      // Corrupt state -> fall back to defaults silently.
    }
  }

  Future<void> _save() async {
    final j = {
      'protectionOn': protectionOn,
      'minIntervalMinutes': minIntervalMinutes,
      'goalText': goalText,
      'aiEnabled': aiEnabled,
      'apiKey': apiKey,
      'onboardingDone': onboardingDone,
      'themeMode': themeMode.index,
      'apps': apps.map((a) => a.toJson()).toList(),
      'lastInterventionMs': _lastInterventionMs,
    };
    await _prefs.setString(_key, jsonEncode(j));
  }
}
