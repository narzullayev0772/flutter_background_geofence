import 'package:flutter_background_geofence/flutter_background_geofence.dart';
import 'package:flutter_background_geofence/flutter_background_geofence_method_channel.dart';
import 'package:flutter_background_geofence/flutter_background_geofence_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBackgroundGeofencePlatform
    with MockPlatformInterfaceMixin
    implements FlutterBackgroundGeofencePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> initialise() => throw UnimplementedError();

  @override
  Future<bool> registerGeofence({
    required GeofenceRegionBase region,
    required GeofenceCallback callback,
  }) =>
      throw UnimplementedError();

  @override
  Future<bool> removeGeofence(GeofenceRegionBase region) => throw UnimplementedError();

  @override
  Future<bool> removeGeofenceById(String id) => throw UnimplementedError();
}

void main() {
  final FlutterBackgroundGeofencePlatform initialPlatform =
      FlutterBackgroundGeofencePlatform.instance;

  test('$MethodChannelFlutterBackgroundGeofence is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBackgroundGeofence>());
  });

  test('getPlatformVersion', () async {
    FlutterBackgroundGeofence flutterBackgroundGeofencePlugin = FlutterBackgroundGeofence();
    MockFlutterBackgroundGeofencePlatform fakePlatform = MockFlutterBackgroundGeofencePlatform();
    FlutterBackgroundGeofencePlatform.instance = fakePlatform;

    expect(await flutterBackgroundGeofencePlugin.getPlatformVersion(), '42');
  });
}
