import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/data/services/onesignal_service.dart';

import 'notification_permission_service.dart';
class NotificationService {

  /// MAIN FUNCTION
  static Future sendAppointmentNotification({
    required String psychologistId,
    required String patientName,
    required String date,
    required String time,
  }) async {

    /// 1️⃣ GET PSYCHOLOGIST DATA
    final psychDoc = await FirebaseFirestore.instance
        .collection("psychologists")
        .doc(psychologistId)
        .get();

    final psychologistEmail = psychDoc["email"];

    /// 2️⃣ DASHBOARD NOTIFICATION
    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": psychologistId,
      "title": "New Appointment Request",
      "message": "$patientName booked appointment on $date at $time",
      "type": "appointment",
      "read": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    /// 3️⃣ EMAIL NOTIFICATION
    await http.post(
      Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": "service_w7lgnhn",
        "template_id": "template_lz6zhvd",
        "user_id": "yEqrMTauttpEPQEUq",
        "template_params": {
          "to_email": psychologistEmail,
          "patient_name": patientName,
          "date": date,
          "time": time
        }
      }),
    );


      await OneSignalService.sendNotification(
        externalId: psychologistId,
        title: " PsyTrack • New Appointment",
        body: "📅 $patientName booked a session\n⏰ $date at $time\n Check now",
      );


  }
  /// ✅ PATIENT RESPONSE (ACCEPT / REJECT)
  static Future sendAppointmentResponse({
    required String patientId,
    required String status,
    required String date,
    required String time,
  }) async {

    String title = status == "confirmed"
        ? "📅 Appointment Confirmed"
        : "❌ Appointment Rejected";

    String body = status == "confirmed"
        ? " Your session is confirmed\n📅 $date\n⏰ $time\n✨ Stay prepared"
        : "⚠️ Your appointment was rejected\n📅 $date\n Please reschedule";

    /// Dashboard notification
    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": patientId,
      "title": title,
      "message": body,
      "type": "appointment_response",
      "read": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    /// Push notification
    if (await NotificationPermissionService.canSend(
      userId: patientId,

    )) {
      await OneSignalService.sendNotification(
        externalId: patientId,
        title: title,
        body: body,
      );
    }
  }
  /// ✅ REMINDER NOTIFICATION
  static Future sendReminder({
    required String userId,
    required String title,
    required String body,
  }) async {

    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": userId,
      "title": title,
      "message": body,
      "type": "reminder",
      "read": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await OneSignalService.sendNotification(
      externalId: userId,
      title: title,
      body: body,
    );
  }
  static Future sendToUser({
    required String userId,
    required String title,
    required String message,
  }) async {

    String finalTitle = " PsyTrack • $title";

    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": userId,
      "title": finalTitle,
      "message": message,
      "read": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (await NotificationPermissionService.canSend(
      userId: userId,
 // reminders are appointment-based
    )) {
      if (await NotificationPermissionService.canSend(
        userId: userId,

      )) {
        await OneSignalService.sendNotification(
          externalId: userId,
          title: finalTitle,
          body: message,
        );
      }
    }
  }

  static Future<List<String>> getAllUsersWithFamily(
      String patientUid,
      String psychologistUid,
      ) async {

    List<String> users = [patientUid, psychologistUid];

    final familySnap = await FirebaseFirestore.instance
        .collection("family")
        .where("patientUid", isEqualTo: patientUid)
        .get();

    for (var doc in familySnap.docs) {
      users.add(doc.id); // 🔥 family UID
    }

    return users;
  }
}