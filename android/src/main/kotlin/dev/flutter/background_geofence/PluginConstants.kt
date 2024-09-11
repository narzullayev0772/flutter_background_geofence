package dev.flutter.background_geofence

class PluginConstants {
    companion object {
        const val channelName: String = "FlutterBackgroundGeofence";
        const val backgroundChannelName = "FlutterBackgroundGeofenceBackground";
        const val initialiseServiceMethod = "$channelName.initialiseService";
        const val registerGeofenceMethod = "$channelName.registerGeofence";
        const val removeGeofenceMethod = "$channelName.removeGeofence";
        const val removeGeofenceByIdMethod = "$channelName.removeGeofenceById";
        const val pluginInitialisedMethod = "$channelName.pluginInitialised";
    }
}