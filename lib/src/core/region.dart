import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_geofence/android.dart';
import 'package:flutter_background_geofence_core/classes.dart';

class GeofenceRegion extends GeofenceRegionBase {
  /// Android-specific settings for a geofence.
  final AndroidGeofenceSettings androidSettings;

  @override
  List<dynamic> get toArgs => [
        id,
        coordinates.latitude,
        coordinates.longitude,
        radius,
        triggers.fold(0, (trigger, event) => (event.id | trigger)),
        if (!kIsWeb && Platform.isAndroid) ...androidSettings.toArgs
      ];

  const GeofenceRegion({
    required super.id,
    required super.coordinates,
    required super.radius,
    required super.triggers,
    this.androidSettings = const AndroidGeofenceSettings(),
  });

  @override
  String toString() =>
      "GeofenceRegion(id: $id, coordinates: $coordinates, radius: $radius, triggers: $triggers, androidSettings: $androidSettings)";
}
