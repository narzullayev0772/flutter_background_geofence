package dev.flutter.background_geofence

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import com.google.android.gms.location.GeofencingEvent
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.view.FlutterMain
import java.util.UUID

class GeofenceBroadcastReceiver : BroadcastReceiver() {
    companion object {
        @JvmStatic
        private val loader = FlutterLoader()
    }
    override fun onReceive(context: Context, intent: Intent) {
        Logger.i("GeofenceBroadcastReceiver.onReceive intent: $intent")
        // Retrieve the callback handle associated with the triggered geofence.
        val callbackHandle = intent.getLongExtra(PluginPreferences.CALLBACK_HANDLE, 0)
        // Parse the GeofencingEvent from the Intent.
        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent == null || geofencingEvent.hasError()) {
            Logger.e("Geofencing error: ${geofencingEvent?.errorCode}")
            return
        }

        // Get the geofence transition type (e.g., enter, dwell, exit).
        val geofenceTransition = geofencingEvent.geofenceTransition

        // Get the geofences that were triggered. A single event can trigger
        // multiple geofences.
        val triggeringGeofences = geofencingEvent.triggeringGeofences!!.map { it.requestId }.toTypedArray()

        val location = geofencingEvent.triggeringLocation
        val locationList = arrayOf(location!!.latitude, location.longitude).toDoubleArray()
        val data = Data.Builder()
            .putLong("callbackHandle", callbackHandle)
            .putStringArray("triggeringGeofences", triggeringGeofences)
            .putDoubleArray("locationList", locationList)
            .putInt("geofenceTransition", geofenceTransition)
            .build()

        val request =  OneTimeWorkRequest.Builder(GeofenceWorker::class.java)
            .setId(UUID.randomUUID())
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setInputData(data)
            .build()
        WorkManager.getInstance(context).enqueue(request)
    }

//    override fun onReceive(context: Context, intent: Intent) {
//        Logger.i("GeofenceBroadcastReceiver.onReceive intent: $intent")
//        FlutterMain.startInitialization(context)
//        FlutterMain.ensureInitializationComplete(context, null)
//        GeofenceService.enqueueWork(context, intent)
//    }
}