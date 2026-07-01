import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../styles/colors.dart';

class StatsPatientsScreen extends StatefulWidget {
  const StatsPatientsScreen({super.key});

  @override
  State<StatsPatientsScreen> createState() => _StatsPatientsScreenState();
}

class _StatsPatientsScreenState extends State<StatsPatientsScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPatients() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection("patient_psychologist_connections")
        .where("psychologistUid", isEqualTo: uid) // ✅ FILTER
        .where("status", isEqualTo: "active")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Stats & Insights"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getPatients(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final patients = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {

              final data = patients[index];

              final patientUid = data["patientUid"];
              final patientCode = data["patientCode"];
              final assessmentId = data["latestAssessmentId"];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("patients").doc(patientUid).get(),
                builder: (context, snap) {

                  if (!snap.hasData) return const SizedBox();

                  final patient = snap.data!;
                  final name =
                      "${patient["firstName"]} ${patient["lastName"]}";
                  final age = "26";

                  return _patientCard(
                    name,
                    age,
                    patientCode,
                    assessmentId,
                    patientUid,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _patientCard(
      String name,
      String age,
      String patientCode,
      String assessmentId,
      String patientUid,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/patientStats",
          arguments: {
            "patientUid": patientUid,
            "assessmentId": assessmentId
          },
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.text(context).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0,4),
            )
          ],
        ),

        child: Row(
          children: [

            /// 👤 PROFILE
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff4E7D7A),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, size: 30),
            ),

            const SizedBox(width: 14),

            /// 🧾 INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Age: $age",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),                  ),

                  Text(
                    "Patient ID: $patientCode",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),                  ),
                ],
              ),
            ),

            /// 📊 SCORE + STATUS
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                /// SCORE

                /// 🟢 STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),

                  decoration: BoxDecoration(
                    color: const Color(0xff4E7D7A),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child:  Text(
                    "View Stats",
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 6),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}