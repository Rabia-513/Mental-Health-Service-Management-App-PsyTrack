import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class FCMService {

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {

    /// Ask notification permission
    await _messaging.requestPermission();

    /// Get device token
    String? token = await _messaging.getToken();
    debugPrint("FCM TOKEN: $token");

    /// Initialize local notification
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidInit);

    await _local.initialize(settings);

    /// Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'fyp_notifications',
        'FYP Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

      await _local.show(
        0,
        message.notification?.title ?? "Notification",
        message.notification?.body ?? "",
        notificationDetails,
      );
    });
  }
}