// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter_background_geofence_core/flutter_background_geofence.dart';

import 'flutter_background_geofence_platform_interface.dart';

export 'package:flutter_background_geofence_core/flutter_background_geofence.dart';
export 'core.dart';
export 'android.dart';

class FlutterBackgroundGeofence implements BackgroundGeofencePlugin {
  FlutterBackgroundGeofencePlatform? __plugin;
  FlutterBackgroundGeofencePlatform get _plugin =>
      __plugin ??= FlutterBackgroundGeofencePlatform.instance;
  static FlutterBackgroundGeofence? _instance;
  FlutterBackgroundGeofence._();
  factory FlutterBackgroundGeofence() => _instance ??= FlutterBackgroundGeofence._();

  Future<String?> getPlatformVersion() => _plugin.getPlatformVersion();

  @override
  Future<bool> initialise() => _plugin.initialise();

  @override
  Future<bool> registerGeofence({
    required GeofenceRegionBase region,
    required GeofenceCallback callback,
  }) =>
      _plugin.registerGeofence(region: region, callback: callback);

  @override
  Future<bool> removeGeofence(GeofenceRegionBase region) => _plugin.removeGeofence(region);

  @override
  Future<bool> removeGeofenceById(String id) => _plugin.removeGeofenceById(id);
}
