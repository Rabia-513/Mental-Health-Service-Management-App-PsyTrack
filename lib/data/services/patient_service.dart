import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class PatientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, String>?> registerPatient({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String state,
    required String city,
    required String gender,
    required DateTime dob,
    required String password,
    String? psychologistUid,
  }) async {
    try {

      // create auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = cred.user!.uid;

      // 🔥 automatic patient code
      String patientCode = "CP${uid.substring(uid.length - 6).toUpperCase()}";

      await cred.user!.sendEmailVerification();

      await _firestore.collection("patients").doc(uid).set({
        "firebaseUid": uid,
        "patientCode": patientCode,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "gender": gender,
        "dob": Timestamp.fromDate(dob),
        "city": city,
        "state": state,
        "country": country,
        "psychologistId": psychologistUid,
        "role": "patient",
        "createdAt": FieldValue.serverTimestamp(),
      });

      return {
        "patientUid": uid,
        "patientCode": patientCode,
      };

    } catch (e) {
      debugPrint("Patient signup error: $e");
      return null;
    }
  }
  Future<String> generatePatientId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("patients")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return "CP000001";
    }

    final lastId = snapshot.docs.first["patientCode"];

    int number = int.parse(lastId.replaceAll("CP", ""));
    number++;

    return "CP${number.toString().padLeft(6, '0')}";
  }

}
