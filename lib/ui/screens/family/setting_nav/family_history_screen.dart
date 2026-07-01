import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as fw; // ✅ FIX RTL ERROR
import 'package:intl/intl.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';



class FamilyHistoryScreen extends StatefulWidget {
  final String patientUid;


  const FamilyHistoryScreen({super.key, required this.patientUid});

  @override
  State<FamilyHistoryScreen> createState() => _FamilyHistoryScreenState();
}

class _FamilyHistoryScreenState extends State<FamilyHistoryScreen> {
  String selectedFilter = "all";
  late String patientUid;
  final patientId = FirebaseAuth.instance.currentUser!.uid;
  final Color primary = const Color(0xff456F6C);
  final Color lightBg = const Color(0xffF4FBFA);

  Future<Map<String, dynamic>> loadData() async {
    final firestore = FirebaseFirestore.instance;

    final moodSnap = await firestore
        .collection("patients")
        .doc(patientUid)
        .collection("mood_checkins")
        .get();

    final reportSnap = await firestore
        .collection("reports")
        .where("patientUid", isEqualTo: patientUid)
        .get();

    final prescriptionSnap = await firestore
        .collection("prescriptions")
        .where("patientUid", isEqualTo: patientUid)
        .get();

    final connectionSnap = await firestore
        .collection("patient_psychologist_connections")
        .where("patientUid", isEqualTo: patientUid)
        .limit(1)
        .get();

    String doctorName = "Dr";
    String doctorImage = "";

    if (connectionSnap.docs.isNotEmpty) {
      final psychId = connectionSnap.docs.first['psychologistUid'];

      final psychDoc =
      await firestore.collection("psychologists").doc(psychId).get();

      if (psychDoc.exists) {
        doctorName = psychDoc['name'] ?? "Dr";
        doctorImage = psychDoc['profileImageUrl'] ?? "";
      }
    }

    List<Map<String, dynamic>> items = [];

    /// 🔹 MOOD
    for (var doc in moodSnap.docs) {
      final data = doc.data();

      items.add({
        "type": "mood",
        "title": Translations.t("moodLogs"),
        "subtitle":
        "${Translations.t("mood")}: ${Translations.isUrdu ? data['moodLabelUr'] : data['moodLabelEn']}",
        "time": data['createdAt'] ?? data['updatedAt'] ?? null,
        "image": data['moodImage'],
        "status": Translations.t("completed"),
      });
    }

    /// 🔹 REPORT
    for (var doc in reportSnap.docs) {
      final data = doc.data();

      items.add({
        "type": "report",
        "title": data['reportName'] ?? "Report",
        "subtitle": "",
        "time": data['createdAt'] ?? data['updatedAt'] ?? null,
        "image": "assets/images/freport.png",
        "status": Translations.t("uploaded"),
      });
    }

    /// 🔹 SESSION
    for (var doc in prescriptionSnap.docs) {
      final data = doc.data();

      items.add({
        "type": "session",
        "title": "${Translations.t("sessionWith")} $doctorName",
        "subtitle": "",
        "time": data['createdAt'] ?? data['updatedAt'] ?? null,
        "image": doctorImage,
        "status": Translations.t("completed"),
      });
    }

    /// SORT (latest first)
    items.sort((a, b) {

      final t1 = a['time'];
      final t2 = b['time'];

      if (t1 == null && t2 == null) return 0;
      if (t1 == null) return 1;
      if (t2 == null) return -1;

      if (t1 is! Timestamp || t2 is! Timestamp) return 0;

      return t2.compareTo(t1);
    });

    return {
      "moodCount": moodSnap.docs.length,
      "sessionCount": prescriptionSnap.docs.length,
      "reportCount": reportSnap.docs.length,
      "items": items,
    };
  }

  String formatDate(dynamic t) {
    if (t == null || t is! Timestamp) return Translations.isUrdu ? "تاریخ موجود نہیں" : "No date";
    return DateFormat('dd MMM yyyy').format(t.toDate());
  }

  String formatTime(dynamic t) {
    if (t == null || t is! Timestamp) return "";
    return DateFormat('h:mm a').format(t.toDate());
  }
  @override
  Widget build(BuildContext context) {

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    String? passedUid = args?["patientUid"];

    final isUrdu = Translations.isUrdu;

    final user = FirebaseAuth.instance.currentUser;
    Future<String> getPatientUid() async {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("family")
          .doc(uid)
          .get();

      return doc.data()?["patientUid"] ?? "";
    }


    Future<String> resolvePatientUid() async {

      // ✅ 1. If passed from dashboard
      if (passedUid != null && passedUid.isNotEmpty) {
        return passedUid;
      }

      // ✅ 2. Otherwise get from family collection
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("family")
          .doc(uid)
          .get();
      print("Fetching family UID...");
      print("Current user: ${FirebaseAuth.instance.currentUser!.uid}");
      print("Doc data: ${doc.data()}");
      print("Resolved patientUid: ${doc.data()?["patientUid"]}");
      return doc.data()?["patientUid"] ?? "";

    }
    FutureBuilder<String>(
      future: resolvePatientUid(),
      builder: (context, uidSnapshot) {

        if (!uidSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        patientUid = uidSnapshot.data!;

        /// 🔥 NOW LOAD DATA
        return FutureBuilder<Map<String, dynamic>>(
          future: loadData(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            final items = data['items'] as List;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔹 TITLE
                  Text(
                    Translations.t("history"),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 SUMMARY

                  const SizedBox(height: 20),

                  /// 🔹 FILTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _chip("all", Translations.t("all")),
                      _chip("session", Translations.t("sessions")),
                      _chip("mood", Translations.t("moodLogs")),
                      _chip("report", Translations.t("reports")),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 TIMELINE
                  ...items.map((item) {
                    if (selectedFilter != "all" &&
                        item['type'] != selectedFilter) {
                      return const SizedBox();
                    }

                    return _timelineItem(item);
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );

    if (user == null) {
      return  Scaffold(
        body: Center(child: Text( Translations.isUrdu
            ? "صارف لاگ ان نہیں ہے"
            : "User not logged in",)),
      );
    }

    return Directionality(
      textDirection:
      isUrdu ? fw.TextDirection.rtl : fw.TextDirection.ltr, // ✅ FIX
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          title:  Text(Translations.isUrdu ? "تاریخ" : "History"),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff2F6F6D),
        ),


        body: SafeArea(
          child: FutureBuilder<String>(
            future: resolvePatientUid(),
            builder: (context, uidSnapshot) {

              if (!uidSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              patientUid = uidSnapshot.data!;

              if (patientUid.isEmpty) {
                return  Center(child: Text(  Translations.isUrdu
                    ? "کوئی مریض منسلک نہیں ہے"
                    : "No patient connected",));
              }

              /// 🔥 NOW LOAD REAL DATA
              return FutureBuilder<Map<String, dynamic>>(
                future: loadData(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  final items = data['items'] as List;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        /// 🔹 TITLE
                        Text(
                          Translations.t("history"),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 SUMMARY
                        Row(
                          children: [
                            _summaryCard(
                              Translations.t("moodTrend"),
                              "${data['moodCount']}",
                              "assets/images/mood.png",
                            ),

                            _summaryCard(
                              Translations.t("sessions"),
                              "${data['sessionCount']}",
                              "assets/images/session.png",
                            ),

                            _summaryCard(
                              Translations.t("reports"),
                              "${data['reportCount']}",
                              "assets/images/freport.png",
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 FILTER
                        /// 🔹 FILTER
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _chip("all", Translations.t("all")),
                                const SizedBox(width: 8),
                                _chip("session", Translations.t("sessions")),
                                const SizedBox(width: 8),
                                _chip("mood", Translations.t("moodLogs")),
                                const SizedBox(width: 8),
                                _chip("report", Translations.t("reports")),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        /// 🔹 TIMELINE
                        ...items.map((item) {
                          if (selectedFilter != "all" &&
                              item['type'] != selectedFilter) {
                            return const SizedBox();
                          }

                          return _timelineItem(item);
                        }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

      ),
    );
  }

  Widget _summaryCard(String title, String value, String image) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xffDFF3F3),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [

            /// IMAGE
            Image.asset(image, height: 40),

            const SizedBox(height: 8),

            Text(title, style: const TextStyle(fontSize: 12)),

            const SizedBox(height: 4),

            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
  Widget _chip(String key, String text) {
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: Chip(
        label: Text(text),
        backgroundColor:
        selectedFilter == key ? Colors.teal : Colors.grey.shade200,
      ),
    );
  }

  Widget _timelineItem(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: item['image'].toString().startsWith("http")
                ? NetworkImage(item['image'])
                : AssetImage(item['image']) as ImageProvider,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (item['subtitle'] != "")
                  Text(item['subtitle']),
                if (item['time'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDate(item['time'])),
                      Text(formatTime(item['time'])),
                    ],
                  )
              ],
            ),
          ),
          Chip(label: Text(item['status']))
        ],
      ),
    );
  }
}