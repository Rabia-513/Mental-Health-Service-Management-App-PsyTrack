import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsentViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<bool> submitConsent({
    required String patientUid,
    required String patientCode,
    required String psychologistUid,
    required String patientName,
    String? attendantName,
    required String clinicianName,
    required DateTime consentDate,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection("patient_consents").add({
        "patientUid": patientUid,
        "patientCode": patientCode,
        "psychologistUid": psychologistUid,
        "patientName": patientName,
        "attendantName": attendantName,
        "clinicianName": clinicianName,
        "consentDate": Timestamp.fromDate(consentDate),
        "consentGiven": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
