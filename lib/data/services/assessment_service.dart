import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveAssessment({
    required String connectionId,
    required String patientUid,
    required String psychologistUid,
    required String historyId,
    required String assessmentCode,
    required String assessmentName,
    required List<int> answers,
    required int score,
    required String severity,
  }) async {
    final doc = await _firestore.collection('patient_assessments').add({
      "connectionId": connectionId,
      "patientUid": patientUid,
      "psychologistUid": psychologistUid,
      "historyId": historyId,
      "assessmentCode": assessmentCode,
      "assessmentName": assessmentName,
      "answers": answers,
      "score": score,
      "severity": severity,
      "status": "completed",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('patient_psychologist_connections')
        .doc(connectionId)
        .set({
      "assessmentStarted": true,
      "assessmentCompleted": true,
      "latestAssessmentId": doc.id,
      "currentStage": "assessment_completed",
    }, SetOptions(merge: true));

    return doc.id;
  }
}