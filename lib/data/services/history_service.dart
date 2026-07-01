import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final _db = FirebaseFirestore.instance;

  /// CREATE NEW HISTORY
  Future<String> createHistory({
    required String patientUid,
    required String psychologistUid,
    required String language,
  }) async {
    final doc = await _db.collection("case_histories").add({
      "patientUid": patientUid,
      "psychologistUid": psychologistUid,
      "language": language,
      "currentStep": 1,
      "isCompleted": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// SAVE STEP DATA
  Future<void> saveStep({
    required String historyId,
    required int step,
    required Map<String, dynamic> data,
    bool moveNext = false,
  }) async {
    await _db.collection("case_histories").doc(historyId).set({
      "step$step": data,
      if (moveNext) "currentStep": step + 1,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// MARK HISTORY COMPLETE
  Future<void> completeHistory(String historyId) async {
    await _db.collection("case_histories").doc(historyId).update({
      "isCompleted": true,
      "completedAt": FieldValue.serverTimestamp(),
    });
  }

  /// GET ALL STEPS DATA
  Future<Map<String, dynamic>> getFullHistory(String historyId) async {
    final doc =
    await _db.collection("case_histories").doc(historyId).get();
    return doc.data() ?? {};
  }

  /// SAVE PDF URL
  Future<void> savePdfUrl({
    required String historyId,
    required String pdfUrl,
  }) async {
    await _db.collection("case_histories").doc(historyId).update({
      "pdfUrl": pdfUrl,
    });
  }



  Future<Map<String, dynamic>> getHistoryMeta(String historyId) async {
    final doc = await _db.collection("case_histories").doc(historyId).get();
    return doc.data() ?? {};
  }



}
