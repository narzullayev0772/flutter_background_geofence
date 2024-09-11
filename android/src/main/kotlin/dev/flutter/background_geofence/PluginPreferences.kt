package dev.flutter.background_geofence

import android.content.Context

/// Manage the cached data for the plugin using shared preferences
class PluginPreferences(private var context: Context) {
    companion object {
        @JvmStatic
        val PREFERENCES_KEY = "flutter_background_geofence_cache"
        @JvmStatic
        val CALLBACK_HANDLE = "callback_handle"
        @JvmStatic
        val CALLBACK_DISPATCHER_HANDLE = "callback_dispatcher_handle"

    }

    /// Get the instance of shared preferences
    private fun preferences() = context.getSharedPreferences(PREFERENCES_KEY, Context.MODE_PRIVATE)

    /// Store the callback dispatcher handle key
    fun putCallbackDispatcherHandle(value: Long) = preferences().edit().putLong(
        CALLBACK_DISPATCHER_HANDLE,
        value
    ).apply()

    /// Get the callback dispatcher handle key from cache.
    fun callbackDispatcherHandle(): Long = preferences().getLong(CALLBACK_DISPATCHER_HANDLE, 0)
}