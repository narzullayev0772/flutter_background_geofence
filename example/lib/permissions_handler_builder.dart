import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_geofence/permission_handler.dart';

class PermissionsHandlerBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  const PermissionsHandlerBuilder({super.key, required this.builder});

  @override
  State<PermissionsHandlerBuilder> createState() => _PermissionsHandlerBuilderState();
}

class _PermissionsHandlerBuilderState extends State<PermissionsHandlerBuilder> {
  late final ValueNotifier<bool?> _serviceEnabledNotifier;
  late final ValueNotifier<bool?> _permissionGrantedNotifier;

  bool get _serviceEnabled => _serviceEnabledNotifier.value ?? false;

  @override
  void initState() {
    super.initState();
    _serviceEnabledNotifier = ValueNotifier<bool?>(null);
    _permissionGrantedNotifier = ValueNotifier<bool?>(null);
    _checkService();
  }

  @override
  void dispose() {
    _serviceEnabledNotifier.dispose();
    _permissionGrantedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool?>(
        valueListenable: _serviceEnabledNotifier,
        builder: (context, value, child) {
          if (value == null) return const Center(child: CircularProgressIndicator());
          if (!value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Location is disabled"),
                  ElevatedButton(
                    onPressed: _checkService,
                    child: const Text("Check service"),
                  ),
                ],
              ),
            );
          }
          return ValueListenableBuilder<bool?>(
            valueListenable: _permissionGrantedNotifier,
            builder: (context, value, child) {
              if (value == null) return const Center(child: CircularProgressIndicator());
              if (!value) {
                return Center(
                  child: ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text("Request permissions"),
                  ),
                );
              }
              return widget.builder(context);
            },
          );
        },
      );

  Future<void> _checkService() async {
    _serviceEnabledNotifier.value = await Permission.location.serviceStatus.isEnabled;
    if (_serviceEnabled) _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();
    final values = statuses.values;
    print("Permissions: $values");
    if (values.any((element) => element.isPermanentlyDenied)) {
      openAppSettings();
      _permissionGrantedNotifier.value = false;
    } else {
      _permissionGrantedNotifier.value = values.every((element) => element.isGranted);
    }
  }
}
