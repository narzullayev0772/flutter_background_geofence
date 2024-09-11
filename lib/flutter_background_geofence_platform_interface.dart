import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_background_geofence_core/flutter_background_geofence.dart';

import 'flutter_background_geofence_method_channel.dart';

abstract class FlutterBackgroundGeofencePlatform extends PlatformInterface
    implements BackgroundGeofencePlugin {
  /// Constructs a FlutterBackgroundGeofencePlatform.
  FlutterBackgroundGeofencePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBackgroundGeofencePlatform _instance = MethodChannelFlutterBackgroundGeofence();

  /// The default instance of [FlutterBackgroundGeofencePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBackgroundGeofence].
  static FlutterBackgroundGeofencePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBackgroundGeofencePlatform] when
  /// they register themselves.
  static set instance(FlutterBackgroundGeofencePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() =>
      throw UnimplementedError("platformVersion() has not been implemented.");
}
