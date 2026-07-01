import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'records_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {

  String search = "";

  Stream<QuerySnapshot> getPatients(String uid) {
    return FirebaseFirestore.instance
        .collection("patient_psychologist_connections")
        .where("psychologistUid", isEqualTo: uid)
        .where("status", isEqualTo: "active")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7F6),

      appBar: AppBar(
        title: const Text("Records"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff4E7D7A),
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search patient...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// 📋 LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPatients(uid),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final connections = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final code = (data["patientCode"] ?? "").toString().toLowerCase();
                  return code.contains(search);
                }).toList();

                return ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {

                    final data = connections[index].data() as Map<String, dynamic>;
                    final patientUid = data["patientUid"];
                    final patientCode = data["patientCode"];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("patients")
                          .doc(patientUid)
                          .get(),
                      builder: (context, snap) {

                        if (!snap.hasData) return const SizedBox();

                        final patient = snap.data!.data() as Map<String, dynamic>;
                        final name =
                            "${patient["firstName"] ?? ""} ${patient["lastName"] ?? ""}";

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [

                              const CircleAvatar(
                                backgroundColor: Color(0xffE6F2F1),
                                child: Icon(Icons.person, color: Colors.teal),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Patient ID: $patientCode"),
                                  ],
                                ),
                              ),

                              /// OPEN
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecordsScreen(
                                        connectionId: connections[index].id,
                                        patientUid: patientUid,
                                        patientName: name,
                                        patientCode: patientCode,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              /// DELETE
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePatient(connections[index].id),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// 🔥 FULL DELETE (IMPORTANT)
  void _deletePatient(String connectionId) async {

    await FirebaseFirestore.instance
        .collection("patient_psychologist_connections")
        .doc(connectionId)
        .delete();

    /// DELETE NOTES
    final notes = await FirebaseFirestore.instance
        .collection("psychologist_notes")
        .where("connectionId", isEqualTo: connectionId)
        .get();

    for (var doc in notes.docs) {
      await doc.reference.delete();
    }

    /// DELETE ASSESSMENTS
    final assessments = await FirebaseFirestore.instance
        .collection("patient_assessments")
        .where("connectionId", isEqualTo: connectionId)
        .get();

    for (var doc in assessments.docs) {
      await doc.reference.delete();
    }

    /// DELETE PRESCRIPTIONS
    final prescriptions = await FirebaseFirestore.instance
        .collection("prescriptions")
        .where("connectionId", isEqualTo: connectionId)
        .get();

    for (var doc in prescriptions.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Patient fully deleted")),
    );
  }
}