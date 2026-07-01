import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';

class FamilyScheduleScreen extends StatefulWidget {
  final String patientUid;

  const FamilyScheduleScreen({super.key, required this.patientUid});

  @override
  State<FamilyScheduleScreen> createState() =>
      _FamilyScheduleScreenState();
}

class _FamilyScheduleScreenState extends State<FamilyScheduleScreen> {
  String selectedFilter = "All";
  final isUrdu = Translations.isUrdu;
  Map<String, dynamic>? psychologist;
  Set<String> hiddenIds = {};
  /// ✅ RESOLVE PATIENT UID (same as history screen)
  Future<String> resolvePatientUid() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    String? passedUid = args?["patientUid"];

    // 1. From navigation
    if (passedUid != null && passedUid.isNotEmpty) {
      return passedUid;
    }

    // 2. From family collection
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("family")
        .doc(uid)
        .get();

    return doc.data()?["patientUid"] ?? "";
  }

  /// 🔥 FETCH PSYCHOLOGIST
  Future<void> loadPsychologist(String patientUid) async {
    final conn = await FirebaseFirestore.instance
        .collection("patient_psychologist_connections")
        .where("patientUid", isEqualTo: patientUid)
        .limit(1)
        .get();

    if (conn.docs.isNotEmpty) {
      final psychId = conn.docs.first["psychologistUid"];

      final doc = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(psychId)
          .get();

      setState(() {
        psychologist = doc.data();
      });
    }
  }

  List<DocumentSnapshot> getUpcomingSessions(List<DocumentSnapshot> list) {
    final now = DateTime.now();

    return list.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null || data["followUpDate"] == null) return false;

      final dt = (data["followUpDate"] as Timestamp).toDate();

      return dt.isAfter(now);
    }).toList()
      ..sort((a, b) {
        final aDate = (a["followUpDate"] as Timestamp).toDate();
        final bDate = (b["followUpDate"] as Timestamp).toDate();
        return aDate.compareTo(bDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      backgroundColor: const Color(0xffF1F7F6),

      appBar: AppBar(
          title: Text(isUrdu ? "اپائنٹمنٹس" : "Appointments"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff2F6F6D),
        elevation: 0,
      ),

      body: FutureBuilder<String>(
        future: resolvePatientUid(),
        builder: (context, uidSnap) {

          if (!uidSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patientUid = uidSnap.data!;

          if (patientUid.isEmpty) {
            return Center(
              child: Text(isUrdu ? "کوئی مریض منسلک نہیں" : "No Patient Connected"),
            );          }

          /// 🔥 LOAD PSYCHOLOGIST AFTER UID
          loadPsychologist(patientUid);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("sessions")
                .where("patientUid", isEqualTo: patientUid)
                .snapshots(),
            builder: (context, sessionSnap) {

              final sessions = sessionSnap.data?.docs ?? [];

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("appointments")
                    .where("patientId", isEqualTo: patientUid)
                    .snapshots(),
                builder: (context, appSnap) {

                  final appointments = appSnap.data?.docs ?? [];

                  final all = [...sessions, ...appointments];
                  final filtered = applyFilter(all)
                      .where((doc) => !hiddenIds.contains(doc.id))
                      .toList();
                  final upcomingSessions = getUpcomingSessions(sessions);
                  final upcomingAppointments = getUpcomingAppointments(all);

                  String getNextAppointmentDays(List<DocumentSnapshot> list) {
                    if (list.isEmpty) return "--";

                    final data = list.first.data() as Map<String, dynamic>?;

                    if (data == null) return "--";

                    DateTime? dt;

                    if (data["followUpDate"] != null) {
                      dt = (data["followUpDate"] as Timestamp).toDate();
                    } else if (data["date"] != null && data["date"].toString().isNotEmpty) {
                      dt = DateTime.tryParse(data["date"]);
                    }

                    if (dt == null) return "--";

                    final now = DateTime.now();

                    final today =
                    DateTime(now.year, now.month, now.day);

                    final appointmentDate =
                    DateTime(dt.year, dt.month, dt.day);

                    final diff =
                        appointmentDate.difference(today).inDays;

                    if (diff == 0) {
                      return isUrdu ? "آج" : "Today";
                    }

                    if (diff == 1) {
                      return isUrdu ? "کل" : "Tomorrow";
                    }

                    return isUrdu ? "$diff دن" : "$diff Days";}
                  String getProgress(List<DocumentSnapshot> list) {
                    if (list.isEmpty) return "--";

                    double? bestValue;

                    for (final doc in list) {
                      final data = doc.data() as Map<String, dynamic>?;
                      if (data == null) continue;

                      final value = data["sessionImprovement"];
                      if (value is num) {
                        bestValue = value.toDouble();
                      }
                    }

                    if (bestValue == null) return "--";

                    if (bestValue >= 70) {
                      return isUrdu ? "بہترین" : "Excellent";
                    }
                    if (bestValue >= 50) {
                      return isUrdu ? "اچھی" : "Good";
                    }
                    return isUrdu ? "مزید توجہ" : "Needs Work";
                  }                  return ListView(
                    padding: const EdgeInsets.all(14),
                    children: [

       Text(
                        isUrdu ? "اپائنٹمنٹس" : "Appointments",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2F6F6D)),
                      ),

                      const SizedBox(height: 10),

                      _patientCard(),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _statCard(
                            isUrdu ? "اگلا سیشن" : "Next Session",
                            getNextAppointmentDays(upcomingAppointments),
                            "assets/images/prescription.png",
                          ),
                          _statCard(
                            isUrdu ? "سیشنز" : "Sessions",
                            sessions.length.toString(),
                            "assets/images/session.png",
                          ),
                          _statCard(
                            isUrdu ? "پیش رفت" : "Progress",
                            getProgress(sessions),
                            "assets/images/progress.png",
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),




                      if (upcomingSessions.isNotEmpty)
                        _nextSessionCard(upcomingSessions.first),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _filter("all", isUrdu ? "سب" : "All"),
                          _filter("today", isUrdu ? "آج" : "Today"),
                          _filter("tomorrow", isUrdu ? "کل" : "Tomorrow"),
                          _filter("upcoming", isUrdu ? "آنے والی" : "Upcoming"),               ],
                      ),

        Text(
                        isUrdu ? "مزید اپائنٹمنٹس" : "More Appointments",                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      ...filtered.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Dismissible(
                          key: Key(doc.id),
                          direction: DismissDirection.endToStart,

                          /// 🔥 REMOVE ONLY FROM UI
                          confirmDismiss: (direction) async {
                            setState(() {
                              hiddenIds.add(doc.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUrdu
                                      ? "فہرست سے ہٹا دیا گیا"
                                      : "Removed from list",
                                ),
                              ),
                            );

                            return false; // 🔥 IMPORTANT → prevents rebuild glitch
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),

                          child: _appointmentCard(
                            data["sessionType"] ??
                                (isUrdu ? "اپائنٹمنٹ" : "Appointment"),
                            data["date"] ?? "",
                            data["status"] ?? "",
                          ),
                        );
                      }).toList(),                    ],
                  );
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar:  FamilyBottomNav(
        selectedIndex: 3,
      ),
    ));
  }

  /// 🔥 FILTER LOGIC
  List<DocumentSnapshot> applyFilter(List<DocumentSnapshot> list) {
    DateTime now = DateTime.now();

    return list.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) return false;

      DateTime date;

      if (data["followUpDate"] != null) {
        date = (data["followUpDate"] as Timestamp).toDate();
      } else {
        date = DateTime.tryParse(data["date"] ?? "") ?? DateTime.now();
      }

      if (selectedFilter == "today") {
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }

      if (selectedFilter == "tomorrow") {
        final tomorrow = now.add(const Duration(days: 1));
        return date.day == tomorrow.day &&
            date.month == tomorrow.month &&
            date.year == tomorrow.year;
      }

      if (selectedFilter == "upcoming") {
        return date.isAfter(now);
      }

      return true;
    }).toList();
  }

  Widget _filter(String key, String label) {
    final active = selectedFilter == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xff2F6F6D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff2F6F6D)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xff2F6F6D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget _patientCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffDFF2EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: psychologist?["profileImageUrl"] != null
                ? NetworkImage(psychologist!["profileImageUrl"])
                : null,
            child: psychologist?["profileImageUrl"] == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  psychologist?["name"] ?? "Patient",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  psychologist?["professionalTitle"] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.medical_services)
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String imagePath) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 22,
              width: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _nextSessionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final dt = data["followUpDate"] != null
        ? (data["followUpDate"] as Timestamp).toDate()
        : DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffE8F7F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff2F6F6D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Next Session",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(data["sessionType"] ?? "Session"),
          Text("${dt.day}/${dt.month}/${dt.year}"),
        ],
      ),
    );
  }

  Widget _appointmentCard(String title, String subtitle, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status ?? ""),
          )
        ],
      ),
    );
  }
}
List<DocumentSnapshot> getUpcomingAppointments(List<DocumentSnapshot> list) {
  final now = DateTime.now();

  return list.where((doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return false;

    DateTime? dt;

    if (data["followUpDate"] != null) {
      dt = (data["followUpDate"] as Timestamp).toDate();
    } else if (data["date"] != null && data["date"].toString().isNotEmpty) {
      dt = DateTime.tryParse(data["date"]);
    }

    if (dt == null) return false;

    return dt.isAfter(now) ||
        (dt.day == now.day && dt.month == now.month && dt.year == now.year);
  }).toList()
    ..sort((a, b) {
      DateTime aDate;
      DateTime bDate;

      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      if (aData["followUpDate"] != null) {
        aDate = (aData["followUpDate"] as Timestamp).toDate();
      } else {
        aDate = DateTime.tryParse(aData["date"] ?? "") ?? DateTime.now();
      }

      if (bData["followUpDate"] != null) {
        bDate = (bData["followUpDate"] as Timestamp).toDate();
      } else {
        bDate = DateTime.tryParse(bData["date"] ?? "") ?? DateTime.now();
      }

      return aDate.compareTo(bDate);
    });
}