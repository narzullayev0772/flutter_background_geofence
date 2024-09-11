import 'package:flutter/material.dart';
import 'package:flutter_background_geofence/flutter_background_geofence.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';

class GeofenceLocationTile extends StatelessWidget {
  final GeoLatLon? value;
  final GeoLatLon? currentLocation;

  double? get _distance {
    if (value == null || currentLocation == null) {
      return null;
    }
    return FlutterMapMath().distanceBetween(
      value!.latitude,
      value!.longitude,
      currentLocation!.latitude,
      currentLocation!.longitude,
      "meters",
    );
  }

  const GeofenceLocationTile({super.key, this.value, this.currentLocation});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          (value != null)
              ? "Geofence location: ${value!.latitude}, ${value!.longitude}"
              : "Geofence not registered",
        ),
        subtitle: Text("Distance: ${_distance?.toStringAsFixed(2) ?? "n/a"} meters"),
      );
}
