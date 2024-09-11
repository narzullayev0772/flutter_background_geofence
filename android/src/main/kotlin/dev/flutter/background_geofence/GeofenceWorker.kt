package dev.flutter.background_geofence

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.core.app.JobIntentService
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.android.gms.location.GeofencingEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

class GeofenceWorker(
    context: Context,
    params: WorkerParameters,
): MethodChannel.MethodCallHandler, Worker(context, params) {
    private val queue = ArrayDeque<List<Any>>()
    /// The channel used for communication.
    ///
    /// This is the background channel used, since this service should be running in the background.
    private lateinit var channel: MethodChannel

    companion object {
        @JvmStatic
        private val serviceStarted = AtomicBoolean(false)
        @JvmStatic
        private var flutterEngine: FlutterEngine? = null
    }

    override fun doWork(): Result {
        val context = applicationContext
        FlutterMain.startInitialization(context)
        FlutterMain.ensureInitializationComplete(context, null)
        var result = Result.success()
        Handler(context.mainLooper).post {
            startGeofencingService(context)
            try {
                val geofenceUpdateList = listOf(
                    inputData.getLong("callbackHandle", 0L),
                    inputData.getStringArray("triggeringGeofences")!!.toList(),
                    inputData.getDoubleArray("locationList")!!.toList(),
                    inputData.getInt("geofenceTransition", 0)
                )
                synchronized(serviceStarted) {
                    if (!serviceStarted.get()) {
                        Logger.w("Service is not started")
                        // Queue up geofencing events while background isolate is starting
                        Logger.i("Queuing up geofence event: $geofenceUpdateList")
                        queue.addLast(geofenceUpdateList)
                    } else {
                        Logger.i("Sending event $geofenceUpdateList")
                        // Callback method name is intentionally left blank.
                        channel.invokeMethod("", geofenceUpdateList)

                    }
                }
            } catch (e: Exception) {
                Logger.e(e.message ?: e.toString())
                Logger.e(e.stackTraceToString())
                result = Result.failure()
            }
        }
        return result
    }

        override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Logger.i("Call received for method: ${call.method}")
        when (call.method) {
            PluginConstants.pluginInitialisedMethod -> {
                synchronized(serviceStarted) {
                    // Dispatch any geofencing events that were handled before the
                    // callback dispatcher was ready.
                    while (queue.isNotEmpty()) {
                        channel.invokeMethod("", queue.removeFirst())
                    }
                    serviceStarted.set(true)
                    result.success(null)
                }
            }

            else -> {
                Logger.e("Unimplemented method")
                result.notImplemented()
            }
        }
    }

    private fun startGeofencingService(context: Context) {
        Logger.i("startGeofencingService was called")
        // Synchronize on sServiceStarted to avoid multiple concurrent
        // initializations.
        synchronized(serviceStarted) {
            // If we don't have an existing background FlutterNativeView,
            // we need to create one and have it initialize our callback
            // dispatcher.
            if (flutterEngine == null) {
                flutterEngine = FlutterEngine(context)
                // Grab the callback handle for the callback dispatcher from
                // storage.
                val callbackDispatcherHandle = PluginPreferences(context).callbackDispatcherHandle()
                if (callbackDispatcherHandle == 0L) {
                    Logger.e("Fatal: no callback registered")
                    return
                }
                // Retrieve the actual callback information needed to invoke it.
                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackDispatcherHandle)
                if (callbackInfo == null) {
                    Logger.e("Fatal: failed to find callback")
                    return
                }

                val args = DartExecutor.DartCallback(
                    context.assets,
                    FlutterMain.findAppBundlePath(context)!!,
                    callbackInfo
                )

                // Start running callback dispatcher code in our background FlutterEngine instance.
                flutterEngine!!.dartExecutor.executeDartCallback(args)
                Logger.i("Finished starting up flutter engine")
            }
        }
        /// Create the channel used to communicate between the callback dispatcher and this instance.
        channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, PluginConstants.backgroundChannelName)
        channel.setMethodCallHandler(this)
    }
}