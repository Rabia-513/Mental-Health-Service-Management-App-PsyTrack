import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/translations.dart';

class EmergencyContactScreen extends StatelessWidget {
  const EmergencyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Translations.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? "ہنگامی رابطہ" : "Emergency Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(isUrdu ? "ایمبولینس" : "Ambulance"),
              subtitle: const Text("1122"),
              trailing: const Icon(Icons.call),
            ),
            ListTile(
              title: Text(isUrdu ? "پولیس" : "Police"),
              subtitle: const Text("15"),
              trailing: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    );
  }
}