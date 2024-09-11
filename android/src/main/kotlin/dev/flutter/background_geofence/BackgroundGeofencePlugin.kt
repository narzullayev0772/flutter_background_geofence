package dev.flutter.background_geofence

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** BackgroundGeofencePlugin */
class BackgroundGeofencePlugin: ActivityAware, FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  /// The main application context
  private var context: Context? = null

  /// The current application activity
  private var activity: Activity? = null

  /// The geofencing client used to manage the geofences
  private var geofencingClient: GeofencingClient? = null

  /// Class used to manage cache using shared preferences
  private var cache: PluginPreferences? = null

  /// Initialise service related stuff here
  ///
  /// It will first, request the permissions required by the plugin then store the callback
  /// dispatcher's handle in the cache.
  private fun initialiseService(args: ArrayList<*>?, result: MethodChannel.Result?,) {
    Logger.d("Initializing GeofencingService")
    cache?.putCallbackDispatcherHandle(args!![0] as Long)
    result?.success(true)
  }

  private fun registerGeofence(
    args: ArrayList<*>?,
    result: MethodChannel.Result?,
  ) {
    Logger.i("Received the following list of arguments: $args")
    val callbackHandle = args!![0] as Long
    val id = args[1] as String
    val lat = args[2] as Double
    val long = args[3] as Double
    val radius = (args[4] as Number).toFloat()
    val fenceTriggers = args[5] as Int
    val initialTrigger = args[6] as Int
    val loiteringDelay = args[7] as Int
    val expirationDuration = (args[8] as Int).toLong()
    val notificationResponsiveness = args[9] as Int
    val geofence = Geofence.Builder()
      .setRequestId(id)
      .setCircularRegion(lat, long, radius)
      .setTransitionTypes(fenceTriggers)
      .setLoiteringDelay(loiteringDelay)
      .setNotificationResponsiveness(notificationResponsiveness)
      .setExpirationDuration(expirationDuration)
      .build()
    geofencingClient!!.addGeofences(
      getGeofencingRequest(geofence, initialTrigger),
      getGeofencePendingIndent(context!!, callbackHandle, id)
    ).run {
      addOnSuccessListener {
        Logger.i("Successfully added geofence")
        result?.success(true)
      }
      addOnFailureListener {
        Logger.e("Failed to add geofence: $it")
        result?.error(it.toString(), null, null)
      }
    }
  }

  private fun getGeofencingRequest(geofence: Geofence, initialTrigger: Int): GeofencingRequest = GeofencingRequest.Builder().apply {
    setInitialTrigger(initialTrigger)
    addGeofence(geofence)
  }.build()

  private fun getGeofencePendingIndent(context: Context, callbackHandle: Long, geofenceId: String): PendingIntent {
    val intent = Intent(context, GeofenceBroadcastReceiver::class.java)
      .putExtra(PluginPreferences.CALLBACK_HANDLE, callbackHandle)
      .putExtra("geofenceId", geofenceId)
    return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
  }

  private fun removeGeofenceById(
    args: ArrayList<*>,
    result: MethodChannel.Result?,
  ) {
    val geofenceId = args[0] as String
    geofencingClient?.removeGeofences(listOf(geofenceId))?.run {
      addOnSuccessListener {
        Logger.i("Successfully removed geofence: $geofenceId")
        result?.success(true)
      }
      addOnFailureListener {
        Logger.e("Failed to add geofence: $it")
        result?.error("99", it.message ?: it.toString(), it)
      }
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val method = call.method
    val args = call.arguments<ArrayList<*>>()
    when (method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      PluginConstants.initialiseServiceMethod -> initialiseService(args, result)
      PluginConstants.registerGeofenceMethod -> registerGeofence(args, result)
      PluginConstants.removeGeofenceByIdMethod -> removeGeofenceById(args!!, result)
      else -> result.notImplemented()
    }
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    geofencingClient = LocationServices.getGeofencingClient(context!!)
    cache = PluginPreferences(context!!)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, PluginConstants.channelName)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
    geofencingClient = null
    cache = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
