import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes.dart';


///create new session if forgot ist screen


class SelectPatientScreen extends StatefulWidget {
  const SelectPatientScreen({super.key});

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String search = "";

  final Color mainColor = const Color(0xff4E7D7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7F7),
      appBar: AppBar(
        title: const Text("Select Patient"),
        backgroundColor: Theme.of(context).cardColor
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search patients...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📋 PATIENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("patient_psychologist_connections")
                  .where("psychologistUid", isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                /// ✅ FILTER PROPERLY
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["patientName"] ?? "")
                      .toString()
                      .toLowerCase();
                  return name.contains(search);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No patients found"));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {

                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;


                    final patientUid = data["patientUid"];
                    final connectionId = doc.id;

                    /// DEFAULT VALUES

                    String score = "--";
                    String severity = "No Data";

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("patients")
                          .doc(patientUid)
                          .get(),
                      builder: (context, patientSnap) {

                        String name = "Patient";
                        String age = "--";

                        if (patientSnap.hasData && patientSnap.data!.exists) {
                          final p = patientSnap.data!.data() as Map<String, dynamic>;

                          name = "${p["firstName"] ?? ""} ${p["lastName"] ?? ""}".trim();

                          if (p["dob"] != null) {
                            final dob = (p["dob"] as Timestamp).toDate();
                            age = (DateTime.now().year - dob.year).toString();
                          }
                        }

                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("patient_assessments")
                              .where("connectionId",
                              isEqualTo: connectionId)
                              .orderBy("createdAt",
                              descending: true)
                              .limit(1)
                              .get(),
                          builder: (context, assessSnap) {

                            if (assessSnap.hasData &&
                                assessSnap.data!.docs.isNotEmpty) {
                              final a = assessSnap.data!.docs.first
                                  .data() as Map<String, dynamic>;

                              score = a["score"]?.toString() ?? "--";
                              severity = a["severity"] ?? "No Data";
                            }

                            Color severityColor = Colors.grey;

                            if (severity.toLowerCase().contains("mild")) {
                              severityColor = Colors.orange;
                            } else if (severity
                                .toLowerCase()
                                .contains("moderate")) {
                              severityColor = Colors.deepOrange;
                            } else if (severity
                                .toLowerCase()
                                .contains("severe")) {
                              severityColor = Colors.red;
                            } else if (severity
                                .toLowerCase()
                                .contains("extreme")) {
                              severityColor = Colors.redAccent;
                            }

                            /// 🔥 BEAUTIFUL CARD
                            return InkWell(
                              onTap: () {
                                /// ✅ FIXED NAVIGATION (IMPORTANT)
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.startSession,
                                  arguments: {
                                    "patientId": patientUid,
                                    "patientName": name,
                                    "connectionId": connectionId,
                                  },
                                );
                              },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE9F3F2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: Row(
                                    children: [

                                      /// 👤 AVATAR
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: mainColor.withOpacity(0.2),
                                        child: Icon(Icons.person, color: mainColor),
                                      ),

                                      const SizedBox(width: 12),

                                      /// 👤 PATIENT INFO
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            /// ✅ FIXED NAME
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              "Age: $age",
                                              style: TextStyle(color: Colors.grey[700]),
                                            ),

                                            Text(
                                              "ID: ${data["patientCode"] ?? "--"}",
                                              style: TextStyle(color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      /// 📊 SCORE BOX (FIXED WIDTH)
                                      Container(
                                        width: 70, // ✅ IMPORTANT FIX
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [

                                            Text(
                                              "Score",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),

                                            Text(
                                              score,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: severityColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                severity,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            );
                          },
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