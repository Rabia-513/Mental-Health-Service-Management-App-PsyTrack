import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/onesignal_service.dart';
import '../../styles/colors.dart';


// accept reject screen

class PsychologistScheduleDetailScreen extends StatefulWidget {
  final String documentId;
  final String sourceCollection; // "sessions" or "appointments"

  const PsychologistScheduleDetailScreen({
    super.key,
    required this.documentId,
    required this.sourceCollection,
  });

  @override
  State<PsychologistScheduleDetailScreen> createState() =>
      _PsychologistScheduleDetailScreenState();
}

class _PsychologistScheduleDetailScreenState
    extends State<PsychologistScheduleDetailScreen> {
  final Color mainColor = const Color(0xff4E7D7A);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xff50C878);
      case 'upcoming':
      case 'confirmed':
        return mainColor;
      case 'pending':
        return const Color(0xffF0A500);
      case 'cancelled':
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  DateTime? _tryParseDate(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd').parse(date);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadPatient(String? patientId) async {
    if (patientId == null || patientId.isEmpty) return null;

    final doc =
    await FirebaseFirestore.instance.collection("patients").doc(patientId).get();

    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> _editNote({
    required String collection,
    required String docId,
    required String initialText,
    required String fieldName,
  }) async {
    final controller = TextEditingController(text: initialText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Note"),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Write note here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection(collection)
                    .doc(docId)
                    .update({
                  fieldName: controller.text.trim(),
                });

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rescheduleItem({
    required String collection,
    required String docId,
    required bool isSession,
  }) async {

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) return;

    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedStartTime == null) return;

    String formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? "AM" : "PM";
      return "$hour:$minute $period";
    }

    String newDate = DateFormat('yyyy-MM-dd').format(pickedDate);
    String newTime = formatTime(pickedStartTime);

    /// 🔥 UPDATE FIRESTORE
    if (isSession) {
      final combinedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedStartTime.hour,
        pickedStartTime.minute,
      );

      await FirebaseFirestore.instance.collection(collection).doc(docId).update({
        "followUpDate": Timestamp.fromDate(combinedDateTime),
      });
    }
    else {
      await FirebaseFirestore.instance.collection(collection).doc(docId).update({
        "date": newDate,
        "time": newTime,
      });
    }

    /// 🔥 GET DATA AGAIN (IMPORTANT)
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .get();

    final data = doc.data() ?? {};

    /// 🔥 SEND NOTIFICATION TO PATIENT
    final patientId = data["patientUid"] ?? data["patientId"];
    final psychologistId = data["psychologistId"];

    /// 🔔 SEND TO PATIENT
    final users = await NotificationService.getAllUsersWithFamily(
      patientId,
      psychologistId,
    );

    for (String uid in users) {
      await NotificationService.sendToUser(
        userId: uid,
        title: "🔄 Session Rescheduled",
        message: "📅 New date: $newDate\n⏰ $newTime",
      );
    }

    /// 🔔 SEND TO PSYCHOLOGIST


    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rescheduled successfully")),
    );
  }
  Future<void> _cancelOrReject({
    required String collection,
    required String docId,
    required String newStatus,
  }) async {

    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .get();

    final data = doc.data();

    await FirebaseFirestore.instance.collection(collection).doc(docId).update({
      "status": newStatus,
    });


    /// ✅ SEND TO PATIENT
    if (data != null && collection == "appointments") {
      await NotificationService.sendAppointmentResponse(
        patientId: data["patientId"],
        status: newStatus,
        date: data["date"],
        time: data["time"],
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status changed to $newStatus")),
    );
  }

  Future<void> _acceptAppointment({
    required String docId,
    required Map<String, dynamic> data,
  }) async {

    /// 1️⃣ Update status
    await FirebaseFirestore.instance
        .collection("appointments")
        .doc(docId)
        .update({"status": "confirmed"});

    /// 2️⃣ Create session
    await FirebaseFirestore.instance.collection("sessions").add({
      "psychologistId": data["psychologistId"],
      "patientUid": data["patientId"],   // ✅ FIXED
      "patientName": data["patientName"] ?? "Patient",
      "date": data["date"],
      "startTime": data["time"],
      "connectionId": data["connectionId"],
      "endTime": "",
      "status": "upcoming",
      "mode": data["mode"] ?? "In-Clinic",
      "notes": data["reason"] ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    /// ✅ 3️⃣ SEND NOTIFICATION TO PATIENT
    await NotificationService.sendAppointmentResponse(
      patientId: data["patientId"],
      status: "confirmed",
      date: data["date"],
      time: data["time"],
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment accepted")),
    );
  }

  Future<void> _handleFileButton(Map<String, dynamic> data) async {
    final fileUrl = data["fileUrl"] ??
        data["reportUrl"] ??
        data["historyPdfUrl"] ??
        data["pdfUrl"];

    if (fileUrl == null || fileUrl.toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file attached")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attached File"),
        content: SelectableText(fileUrl.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topMiniButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey, width: 1.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mainColor, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(widget.sourceCollection)
          .doc(widget.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Record not found")),
          );
        }

        final data = snapshot.data!.data()!;
        final String patientId = (data["patientUid"] ?? "").toString();
        final String patientName = (data["patientName"] ?? "Patient").toString();
        final String status = (data["status"] ?? "upcoming").toString();

        final bool isPendingAppointment =
            widget.sourceCollection == "appointments" &&
                status.toLowerCase() == "pending";

        final bool isSession = widget.sourceCollection == "sessions";

        final String date = (data["date"] ?? "").toString();

        final DateTime? parsedDate = _tryParseDate(date);
        final String monthLabel =
        parsedDate != null ? DateFormat('MMMM').format(parsedDate) : "Date";
        final String dayLabel =
        parsedDate != null ? DateFormat('d').format(parsedDate) : "--";
        final String yearLabel =
        parsedDate != null ? DateFormat('yyyy').format(parsedDate) : "--";

        final String startTime =
        (data["startTime"] ?? data["time"] ?? "--").toString();
        final String endTime = (data["endTime"] ?? "").toString().trim();

        final bool hasValidEndTime =
            endTime.isNotEmpty && endTime != "--" && endTime != startTime;

        final String timeText =
        hasValidEndTime ? "$startTime - $endTime" : startTime;

        final String mode = (data["mode"] ?? "In-Clinic").toString();
        final String noteText =
        (data["notes"] ?? data["reason"] ?? "No notes added yet").toString();

        return FutureBuilder<Map<String, dynamic>?>(
          future: _loadPatient(patientId),
          builder: (context, patientSnapshot) {
            final patientData = patientSnapshot.data;

            final String displayName = patientData?["name"]?.toString() ??
                patientData?["fullName"]?.toString() ??
                patientName;

            final String age = patientData?["age"]?.toString() ?? "--";
            final String gender = patientData?["gender"]?.toString() ?? "--";

            return Scaffold(
              backgroundColor: const Color(0xffF4F4F4),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: mainColor, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: mainColor, size: 42),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthLabel,
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$dayLabel $yearLabel",
                                style: TextStyle(
                                  color: mainColor.withOpacity(0.85),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),                        decoration: BoxDecoration(
                          color: const Color(0xffEEF5F4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: mainColor.withOpacity(0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: mainColor.withOpacity(0.45),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: mainColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$age | $gender",
                                        style: TextStyle(
                                          color: mainColor.withOpacity(0.85),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _topMiniButton(
                                    icon: Icons.note_alt_outlined,
                                    title: "Note",
                                    onTap: () => _editNote(
                                      collection: widget.sourceCollection,
                                      docId: widget.documentId,
                                      initialText: noteText == "No notes added yet"
                                          ? ""
                                          : noteText,
                                      fieldName: isSession ? "notes" : "reason",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _topMiniButton(
                                    icon: Icons.insert_drive_file_outlined,
                                    title: "File",
                                    onTap: () => _handleFileButton(data),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              timeText,
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _statusChip(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Mode: $mode",
                        style: TextStyle(
                          color: mainColor.withOpacity(0.82),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isPendingAppointment)
                        Row(
                          children: [
                            _actionButton(
                              text: "Accept",
                              icon: Icons.check_circle_outline,
                              color: mainColor,
                              onTap: () => _acceptAppointment(
                                docId: widget.documentId,
                                data: data,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _actionButton(
                              text: "Reject",
                              icon: Icons.close,
                              color: Colors.pinkAccent,
                              onTap: () => _cancelOrReject(
                                collection: "appointments",
                                docId: widget.documentId,
                                newStatus: "rejected",
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [

                            /// START SESSION BUTTON
                            if (isSession && status.toLowerCase() != "completed")
                            /// RESCHEDULE + CANCEL
                            Row(
                              children: [
                                _actionButton(
                                  text: "Reschedule",
                                  icon: Icons.calendar_month_outlined,
                                  color: mainColor,
                                  onTap: () => _rescheduleItem(
                                    collection: widget.sourceCollection,
                                    docId: widget.documentId,
                                    isSession: isSession,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _actionButton(
                                  text: "Cancel",
                                  icon: Icons.cancel_outlined,
                                  color: Colors.pinkAccent,
                                  onTap: () => _cancelOrReject(
                                    collection: widget.sourceCollection,
                                    docId: widget.documentId,
                                    newStatus: "cancelled",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 18),
                      Divider(color: Colors.grey, thickness: 1.1),
                      const SizedBox(height: 12),

                      Text(
                        "Session Details",
                        style: TextStyle(
                          color: mainColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time, color: mainColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hasValidEndTime
                                  ? "Time: $timeText"
                                  : "Arrival Time: $timeText",
                              style: TextStyle(
                                color: mainColor.withOpacity(0.9),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: mainColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Mode: $mode",
                              style: TextStyle(
                                color: mainColor.withOpacity(0.9),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey, thickness: 1.1),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Notes",
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _editNote(
                              collection: widget.sourceCollection,
                              docId: widget.documentId,
                              initialText:
                              noteText == "No notes added yet" ? "" : noteText,
                              fieldName: isSession ? "notes" : "reason",
                            ),
                            icon: Icon(
                              Icons.edit_outlined,
                              color: mainColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: mainColor.withOpacity(0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          noteText,
                          style: TextStyle(
                            color: mainColor.withOpacity(0.92),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}