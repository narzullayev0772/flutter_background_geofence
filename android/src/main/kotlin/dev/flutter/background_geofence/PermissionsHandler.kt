package dev.flutter.background_geofence

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat

class PermissionsHandler: ActivityCompat.OnRequestPermissionsResultCallback {
    companion object {
        fun requestPermissions(activity: Activity) {
            throw NotImplementedError()
        }

        /// Check if the plugin has the required permissions
        ///
        /// For SDKs older than version 23, it will return true.
        fun hasPermissions(context: Context): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_DENIED
            } else {
                true
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        TODO("Not yet implemented")
    }
}