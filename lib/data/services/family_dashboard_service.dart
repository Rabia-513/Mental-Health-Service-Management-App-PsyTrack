import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyDashboardService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///  CURRENT FAMILY UID
  String get currentUid => _auth.currentUser!.uid;

  ///  GET FAMILY DATA (MAIN FUNCTION)
  Future<Map<String, dynamic>?> getFamilyData() async {
    final doc = await _firestore.collection("family").doc(currentUid).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    return {
      "fullName": data["fullName"] ?? "",
      "relation": data["relation"] ?? "",
      "profileImageUrl": data["profileImageUrl"] ?? "",
      "patientUid": data["patientUid"] ?? "", // 🔥 IMPORTANT
    };
  }

  /// 🔥 GET PATIENT UID ONLY (SAFE FUNCTION)
  Future<String> getPatientUid() async {
    final doc = await _firestore.collection("family").doc(currentUid).get();

    if (!doc.exists) return "";

    return doc.data()?["patientUid"] ?? "";
  }

  /// 🔔 NOTIFICATIONS (FOR PATIENT)
  Stream<QuerySnapshot> getUnreadNotifications(String patientUid) {
    return _firestore
        .collection("notifications")
        .where("userId", isEqualTo: patientUid)
        .where("read", isEqualTo: false)
        .snapshots();
  }

  /// 📅 ACTIVE CONNECTION
  Stream<QuerySnapshot> getActiveConnection(String patientUid) {
    return _firestore
        .collection("patient_psychologist_connections")
        .where("patientUid", isEqualTo: patientUid)
        .where("status", isEqualTo: "active")
        .limit(1)
        .snapshots();
  }

  /// 📄 LATEST PRESCRIPTION (FROM CONNECTION)
  Stream<QuerySnapshot> getLatestPrescription(String patientUid) {
    return _firestore
        .collection("patient_psychologist_connections")
        .where("patientUid", isEqualTo: patientUid)
        .where("status", isEqualTo: "active")
        .limit(1)
        .snapshots();
  }

  /// 💊 ALL PRESCRIPTIONS (NEW - IMPORTANT)
  Stream<QuerySnapshot> getAllPrescriptions(String patientUid) {
    return _firestore
        .collection("prescriptions")
        .where("patientUid", isEqualTo: patientUid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// 📊 SESSIONS (OPTIONAL - FUTURE USE)
  Stream<QuerySnapshot> getPatientSessions(String patientUid) {
    return _firestore
        .collection("sessions")
        .where("patientUid", isEqualTo: patientUid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}