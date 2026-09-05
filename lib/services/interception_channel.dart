import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge to the native launch-interception layer.
///
///  * Android — an AccessibilityService detects when a guarded app comes to
///    the foreground and pushes its package name over [_events].
///  * iOS — a Shortcuts "app opened" automation re-opens Refocus; the native
///    side reports which app triggered it over the same channel.
///
/// On platforms without native support (Windows/macOS/web used for previewing
/// the UI), every call is a safe no-op and [triggers] never emits — so the
/// Flutter app still runs and the pause can be shown manually.
class InterceptionChannel {
  static const _method = MethodChannel('refocus/interception');
  static const _events = EventChannel('refocus/interception/events');

  bool get isNativelySupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Fires the package name each time a guarded app is opened.
  ///
  /// Errors (e.g. the native channel not registered yet) are swallowed so a
  /// missing plugin never crashes the app — the stream simply stays quiet.
  Stream<String> get triggers {
    if (!isNativelySupported) return const Stream<String>.empty();
    return _events
        .receiveBroadcastStream()
        .map((e) => e as String)
        .where((e) => e.isNotEmpty)
        .handleError((_) {});
  }

  Future<bool> hasPermissions() async {
    if (!isNativelySupported) return false;
    try {
      return await _method.invokeMethod<bool>('hasPermissions') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the relevant system settings page (accessibility / overlay on
  /// Android, Screen Time authorization / Shortcuts guide on iOS).
  Future<void> requestPermissions() async {
    if (!isNativelySupported) return;
    try {
      await _method.invokeMethod('requestPermissions');
    } catch (_) {
      // ignore — the settings screen surfaces the real state
    }
  }

  /// Push the current guard config down to the native service.
  Future<void> syncGuardedPackages(Set<String> packages) async {
    if (!isNativelySupported) return;
    try {
      await _method.invokeMethod('syncGuarded', {'packages': packages.toList()});
    } catch (_) {
      // ignore — native side may not be wired up yet
    }
  }

  /// Ask the native side to send the user home (Android GLOBAL_ACTION_HOME).
  Future<void> goHome() async {
    if (!isNativelySupported) return;
    try {
      await _method.invokeMethod('goHome');
    } catch (_) {
      // ignore
    }
  }
}
