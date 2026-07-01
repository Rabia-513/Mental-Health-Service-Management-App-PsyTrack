import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  final _db = FirebaseFirestore.instance;

  /// 🔹 Get connected psychologist
  Future<Map<String, dynamic>?> getPsychologist() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    print("Current UID: $uid");

    final snap = await _db
        .collection("patient_psychologist_connections")
        .where("patientUid", isEqualTo: uid)
        .get();

    print("Connections found: ${snap.docs.length}");

    if (snap.docs.isEmpty) return null;

    final connection = snap.docs.first.data();
    final psychUid = connection["psychologistUid"];

    print("Psych UID: $psychUid");

    final psychDoc = await _db
        .collection("psychologists")
        .doc(psychUid)
        .get();

    print("Doctor Data: ${psychDoc.data()}");

    if (!psychDoc.exists) return null;

    final data = psychDoc.data()!;
    data["uid"] = psychUid;

    return data;
  }

  /// 🔹 Submit rating (ONLY ONE PER PATIENT ✅)
  Future<void> submitRating({
    required String psychUid,
    required double rating,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    /// 🔥 UNIQUE DOCUMENT ID (IMPORTANT)
    final docId = "${uid}_$psychUid";

    final docRef = _db
        .collection("psychologist_ratings")
        .doc(docId);

    final doc = await docRef.get();

    if (doc.exists) {
      /// 🔁 UPDATE EXISTING RATING
      await docRef.update({
        "rating": rating,
        "updatedAt": Timestamp.now(),
      });
    } else {
      /// ➕ CREATE NEW RATING
      await docRef.set({
        "patientUid": uid,
        "psychologistUid": psychUid,
        "rating": rating,
        "createdAt": Timestamp.now(),
      });
    }

    /// 🔥 UPDATE AVERAGE
    await updateAverage(psychUid);
  }

  /// 🔹 Update average rating
  Future<void> updateAverage(String psychUid) async {
    final snap = await _db
        .collection("psychologist_ratings")
        .where("psychologistUid", isEqualTo: psychUid)
        .get();

    if (snap.docs.isEmpty) return;

    double total = 0;

    for (var doc in snap.docs) {
      total += (doc["rating"] as num).toDouble();
    }

    double avg = total / snap.docs.length;

    await _db
        .collection("psychologists")
        .doc(psychUid)
        .update({
      "averageRating": avg,
      "totalRatings": snap.docs.length,
    });
  }

  /// 🔹 Check if patient already rated (OPTIONAL UI USE)
  Future<int?> getExistingRating(String psychUid) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final docId = "${uid}_$psychUid";

    final doc = await _db
        .collection("psychologist_ratings")
        .doc(docId)
        .get();

    if (doc.exists) {
      return (doc["rating"] as num).toInt();
    }

    return null;
  }
}