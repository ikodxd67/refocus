package com.refocus.refocus // <-- match your applicationId after `flutter create`

import android.accessibilityservice.AccessibilityService
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent

/**
 * Watches which app comes to the foreground and, when it's one of the guarded
 * packages, pushes the package name up to Flutter over the EventChannel.
 *
 * This is the Android half of the "Application Monitoring Module" from the
 * research report — the same TYPE_WINDOW_STATE_CHANGED mechanism, no root.
 *
 * Wiring (see MainActivity.kt):
 *  - Flutter calls `syncGuarded` -> updates [guardedPackages].
 *  - This service emits the package -> Flutter shows the pause screen.
 *  - Flutter calls `goHome` -> [goHomeNow].
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
            // Send the user home immediately so the feed never really loads,
            // then let Flutter present the pause over our own window.
            performGlobalAction(GLOBAL_ACTION_HOME)
            main.post { emit?.invoke(pkg) }
        }
    }

    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) instance = null
    }
}
