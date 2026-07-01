import 'package:cloud_firestore/cloud_firestore.dart';

class ConsentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveConsent({
    required String patientId,
    required String psychologistId,
    required String patientName,
    required String attendantName,
    required String clinicianName,
    required DateTime consentDate,
  }) async {
    try {
      await _firestore.collection("patient_consents").add({
        "patientId": patientId,
        "psychologistId": psychologistId,
        "patientName": patientName,
        "attendantName": attendantName,
        "clinicianName": clinicianName,
        "consentGiven": true,
        "consentDate": Timestamp.fromDate(consentDate),
        "createdAt": FieldValue.serverTimestamp(),

      });
    } catch (e) {
      throw Exception("Failed to save consent");
    }
  }
}
