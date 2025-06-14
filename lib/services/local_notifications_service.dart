import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  static int _notificationsCounter = 0;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init() async {
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permission on Android 13+
    if (!kIsWeb && Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? subTitle,
  }) async {
    // print for debug
    // print('showNotification called: title=\"$title\", body=\"$body\"');
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channelId',
      'Local Notification',
      channelDescription: 'This is a channel for local notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: subTitle,
      threadIdentifier: 'thread_id',
    );
    await flutterLocalNotificationsPlugin.show(
      _notificationsCounter++,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
