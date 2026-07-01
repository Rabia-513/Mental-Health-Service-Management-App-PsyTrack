import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalService {

  static Future<void> sendNotification({
    required String externalId,
    required String title,
    required String body,
  }) async {

    await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "YOUR_ONESIGNAL_REST_API_KEY",      },
      body: jsonEncode({
        "app_id": "8aaeca44-3d52-4e84-96de-fc8bb54f1e32",
        "include_external_user_ids": [externalId],
        "headings": {"en": title},
        "contents": {"en": body},


        /// 🔥 MAKE IT LOOK PREMIUM
        "small_icon": "ic_launcher",

        /// 🔥 OPTIONAL BIG STYLE
        "android_style": "bigtext",

        /// 🔥 GROUPING
        "android_group": "appointments",

        /// 🔥 PRIORITY
        "priority": 10,
      }),
    );
  }
  static Future<void> sendScheduledNotification({
    required List<String> externalIds,
    required String title,
    required String body,
    required DateTime sendAt,
  }) async {
    await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "YOUR_ONESIGNAL_REST_API_KEY",      },
      body: jsonEncode({
        "app_id": "8aaeca44-3d52-4e84-96de-fc8bb54f1e32",
        "include_external_user_ids": externalIds,
        "headings": {"en": title},
        "contents": {"en": body},
        "send_after": sendAt.toUtc().toIso8601String(),

        /// 🔥 MAKE IT LOOK PREMIUM
        "small_icon": "ic_launcher",

        /// 🔥 OPTIONAL BIG STYLE
        "android_style": "bigtext",

        /// 🔥 GROUPING
        "android_group": "appointments",

        /// 🔥 PRIORITY
        "priority": 10,
      }),
    );
  }


}