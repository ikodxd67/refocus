import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/guarded_app.dart';

/// Single source of truth for user configuration and lightweight stats.
///
/// Everything lives locally in [SharedPreferences] as one JSON blob — no
/// account, no server. Screens listen to this via `provider`.
class SettingsController extends ChangeNotifier {
  static const _key = 'refocus_state_v1';

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

  // ---- runtime state / stats ----
  final Map<String, int> _lastInterventionMs = {}; // package -> epoch ms
  int opensToday = 0;
  int minutesToday = 0; // filled by native UsageStats when available
  int streakDays = 0;
  String _statsDay = _today();
  String _lastPauseDay = '';

  // ---- derived ----
  int get guardedCount => apps.where((a) => a.guarded).length;

  List<GuardedApp> get guardedApps =>
      apps.where((a) => a.guarded).toList(growable: false);

  Set<String> get guardedPackages =>
      guardedApps.map((a) => a.packageName).toSet();

  bool get aiReady => aiEnabled && apiKey.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Intervention decision — the core rule that keeps pauses from spamming.
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

  /// Record that a pause was shown for [package] and roll daily counters.
  void recordIntervention(String package) {
    _rollDayIfNeeded();
    _lastInterventionMs[package] = DateTime.now().millisecondsSinceEpoch;
    opensToday += 1;
    _save();
    notifyListeners();
  }

  /// User chose "take me home" — counts toward today's streak.
  void recordWentHome() {
    final today = _today();
    if (_lastPauseDay != today) {
      // consecutive day? bump streak, otherwise restart at 1
      final yesterday = _dayString(
          DateTime.now().subtract(const Duration(days: 1)));
      streakDays = (_lastPauseDay == yesterday) ? streakDays + 1 : 1;
      _lastPauseDay = today;
      _save();
      notifyListeners();
    }
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

  void _rollDayIfNeeded() {
    final today = _today();
    if (today != _statsDay) {
      _statsDay = today;
      opensToday = 0;
      minutesToday = 0;
    }
  }

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
      opensToday = j['opensToday'] as int? ?? 0;
      minutesToday = j['minutesToday'] as int? ?? 0;
      streakDays = j['streakDays'] as int? ?? 0;
      _statsDay = j['statsDay'] as String? ?? _today();
      _lastPauseDay = j['lastPauseDay'] as String? ?? '';

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
      _rollDayIfNeeded();
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
      'opensToday': opensToday,
      'minutesToday': minutesToday,
      'streakDays': streakDays,
      'statsDay': _statsDay,
      'lastPauseDay': _lastPauseDay,
      'apps': apps.map((a) => a.toJson()).toList(),
      'lastInterventionMs': _lastInterventionMs,
    };
    await _prefs.setString(_key, jsonEncode(j));
  }

  static String _today() => _dayString(DateTime.now());
  static String _dayString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
