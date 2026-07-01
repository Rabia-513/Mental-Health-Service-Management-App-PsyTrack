import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../../app/translations.dart';
import '../../../../data/services/email_service.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/onesignal_service.dart';
import '../../styles/colors.dart';

class AppointmentConfirmationScreen extends StatefulWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  State<AppointmentConfirmationScreen> createState() =>
      _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState
    extends State<AppointmentConfirmationScreen> {
  final reasonController = TextEditingController();
  bool reminder = true;
  bool isSending = false;
  final mainColor = const Color(0xff4E7D7A);

  Future<void> sendAppointment(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final patientName =
        FirebaseAuth.instance.currentUser!.displayName ?? "Patient";

    await FirebaseFirestore.instance.collection("appointments").add({
      "patientId": uid,
      "patientName": patientName,
      "psychologistId": data["psychologistId"],
      "psychologistName": data["psychologistName"],
      "date": data["date"],
      "time": data["time"],
      "reason": reasonController.text.trim(),
      "reminder": reminder,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await NotificationService.sendAppointmentNotification(
      psychologistId: data["psychologistId"],
      patientName: patientName,
      date: data["date"],
      time: data["time"],
    );
    /// 🔥 CREATE REMINDER (3 HOURS BEFORE)


    final dateParts = data["date"].split("-");
    final timeParts = data["time"].split(" ");

    final hm = timeParts[0].split(":");
    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);

    if (timeParts[1] == "PM" && hour != 12) hour += 12;
    if (timeParts[1] == "AM" && hour == 12) hour = 0;

    DateTime appointmentDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      hour,
      minute,
    );
    DateTime reminderTime =
    appointmentDateTime.subtract(const Duration(minutes:3));
    if (reminder) {
      final users = await NotificationService.getAllUsersWithFamily(
        uid,
        data["psychologistId"],
      );

      await OneSignalService.sendScheduledNotification(
        externalIds: users,
        title: "⏰ Appointment Reminder",
        body: " Session in 3 minutes\n📅 ${data["date"]}\n⏰ ${data["time"]}",
        sendAt: reminderTime,
      );    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${Translations.t("appointmentBooked")} ${data["date"]} ${Translations.t("at")} ${data["time"]}",
        ),
      ),
    );
    setState(() {
      isSending = false;
    });
    Navigator.pop(context);

  }



  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (data == null) {
      return const Scaffold(
        body: Center(
          child: Text("No appointment data found"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        title: Text(
          "Book Appointment",
          style: TextStyle(color: AppColors.card(context)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Available Time",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "${data["time"]}",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Text(
              "${data["date"]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              "Are you sure you want to book appointment?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              value: "Self",
              items: [
                DropdownMenuItem(
                  value: "Self",
                  child: Text(Translations.t("bookingFor")),
                ),
              ],
              onChanged: (v) {},
              decoration: const InputDecoration(
                labelText: "Booking for / بکنگ",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Reason for Appointment / وجہ",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text("Reminder message for appointment"),
                ),
                Switch(
                  value: reminder,
                  activeColor: const Color(0xff4E7D7A),
                  onChanged: (val) {
                    setState(() {
                      reminder = val;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isSending ? Colors.grey : const Color(0xff4E7D7A),
                      foregroundColor: AppColors.card(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSending
                        ? null
                        : () async {
                      setState(() {
                        isSending = true;
                      });

                      try {
                        await sendAppointment(data);
                      } catch (e) {
                        setState(() {
                          isSending = false;
                        });
                      }
                    },

                    child: isSending
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Sending...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                        : Text(
                      Translations.t("send"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: AppColors.card(context),
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      Translations.t("Cancel"),
                      style:  TextStyle(
                        color: AppColors.card(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Your information is safe and confidential",
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}