import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ===============================
  /// CREATE APPOINTMENT
  /// ===============================
  Future<void> createAppointment({
    required String psychologistId,
    required String date,
    required String time,
  }) async {

    final patientId = _auth.currentUser!.uid;

    await _firestore.collection("appointments").add({
      "patientId": patientId,
      "psychologistId": psychologistId,
      "date": date,
      "time": time,
      "status": "pending",
      "createdAt": Timestamp.now(),
    });
  }

  /// ===============================
  /// GET PATIENT APPOINTMENTS
  /// ===============================
  Stream<QuerySnapshot> getPatientAppointments() {

    final patientId = _auth.currentUser!.uid;

    return _firestore
        .collection("appointments")
        .where("patientId", isEqualTo: patientId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// ===============================
  /// TOGGLE FAVOURITE PSYCHOLOGIST
  /// ===============================
  Future<void> toggleFavourite(String psychologistId) async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .collection("favourites")
        .doc(psychologistId);

    final doc = await ref.get();

    if(doc.exists){
      await ref.delete();
    }else{
      await ref.set({
        "psychologistId":psychologistId,
        "createdAt":FieldValue.serverTimestamp()
      });
    }
  }

  /// ===============================
  /// CHECK IF FAVOURITE
  /// ===============================
  Stream<bool> isFavourite(String psychologistId){

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .collection("favourites")
        .doc(psychologistId)
        .snapshots()
        .map((doc)=>doc.exists);

  }

}