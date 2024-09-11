import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_geofence/flutter_background_geofence.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationTile extends StatefulWidget {
  final ValueChanged<GeoLatLon>? onChanged;

  const CurrentLocationTile({super.key, this.onChanged});

  @override
  State<CurrentLocationTile> createState() => _CurrentLocationTileState();
}

class _CurrentLocationTileState extends State<CurrentLocationTile> {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );
  late final ValueNotifier<GeoLatLon?> _locationNotifier;
  late final StreamSubscription<GeoLatLon> _positionSubscription;

  GeoLatLon? get _location => _locationNotifier.value;

  @override
  void initState() {
    super.initState();
    _locationNotifier = ValueNotifier(null)..addListener(_locationValueChanged);

    /// Geolocator.getLastKnownPosition().then(
    ///   (value) => (value != null)
    ///       ? _locationNotifier.value = GeoLatLon(value.latitude, value.longitude)
    ///       : null,
    /// );
    _positionSubscription = Geolocator.getPositionStream(locationSettings: _locationSettings)
        .map((event) => GeoLatLon(event.latitude, event.longitude))
        .listen(_onLocationChanged);
  }

  @override
  Future<void> dispose() async {
    await _positionSubscription.cancel();
    _locationNotifier.removeListener(_locationValueChanged);
    _locationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: _locationNotifier,
        builder: (context, value, child) => ListTile(
          title: Text(
            (value != null)
                ? "Current location: ${value.latitude}, ${value.longitude}"
                : "No location",
          ),
        ),
      );

  void _onLocationChanged(GeoLatLon position) {
    print("Location changed: $position");
    _locationNotifier.value = position;
  }

  void _locationValueChanged() => (_location != null) ? widget.onChanged?.call(_location!) : null;
}
