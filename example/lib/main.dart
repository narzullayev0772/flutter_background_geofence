import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geofence/flutter_background_geofence.dart';
import 'package:flutter_background_geofence_example/current_location.dart';
import 'package:flutter_background_geofence_example/geofence_slider.dart';
import 'package:flutter_background_geofence_example/permissions_handler_builder.dart';

import 'geofence_location_tile.dart';
import 'notifications_manager.dart';

Future<void> _initDependencies() async {
  await FlutterBackgroundGeofence().initialise();
  NotificationsManager()
      .initialiseSettings()
      .then((value) => log("Notifications initialised: $value"));
}

@pragma('vm:entry-point')
void geofenceCallback(List<String> ids, GeoLatLon coordinates, GeofenceEvent event) async {
  log("Geofence triggered: $ids, $coordinates, $event");
  WidgetsFlutterBinding.ensureInitialized();

  NotificationsManager().showNotification(
    title: "New geofence: $event",
    body: "The geofence was triggered at $coordinates, for the following geofences: $ids",
  );

  /// final SendPort send = IsolateNameServer.lookupPortByName('geofencing_send_port');
  /// send?.send(e.toString());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<String> _platformFuture;
  late final FlutterBackgroundGeofence _plugin;
  late final ValueNotifier<GeoLatLon?> _currentLocationNotifier;
  late final ValueNotifier<GeoLatLon?> _geofenceLocationNotifier;
  late final ValueNotifier<int> _radiusNotifier;

  @override
  void initState() {
    super.initState();
    _plugin = FlutterBackgroundGeofence();
    _currentLocationNotifier = ValueNotifier(null);
    _geofenceLocationNotifier = ValueNotifier(null);
    _radiusNotifier = ValueNotifier(10);
    _platformFuture = _platformVersion();
  }

  @override
  void dispose() {
    _radiusNotifier.dispose();
    _currentLocationNotifier.dispose();
    _geofenceLocationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: _Platform(platformFuture: _platformFuture),
          ),
          body: SafeArea(
            top: false,
            child: PermissionsHandlerBuilder(
              builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrentLocationTile(
                    onChanged: (value) => _currentLocationNotifier.value = value,
                  ),
                  ValueListenableBuilder(
                    valueListenable: _geofenceLocationNotifier,
                    builder: (context, value, child) => ValueListenableBuilder(
                      valueListenable: _currentLocationNotifier,
                      builder: (context, currentLocation, child) => GeofenceLocationTile(
                        value: value,
                        currentLocation: currentLocation,
                      ),
                    ),
                  ),
                  GeofenceSlider(
                    valueListenable: _radiusNotifier,
                    titlePrefix: "Radius",
                    titleSuffix: "m",
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: _currentLocationNotifier,
                    builder: (context, value, child) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _registerGeofence(value),
                        child: const Text("Register geofence"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> _registerGeofence(GeoLatLon? coordinates) async {
    if (coordinates == null) {
      log("No coordinates available", level: 1000);
      return;
    }
    await _plugin.removeGeofenceById("test_region");
    _plugin.registerGeofence(
      region: GeofenceRegion(
        id: "test_region",
        coordinates: coordinates,
        radius: _radiusNotifier.value.toDouble(),
        triggers: [GeofenceEvent.dwell, GeofenceEvent.enter, GeofenceEvent.exit],
        androidSettings: const AndroidGeofenceSettings(
          loiteringDelay: 10000,
          notificationResponsiveness: 10000,
        ),
      ),
      callback: geofenceCallback,
    );
    _geofenceLocationNotifier.value = coordinates;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<String> _platformVersion() async {
    try {
      return await _plugin.getPlatformVersion() ?? "Unknown platform version";
    } on PlatformException {
      return "Failed to get platform version.";
    }
  }
}

class _Platform extends StatelessWidget {
  final Future<String> platformFuture;

  const _Platform({required this.platformFuture});

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: platformFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return Text("Goefence on: ${snapshot.data}");
        },
      );
}
