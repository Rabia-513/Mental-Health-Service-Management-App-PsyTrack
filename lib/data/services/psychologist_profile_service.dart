import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PsychologistProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _supabase = Supabase.instance.client;

  String get uid => _auth.currentUser!.uid;


  /// ================= FETCH PROFILE =================
  Future<Map<String, dynamic>> fetchProfile() async {
    final doc = await _firestore
        .collection('psychologists')
        .doc(uid)
        .get();

    return doc.data() ?? {};
  }

  /// ================= UPLOAD PROFILE IMAGE =================
  Future<String> uploadProfileImage(File file) async {
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


  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String country,
    required String language,
    required bool notificationsEnabled,
    String? profileImageUrl,
  }) async {
    await _firestore.collection('psychologists').doc(uid).update({
      "firstName": firstName,
      "lastName": lastName,
      "dob": Timestamp.fromDate(dob),
      "country": country,
      "language": language,
      "notificationsEnabled": notificationsEnabled,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
    });
  }
}

