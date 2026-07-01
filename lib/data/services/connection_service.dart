import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> connectPatientByCode(String patientCode) async {
    final psychologistUid = _auth.currentUser!.uid;

    final patientQuery = await _firestore
        .collection('patients')
        .where('patientCode', isEqualTo: patientCode.trim())
        .limit(1)
        .get();

    if (patientQuery.docs.isEmpty) {
      throw Exception("Patient not found");
    }

    final patientDoc = patientQuery.docs.first;
    final patientUid = patientDoc.id;
    final patientData = patientDoc.data();

    final connectionId = "${psychologistUid}_$patientUid";

    final connectionRef = _firestore
        .collection('patient_psychologist_connections')
        .doc(connectionId);

    final existing = await connectionRef.get();

    if (!existing.exists) {
      await connectionRef.set({
        'connectionId': connectionId,
        'patientUid': patientUid,
        'psychologistUid': psychologistUid,
        'patientCode': patientCode.trim(),
        'status': 'active',

        'historyAllowed': false,
        'consentAllowed': false,
        'historySubmitted': false,
        'consentSubmitted': false,
        'historyPdfUrl': '',
        'latestHistoryId': '',
        'latestConsentId': '',
        'assessmentStarted': false,
        'assessmentCompleted': false,
        'currentStage': 'connected',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return {
      "connectionId": connectionId,
      "patientUid": patientUid,
      "patientName":
      "${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}".trim(),
      "patientCode": patientData['patientCode'] ?? '',
    };
  }



  Future<void> savePsychologistNote({
    required String connectionId,
    required String patientUid,
    required String noteText,
    int? sessionNumber,

    String stage = 'history_review',
  }) async {
    final psychologistUid = _auth.currentUser!.uid;

    await _firestore.collection('psychologist_notes').add({
      'connectionId': connectionId,
      'patientUid': patientUid,
      'psychologistUid': psychologistUid,
      if (sessionNumber != null) "sessionNumber": sessionNumber,
      'noteText': noteText.trim(),
      'stage': stage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveAssessment({
    required String connectionId,
    required String patientUid,
    required String assessmentType,
    required int score,
    required String severity,
    Map<String, dynamic>? answers,
  }) async {
    final psychologistUid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('assessments').add({
      'connectionId': connectionId,
      'patientUid': patientUid,
      'psychologistUid': psychologistUid,
      'assessmentType': assessmentType,
      'score': score,
      'severity': severity,
      'answers': answers ?? {},
      'completedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('patient_psychologist_connections')
        .doc(connectionId)
        .update({
      'assessmentStarted': true,
      'assessmentCompleted': true,
      'latestAssessmentId': doc.id,
      'currentStage': 'assessment_completed',
    });
  }
  Future<void> allowHistoryAndConsent(String connectionId) async {
    await FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc(connectionId)
        .update({
      'historyAllowed': true,
      'consentAllowed': true,
      'currentStage': 'forms_allowed',
    });
  }

  Future<void> markConsentSubmitted({
    required String connectionId,
  }) async {
    await FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc(connectionId)
        .update({
      'consentSubmitted': true,
      'currentStage': 'consent_submitted',
    });
  }

  Future<void> markHistorySubmitted({
    required String connectionId,
    required String historyId,
    required String historyPdfUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc(connectionId)
        .update({
      'historySubmitted': true,
      'historyPdfUrl': historyPdfUrl,
      'latestHistoryId': historyId,
      'currentStage': 'history_submitted',
    });
  }
}