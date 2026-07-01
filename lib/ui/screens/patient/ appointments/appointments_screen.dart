import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/translations.dart';
import '../../../common/patient_bottom_nav.dart';
import '../../styles/colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/patient-dashboard", // 🔥 IMPORTANT
                  (route) => false,
            );
          },
        ),
        iconTheme: IconThemeData(color: AppColors.text(context)),

        title: Text(
          Translations.t("appointments"),
          style: TextStyle(color: AppColors.text(context)),
        ),

        bottom: TabBar(
          controller: tabController,
          labelColor: const Color(0xff4E7D7A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xff4E7D7A),
          tabs: [
            Tab(text: Translations.t("all")),
            Tab(text: Translations.t("pending")),
            Tab(text: Translations.t("confirmed")),
            Tab(text: Translations.t("rejected")),
            Tab(text: Translations.t("followUp")), // 🔥 NEW
          ],
        ),
      ),

      body: TabBarView(
        controller: tabController,
        children: [

          appointmentList("all"),
          appointmentList("pending"),
          appointmentList("confirmed"),
          appointmentList("rejected"),
          appointmentList("followup"),

        ],
      ),
      bottomNavigationBar: PatientBottomNav(
        selectedIndex: 0, // 👈 VERY IMPORTANT
      ),
    );
  }

  // ================= MAIN LOGIC =================

  Widget appointmentList(String status) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    /// 🔁 FOLLOW-UP → SESSIONS
    if (status == "followup") {

      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("sessions")
            .where("patientUid", isEqualTo: uid)
            .where("status", isEqualTo: "scheduled")
            .orderBy("followUpDate", descending: false)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No follow-up sessions"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return sessionCard(docs[index]);
            },
          );
        },
      );
    }

    /// 🔀 ALL → MERGE appointments + sessions
    if (status == "all") {

      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("appointments")
            .where("patientId", isEqualTo: uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("sessions")
                .where("patientUid", isEqualTo: uid)
                .snapshots(),

            builder: (context, sessionSnap) {

              if (!sessionSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final sessions = sessionSnap.data!.docs;

              final allData = [...appointments, ...sessions];

              if (allData.isEmpty) {
                return const Center(child: Text("No data"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allData.length,
                itemBuilder: (context, index) {

                  final data = allData[index];

                  if (data.data().toString().contains("time")) {
                    return appointmentCard(data);
                  } else {
                    return sessionCard(data);
                  }
                },
              );
            },
          );
        },
      );
    }

    /// 📌 NORMAL → appointments only
    Query query = FirebaseFirestore.instance
        .collection("appointments")
        .where("patientId", isEqualTo: uid)
        .where("status", isEqualTo: status);

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No appointments"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return appointmentCard(docs[index]);
          },
        );
      },
    );
  }

  // ================= APPOINTMENT CARD =================

  Widget appointmentCard(DocumentSnapshot data){

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),

      child: Row(
        children: [

          const Icon(Icons.calendar_month,
              color: Color(0xff4E7D7A), size: 35),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  data["psychologistName"] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  "${data["date"]} • ${data["time"]}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                statusChip(data["status"]),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= SESSION CARD (FOLLOW-UP) =================

  Widget sessionCard(DocumentSnapshot data){

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),

      child: Row(
        children: [

          const Icon(Icons.repeat,
              color: Colors.green, size: 35),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  data["sessionType"] ?? "Therapy Session",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  data["followUpDate"] != null
                      ? (data["followUpDate"] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 16)
                      : "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Follow-up",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget statusChip(String status){

    Color color = Colors.grey;

    if(status == "pending") color = Colors.orange;
    if(status == "confirmed") color = const Color(0xff4E7D7A);
    if(status == "rejected") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Translations.t(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}