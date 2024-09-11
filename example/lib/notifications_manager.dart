import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsManager {
  /// Android Notification Channel info
  static const _androidChannel = AndroidNotificationChannel(
    "background_geofence_example_notifications",
    "Background Geofence Example Notifications",
    description: "Notifications used by the background geofence example app",
    importance: Importance.max,
  );
  static FlutterLocalNotificationsPlugin? __plugin;
  static FlutterLocalNotificationsPlugin get _plugin =>
      __plugin ??= FlutterLocalNotificationsPlugin();
  static NotificationsManager? _instance;
  static InitializationSettings? _initializationSettings;

  /// Getter to retrieve notifications details specifically for Android required to show notifications
  AndroidNotificationDetails get _androidPlatformChannelSpecifics => AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        groupKey: _androidChannel.groupId,
        importance: _androidChannel.importance,
        priority: Priority.max,
      );

  /// Getter to retrieve notifications details required to show notifications
  /// in a cross-platform manner
  NotificationDetails get _platformSpecificsDetails => NotificationDetails(
        android: _androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(threadIdentifier: _androidChannel.id),
      );

  NotificationsManager._();
  factory NotificationsManager() => _instance ??= NotificationsManager._();

  Future<bool> initialiseSettings() async {
    if (kIsWeb) return false;
    if (_initializationSettings != null) return true;
    if (Platform.isIOS && !(await _checkIOSPermissions())) return false;

    _initializationSettings = const InitializationSettings(
      android: AndroidInitializationSettings("ic_launcher"),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    final result = await _plugin.initialize(
      _initializationSettings!,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);
      await androidPlugin?.requestNotificationsPermission();
    }
    return result ?? false;
  }

  /// Show a notification while the app is in foreground.
  ///
  /// FCM does not have capibility of doing this so we need to do it with the
  /// flutter_local_notifications package: https://pub.dev/packages/flutter_local_notifications.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) =>
      _plugin.show(
        payload.hashCode,
        title,
        body,
        _platformSpecificsDetails,
        payload: payload,
      );

  /// The correct way of checking permissions on IOS, to avoid asking for permissions multiple times.
  Future<bool> _checkIOSPermissions() async =>
      await (_plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )) ??
      false;
}
