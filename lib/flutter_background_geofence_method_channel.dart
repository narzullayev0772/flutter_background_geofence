import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geofence_core/flutter_background_geofence.dart';

import 'flutter_background_geofence_platform_interface.dart';
import 'src/core/callback_dispatcher.dart';

/// An implementation of [FlutterBackgroundGeofencePlatform] that uses method channels.
class MethodChannelFlutterBackgroundGeofence extends FlutterBackgroundGeofencePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final channel = const MethodChannel(PluginConstants.channelName);

  @override
  Future<String?> getPlatformVersion() async =>
      await channel.invokeMethod<String>('getPlatformVersion');

  @override
  Future<bool> initialise() async {
    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    final result = await channel.invokeMethod(
      PluginConstants.initialiseServiceMethod,
      <dynamic>[callback?.toRawHandle()],
    );
    return result ?? false;
  }

  @override
  Future<bool> registerGeofence({
    required GeofenceRegionBase region,
    required GeofenceCallback callback,
  }) async {
    final isIos = !kIsWeb && Platform.isIOS;
    if (isIos && region.triggers.contains(GeofenceEvent.dwell) && (region.triggers.length == 1)) {
      throw UnsupportedError("iOS does not support 'GeofenceEvent.dwell'");
    }
    final args = <dynamic>[
      PluginUtilities.getCallbackHandle(callback)?.toRawHandle(),
      ...region.toArgs,
    ];
    final result = await channel.invokeMethod<bool>(
      PluginConstants.registerGeofenceMethod,
      args,
    );
    return result ?? false;
  }

  @override
  Future<bool> removeGeofence(GeofenceRegionBase region) {
    // TODO: implement removeGeofence
    throw UnimplementedError();
  }

  @override
  Future<bool> removeGeofenceById(String id) async {
    final result = await channel.invokeMethod<bool>(
      PluginConstants.removeGeofenceByIdMethod,
      <dynamic>[id],
    );
    return result ?? false;
  }
}
