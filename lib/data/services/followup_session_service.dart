import 'package:cloud_firestore/cloud_firestore.dart';

class FollowupSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession({
    required String connectionId,
    required String patientUid,
    required String psychologistUid,
    required String assessmentId,
    required String sessionType,
    required DateTime followUpDate,
    required bool reminderEnabled,
  }) async {
    final doc = await _firestore.collection("sessions").add({
      "connectionId": connectionId,
      "patientUid": patientUid,
      "psychologistUid": psychologistUid,
      "assessmentId": assessmentId,
      "sessionType": sessionType,
      "followUpDate": Timestamp.fromDate(followUpDate),
      "reminderEnabled": reminderEnabled,
      "status": "scheduled",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection("patient_psychologist_connections")
        .doc(connectionId)
        .set({
      "latestSessionId": doc.id,
      "nextFollowUpDate": Timestamp.fromDate(followUpDate),
      "reminderEnabled": reminderEnabled,
      "latestSessionType": sessionType,
    }, SetOptions(merge: true));


    return doc.id;
  }

}