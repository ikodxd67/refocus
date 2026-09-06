package com.refocus.refocus

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import android.os.Process

/**
 * Reads real per-app foreground time from the platform.
 *
 * This is what turns the pause screen's "cost mirror" and the daily charts from
 * guesses into measurements. Access is a special permission the user grants in
 * Settings -> Usage access; we never read anything but package names and
 * durations.
 */
class UsageStatsReader(private val context: Context) {

    /** Whether the user has granted usage access. */
    fun hasAccess(): Boolean {
        val appOps =
            context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Foreground minutes per package between [startMs] and [endMs].
     *
     * Uses the aggregating query rather than raw daily buckets, which can
     * overlap the requested window and double-count.
     */
    fun minutesBetween(startMs: Long, endMs: Long): Map<String, Int> {
        if (!hasAccess()) return emptyMap()

        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE)
            as UsageStatsManager
        val aggregated = usm.queryAndAggregateUsageStats(startMs, endMs)

        val out = HashMap<String, Int>()
        for ((pkg, stats) in aggregated) {
            val minutes = (stats.totalTimeInForeground / 60_000L).toInt()
            if (minutes > 0) out[pkg] = minutes
        }
        return out
    }
}
