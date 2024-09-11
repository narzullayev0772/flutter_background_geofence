import 'package:flutter_background_geofence_core/core.dart';

/// Geofence settings used for Android.
class AndroidGeofenceSettings {
  final GeofenceEvent initialTrigger;
  final int expirationDuration;
  final int loiteringDelay;
  final int notificationResponsiveness;

  List<dynamic> get toArgs => [
        initialTrigger.id,
        loiteringDelay,
        expirationDuration,
        notificationResponsiveness,
      ];

  const AndroidGeofenceSettings({
    this.initialTrigger = GeofenceEvent.enter,
    this.loiteringDelay = 0,
    this.expirationDuration = -1,
    this.notificationResponsiveness = 0,
  });

  @override
  String toString() =>
      "AndroidGeofenceSettings(initialTrigger: $initialTrigger, loiteringDelay: $loiteringDelay, expirationDuration: $expirationDuration, notificationResponsiveness: $notificationResponsiveness)";
}
