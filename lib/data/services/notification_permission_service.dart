import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPermissionService {

  static Future<bool> canSend({
    required String userId,
  }) async {

    print("🔍 Checking notification permission for: $userId");

    /// PATIENT
    var doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(userId)
        .get();

    /// PSYCHOLOGIST
    if (!doc.exists) {
      doc = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(userId)
          .get();
    }

    /// FAMILY
    if (!doc.exists) {
      doc = await FirebaseFirestore.instance
          .collection("family")
          .doc(userId)
          .get();
    }

    if (!doc.exists) {
      print("⚠️ No settings found → allow");
      return true;
    }

    final data = doc.data()!;

    print("📊 Settings: $data");

    if (!(data["enableNotifications"] ?? true)) {
      print("🚫 Notifications disabled");
      return false;
    }

    if (!(data["appointmentNotifications"] ?? true)) {
      print("🚫 Appointment notifications disabled");
      return false;
    }

    print("✅ Notification allowed");
    return true;
  }
}