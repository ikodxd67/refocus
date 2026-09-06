package com.refocus.refocus

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Registers the two channels the Dart side (interception_channel.dart) talks to:
 *   method channel  "refocus/interception"         -> permissions, sync, goHome
 *   event  channel  "refocus/interception/events"  -> guarded app opened
 */
class MainActivity : FlutterActivity() {

    private val methodName = "refocus/interception"
    private val eventName = "refocus/interception/events"
    private val usageName = "refocus/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        val usage = UsageStatsReader(applicationContext)
        MethodChannel(messenger, usageName).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageAccess" -> result.success(usage.hasAccess())
                "requestUsageAccess" -> {
                    startActivity(
                        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    )
                    result.success(null)
                }
                "minutesBetween" -> {
                    val start = call.argument<Long>("start")
                    val end = call.argument<Long>("end")
                    if (start == null || end == null) {
                        result.error("bad_args", "start and end are required", null)
                    } else {
                        result.success(usage.minutesBetween(start, end))
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, methodName).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermissions" -> result.success(isAccessibilityEnabled())
                "requestPermissions" -> {
                    startActivity(
                        Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    )
                    result.success(null)
                }
                "syncGuarded" -> {
                    val list = call.argument<List<String>>("packages") ?: emptyList()
                    FocusAccessibilityService.guardedPackages = list.toSet()
                    result.success(null)
                }
                "goHome" -> {
                    FocusAccessibilityService.goHomeNow()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, eventName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                    FocusAccessibilityService.emit = { pkg -> sink?.success(pkg) }
                }

                override fun onCancel(args: Any?) {
                    FocusAccessibilityService.emit = null
                }
            }
        )
    }

    private fun isAccessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return enabled.contains("$packageName/.FocusAccessibilityService")
    }
}
