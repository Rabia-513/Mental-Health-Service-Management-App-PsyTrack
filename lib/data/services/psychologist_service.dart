import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PsychologistService {
  final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  static final _supabase = Supabase.instance.client;

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<String?> registerPsychologist({
    required String firstName,
    required String lastName,
    required String phone,
    required String clinicName,
    required String clinicAddress,
    required String clinicEmail,
    required String qualification,
    required String licenseNumber,
    required String yearsOfExperience,
    required String workingDays,
    required String workingHours,
    required File certificateFile,
    required String password,

  }) async {
    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: clinicEmail.trim(),
        password: password.trim(),
      );

      String uid = cred.user!.uid;

      // 2️⃣ Upload certificate to Firebase Storage
      String certificatePath = "psychologists/$uid/license_certificate.jpg";
      UploadTask uploadTask =
      _storage.ref().child(certificatePath).putFile(certificateFile);

      TaskSnapshot snapshot = await uploadTask;
      String certificateUrl = await snapshot.ref.getDownloadURL();

      // 3️⃣ Save user data to Firestore
      await _firestore.collection("psychologists").doc(uid).set({
        "uid": uid,

        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,

        "email": clinicEmail,
        "clinicEmail": clinicEmail,

        "clinicName": clinicName,
        "clinicAddress": clinicAddress,
        "qualification": qualification,
        "licenseNumber": licenseNumber,
        "yearsOfExperience": yearsOfExperience,
        "workingDays": workingDays,
        "workingHours": workingHours,
        "certificateUrl": certificateUrl,
        "createdAt": DateTime.now(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
  static Future<DocumentSnapshot<Map<String, dynamic>>> getProfile(
      String uid) {
    return _db.collection("psychologists").doc(uid).get();
  }

  // UPDATE (Edit Profile)



  static Future<String> uploadProfileImage(
      File file, String uid) async {
    final bytes = await file.readAsBytes();

    await _supabase.storage
        .from('psychologist-profiles')
        .uploadBinary(
      'profiles/$uid.jpg',
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage
        .from('psychologist-profiles')
        .getPublicUrl('profiles/$uid.jpg');
  }

  static Future<void> updateProfile(
      String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection("psychologists")
        .doc(uid)
        .update(data);
  }

  // ================= FETCH PROFESSIONAL INFO =================
  static Future<Map<String, dynamic>?> fetchProfessionalInfo(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("psychologists")
        .doc(uid)
        .get();
    return doc.data();
  }

  static Future<void> updateProfessionalInfo(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await FirebaseFirestore.instance
        .collection("psychologists")
        .doc(uid)
        .update(data);
  }

  // ================= FETCH AVAILABILITY =================
  static Future<Map<String, dynamic>?> fetchAvailability(String uid) async {
    final doc =
    await _firestore.collection("psychologists").doc(uid).get();

    return doc.data()?['availability'];
  }

  // ================= UPDATE AVAILABILITY =================
  static Future<void> updateAvailability(
      String uid, Map<String, dynamic> availability) async {
    await _firestore.collection("psychologists").doc(uid).update({
      "availability": availability,
    });
  }


  // ================= FETCH CLINIC DETAILS =================
  static Future<Map<String, dynamic>?> fetchClinicDetails(String uid) async {
    final doc = await _firestore.collection("psychologists").doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    // clinicDetails is nested object
    return Map<String, dynamic>.from(data['clinicDetails'] ?? {});
  }

  // ================= UPDATE CLINIC DETAILS =================
  static Future<void> updateClinicDetails(String uid, Map<String, dynamic> data) async {
    await _firestore.collection("psychologists").doc(uid).set({
      "clinicDetails": data,
    }, SetOptions(merge: true));
  }

  // ================= UPLOAD CLINIC IMAGES =================
  static Future<List<String>> uploadClinicImages({
    required String uid,
    required List<File> files,
  }) async {
    const bucket = "clinic-images";

    final urls = <String>[];

    for (final f in files) {
      final bytes = await f.readAsBytes();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = "clinic/$uid/$fileName";

      await _supabase.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      urls.add(url);
    }

    return urls;
  }

  // ================= FETCH ABOUT ME =================
  static Future<Map<String, dynamic>?> fetchAboutMe(String uid) async {
    final doc =
    await FirebaseFirestore.instance.collection("psychologists").doc(uid).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return Map<String, dynamic>.from(data['aboutMe'] ?? {});
  }

// ================= UPDATE ABOUT ME =================
  static Future<void> updateAboutMe(
      String uid, Map<String, dynamic> aboutData) async {
    await FirebaseFirestore.instance
        .collection("psychologists")
        .doc(uid)
        .set({
      "aboutMe": aboutData,
    }, SetOptions(merge: true));
  }
  // ================= FETCH CONTACT =================
  static Future<Map<String, dynamic>?> fetchContact(String uid) async {
    final doc =
    await FirebaseFirestore.instance.collection("psychologists").doc(uid).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return {
      "phone": data['phone'], // from signup
      "email": data['email'], // from signup
      "contactDetails": data['contactDetails'] ?? {},
    };
  }

// ================= UPDATE CONTACT =================
  static Future<void> updateContact(
      String uid, Map<String, dynamic> contactData) async {
    await FirebaseFirestore.instance
        .collection("psychologists")
        .doc(uid)
        .set({
      "contactDetails": contactData,
    }, SetOptions(merge: true));
  }
}
