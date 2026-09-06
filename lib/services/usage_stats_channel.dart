import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads real per-app foreground time from the platform.
///
/// Android only for now (UsageStatsManager). Everywhere else every call is a
/// safe no-op, so the app runs normally and simply reports no minutes.
class UsageStatsChannel {
  static const _channel = MethodChannel('refocus/usage');

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasAccess() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system "Usage access" settings page.
  Future<void> requestAccess() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('requestUsageAccess');
    } catch (_) {
      // ignore — the UI reflects the real state on the next check
    }
  }

  /// Foreground minutes per package in `[from, to)`.
  Future<Map<String, int>> minutesBetween(DateTime from, DateTime to) async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMapMethod<String, int>(
        'minutesBetween',
        {
          'start': from.millisecondsSinceEpoch,
          'end': to.millisecondsSinceEpoch,
        },
      );
      return raw ?? const {};
    } catch (_) {
      return const {};
    }
  }
}
