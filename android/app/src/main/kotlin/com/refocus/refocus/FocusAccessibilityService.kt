package com.refocus.refocus

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent

/**
 * Watches which app comes to the foreground and, when it's one of the guarded
 * packages, sends the user home, brings Refocus forward, and tells Flutter to
 * show the pause screen.
 *
 * Android half of the report's "Application Monitoring Module" — the same
 * TYPE_WINDOW_STATE_CHANGED mechanism, no root.
 */
class FocusAccessibilityService : AccessibilityService() {

    companion object {
        /** Packages the user chose to guard, pushed down from Flutter. */
        @Volatile
        var guardedPackages: Set<String> = emptySet()

        /** Set while the service is connected so MainActivity can call goHome. */
        @Volatile
        private var instance: FocusAccessibilityService? = null

        /** Sink into Flutter; set by MainActivity's EventChannel handler. */
        @Volatile
        var emit: ((String) -> Unit)? = null

        fun goHomeNow() {
            instance?.performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    private val main = Handler(Looper.getMainLooper())
    private var lastPackage: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return

        // Ignore our own UI and repeated events for the same window.
        if (pkg == packageName || pkg == lastPackage) return
        lastPackage = pkg

        if (guardedPackages.contains(pkg)) {
            // Home first, so the feed never really loads.
            performGlobalAction(GLOBAL_ACTION_HOME)

            // Bring Refocus to the front so it can present the pause screen.
            val launch = packageManager.getLaunchIntentForPackage(packageName)
            if (launch != null) {
                launch.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                )
                launch.putExtra("triggered_package", pkg)
                startActivity(launch)
            }

            main.post { emit?.invoke(pkg) }
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) instance = null
    }
}
