import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../styles/colors.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() =>
      _ManagePatientsScreenState();
}

class _ManagePatientsScreenState
    extends State<ManagePatientsScreen> {

  final Color mainColor = const Color(0xff4E7D7A);

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    final psychologistUid =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.card(context),

      appBar: AppBar(
        elevation: 0,
        title: const Text("Manage Patient"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search patients...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 👥 PATIENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("patient_psychologist_connections")
                  .where("psychologistUid",
                  isEqualTo: psychologistUid)
                  .where("status", isEqualTo: "active")
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final patients = snapshot.data!.docs;

                if (patients.isEmpty) {
                  return const Center(
                      child: Text("No connected patients"));
                }

                return ListView.builder(
                  itemCount: patients.length,

                  itemBuilder: (context, index) {

                    final connectionDoc = patients[index];
                    final connectionId = connectionDoc.id;
                    final data = connectionDoc.data()
                    as Map<String, dynamic>;

                    final patientUid = data["patientUid"];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("patients")
                          .doc(patientUid)
                          .get(),

                      builder: (context, userSnapshot) {

                        if (!userSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final patientData =
                        userSnapshot.data!.data()
                        as Map<String, dynamic>?;

                        final patientName =
                        "${patientData?["firstName"] ?? ""} "
                            "${patientData?["lastName"] ?? ""}"
                            .trim();

                        /// 🔍 SEARCH FILTER
                        if (searchText.isNotEmpty &&
                            !patientName
                                .toLowerCase()
                                .contains(searchText)) {
                          return const SizedBox();
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/patientDetail",
                              arguments: connectionId,
                            );
                          },

                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: const Color(0xffEAF3F2),
                              borderRadius:
                              BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.text(context)
                                      .withOpacity(0.04),
                                  blurRadius: 8,
                                  offset:
                                  const Offset(0, 4),
                                )
                              ],
                            ),

                            child: Row(
                              children: [

                                /// 👤 PROFILE
                                Container(
                                  padding:
                                  const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: mainColor,
                                        width: 2),
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 28),
                                ),

                                const SizedBox(width: 12),

                                /// 🧾 INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      Text(
                                        patientName.isEmpty
                                            ? "Patient"
                                            : patientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "Patient ID: ${data["patientCode"]}",
                                        style: const TextStyle(
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                /// 📊 SCORE + STATUS
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [

                                    /// SCORE
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore
                                          .instance
                                          .collection(
                                          "patient_assessments")
                                          .where(
                                          "connectionId",
                                          isEqualTo:
                                          connectionId)
                                          .orderBy(
                                          "createdAt",
                                          descending: true)
                                          .limit(1)
                                          .snapshots(),

                                      builder:
                                          (context, snap) {

                                        if (!snap.hasData ||
                                            snap.data!.docs
                                                .isEmpty) {
                                          return const Text(
                                              "No Score");
                                        }

                                        final assess = snap
                                            .data!.docs.first
                                            .data()
                                        as Map<String,
                                            dynamic>;

                                        return Text(
                                          "Total Score\n${assess["score"] ?? 0}",
                                          textAlign:
                                          TextAlign.right,
                                          style:
                                          const TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 6),

                                    /// 🟢 STATUS BADGE
                                    Container(
                                      padding:
                                      const EdgeInsets
                                          .symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                      decoration:
                                      BoxDecoration(
                                        color: mainColor,
                                        borderRadius:
                                        BorderRadius
                                            .circular(14),
                                      ),
                                      child: const Text(
                                        "Active",
                                        style: TextStyle(
                                            color:
                                            Colors.white,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 6),

                                const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}