import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyService {

  final supabase = Supabase.instance.client;
  final firestore = FirebaseFirestore.instance;

  /// 🔥 UPLOAD IMAGE TO SUPABASE
  Future<String> uploadFamilyImage({
    required File imageFile,
    required String familyUid,
  }) async {
    try {
      final fileName = "$familyUid.jpg";
      final path = "family-images/$fileName";

      await supabase.storage
          .from('family-images') // 🔥 bucket name
          .upload(path, imageFile);

      final imageUrl = supabase.storage
          .from('family-images')
          .getPublicUrl(path);

      return imageUrl;

    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  /// 🔥 SAVE FAMILY MEMBER
  Future<void> saveFamily({
    required String familyUid,
    required String patientUid,
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String relation,
    required DateTime? dob,
    required String imageUrl,
  }) async {

    await firestore.collection("family").doc(familyUid).set({
      "fullName": name,
      "email": email,
      "phone": phone,
      "gender": gender,
      "relation": relation,
      "dob": dob,
      "profileImageUrl": imageUrl,
      "patientUid": patientUid,
      "createdAt": FieldValue.serverTimestamp(),
    });

  }
}