package dev.flutter.background_geofence

import android.util.Log

class Logger {
    companion object {
        private const val TAG = "BackgroundGeofence"
        fun i(msg: String) = Log.i(TAG, msg)
        fun d(msg: String) = Log.d(TAG, msg)
        fun w(msg: String) = Log.w(TAG, msg)
        fun e(msg: String) = Log.e(TAG, msg)
    }
}