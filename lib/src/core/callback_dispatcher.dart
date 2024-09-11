import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_geofence_core/classes.dart';
import 'package:flutter_background_geofence_core/core.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const channel = MethodChannel(PluginConstants.backgroundChannelName);

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  channel.setMethodCallHandler((call) async {
    final args = call.arguments;

    // 3.1. Retrieve callback instance for handle.
    final callback = PluginUtilities.getCallbackFromHandle(CallbackHandle.fromRawHandle(args[0]));
    assert(callback != null);

    // 3.2. Preprocess arguments.
    final triggeringGeofences = (args[1] as List<dynamic>).map((e) => e as String).toList();
    final locationList = args[2].cast<double>();
    final triggeringLocation = GeoLatLon.fromList(locationList);
    final event = GeofenceEvent.fromId(args[3] as int);
    assert(event != null);

    // 3.3. Invoke callback.
    callback!(triggeringGeofences, triggeringLocation, event);
  });

  // 4. Alert plugin that the callback handler is ready for events.
  channel.invokeMethod(PluginConstants.pluginInitialisedMethod);
  print("Callback dispatcher ready!");
}
