import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/routes.dart';
import '../../styles/colors.dart';
import 'psychologist_schedule_detail_screen.dart';

// main screen first one//

class PsychologistScheduleScreen extends StatefulWidget {
  const PsychologistScheduleScreen({super.key});

  @override
  State<PsychologistScheduleScreen> createState() =>
      _PsychologistScheduleScreenState();
}

class _PsychologistScheduleScreenState
    extends State<PsychologistScheduleScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  final Color mainColor = const Color(0xff4E7D7A);
  final Color softBg = const Color(0xffEEF5F4);

  String _dateKey(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

  String _monthTitle(DateTime day) => DateFormat('MMMM').format(day);

  String _sessionHeading(DateTime day) =>
      DateFormat('EEE, MMM d').format(day);

  int _eventsForDay(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      DateTime day,
      ) {
    final key = _dateKey(day);
    return docs.where((doc) {
      final data = doc.data();
      return (data['date'] ?? '') == key &&
          (data['status'] ?? '').toString().toLowerCase() != 'cancelled';
    }).length;
  }

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

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String name,
    required String time,
    required String status,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.text(context).withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: mainColor.withOpacity(0.35), width: 1.8),
              ),
              child: Icon(
                Icons.person,
                color: mainColor.withOpacity(0.55),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(
                      color: mainColor.withOpacity(0.82),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(status),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.menu, color: mainColor, size: 34),
              const Spacer(),
              Icon(Icons.psychology_alt_outlined, color: mainColor, size: 50),
              const SizedBox(width: 10),
              Text(
                "PsyTrack",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "Schedule",
            style: TextStyle(
              color: mainColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> sessionDocs,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: mainColor.withOpacity(0.35)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        focusedDay = DateTime(
                          focusedDay.year,
                          focusedDay.month - 1,
                        );
                      });
                    },
                    icon: Icon(Icons.chevron_left, color: mainColor, size: 34),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_left, color: mainColor, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      _monthTitle(focusedDay),
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      focusedDay = DateTime.now();
                      selectedDay = DateTime.now();
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      border: Border.all(color: mainColor, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: mainColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "Today",
                          style: TextStyle(
                            color: mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime(2023),
            lastDay: DateTime(2035),
            focusedDay: focusedDay,
            headerVisible: false,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              isTodayHighlighted: false,
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: AppColors.card(context),
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                color: mainColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              weekendTextStyle: TextStyle(
                color: mainColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: mainColor.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              weekendStyle: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            eventLoader: (day) {
              final count = _eventsForDay(sessionDocs, day);
              return List.generate(count, (_) => 'event');
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDaySessions(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    final selectedKey = _dateKey(selectedDay);

    final selectedDocs = docs.where((doc) {
      final data = doc.data();
      return (data['date'] ?? '') == selectedKey;
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${selectedDocs.length} Sessions on ${_sessionHeading(selectedDay)}",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: mainColor, size: 34),
            ],
          ),
          const SizedBox(height: 14),
          if (selectedDocs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              child: Text(
                "No sessions for selected day",
                style: TextStyle(
                  color: mainColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            )
          else
            Column(
              children: selectedDocs.map((doc) {
                final data = doc.data();

                final String patientName =
                (data['patientName'] ?? 'Patient').toString();

                final String status =
                (data['status'] ?? 'upcoming').toString();

                final String timeText = data['endTime'] != null &&
                    (data['endTime'] as String).trim().isNotEmpty
                    ? "${data['startTime']} - ${data['endTime']}"
                    : (data['startTime'] ?? data['time'] ?? '').toString();

               return Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,

                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete"),
                        content: const Text("Delete this session?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },

                  onDismissed: (direction) async {
                    await FirebaseFirestore.instance
                        .collection("sessions")
                        .doc(doc.id)
                        .delete();
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  child: _buildSessionCard(
                    name: patientName,
                    time: timeText,
                    status: status,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PsychologistScheduleDetailScreen(
                            documentId: doc.id,
                            sourceCollection: "sessions",
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("appointments")
          .where("psychologistId", isEqualTo: uid)
          .where("status", isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.text(context).withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Appointment Requests",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              if (docs.isEmpty)
                Text(
                  "No pending requests",
                  style: TextStyle(
                    color: mainColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                )
              else
                Column(
                  children: docs.map((doc) {
                    final data = doc.data();

                    final String patientName =
                    (data["patientName"] ?? "Patient").toString();
                    final String date = (data["date"] ?? "").toString();
                    final String time = (data["time"] ?? "").toString();

                return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,

                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete"),
                            content: const Text("Delete this appointment?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },

                      onDismissed: (direction) async {
                        await FirebaseFirestore.instance
                            .collection("appointments")
                            .doc(doc.id)
                            .delete();
                      },

                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),

                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      child: _buildSessionCard(
                        name: patientName,
                        time: "$date  •  $time",
                        status: "pending",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PsychologistScheduleDetailScreen(
                                documentId: doc.id,
                                sourceCollection: "appointments",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildFollowUpSessions() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("patient_psychologist_connections")
          .where("psychologistUid", isEqualTo: uid)
          .where("status", isEqualTo: "active")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: softBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Follow-up Sessions",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              if (docs.isEmpty)
                Text(
                  "No follow-up sessions",
                  style: TextStyle(
                    color: mainColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                )
              else
                Column(
                  children: docs.map((doc) {

                    final data = doc.data();

                    final Timestamp? followUp =
                    data["nextFollowUpDate"] as Timestamp?;

                    String dateText = "--";

                    if (followUp != null) {
                      final date = followUp.toDate();
                      dateText = DateFormat('yyyy-MM-dd').format(date);
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("patients")
                          .doc(data["patientUid"])
                          .get(),
                      builder: (context, patientSnap) {

                        String patientName = "Patient";

                        if (patientSnap.connectionState ==
                            ConnectionState.waiting) {

                          patientName = "Loading...";

                        } else if (patientSnap.hasData &&
                            patientSnap.data!.exists) {

                          final patientData =
                          patientSnap.data!.data()
                          as Map<String, dynamic>;

                          print(patientData);

                          final firstName =
                          (patientData["firstName"] ?? "").toString();

                          final lastName =
                          (patientData["lastName"] ?? "").toString();

                          patientName =
                              "$firstName $lastName".trim();

                          if (patientName.isEmpty) {
                            patientName = "Patient";
                          }

                        } else {

                          patientName = "Patient";

                        }
                        return _buildSessionCard(
                          name: patientName,
                          time: "Follow-up • $dateText",
                          status: "upcoming",
                          onTap: () {

                            Navigator.pushNamed(
                              context,
                              AppRoutes.startSession,
                              arguments: {
                                "connectionId": doc.id,
                                "patientId": data["patientUid"],
                                "patientName": patientName,
                              },
                            );

                          },
                        );
                      },
                    );

                  }).toList(),                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("sessions")
              .where("psychologistId", isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> sessionDocs =
                snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildCalendarCard(sessionDocs),
                  const SizedBox(height: 18),
                  _buildSelectedDaySessions(sessionDocs),
                  const SizedBox(height: 18),

                  _buildFollowUpSessions(),
                  const SizedBox(height: 18),
                  _buildPendingRequests(),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}