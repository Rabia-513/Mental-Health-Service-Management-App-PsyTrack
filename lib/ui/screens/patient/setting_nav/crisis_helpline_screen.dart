import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/translations.dart';

class CrisisHelplineScreen extends StatelessWidget {
  const CrisisHelplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Translations.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? "ہنگامی مدد" : "Crisis Helpline"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(isUrdu
                  ? "ذہنی صحت ہیلپ لائن"
                  : "Mental Health Helpline"),
              subtitle: const Text("0800-12345"),
              trailing: const Icon(Icons.call),
            ),
            ListTile(
              title: Text(isUrdu
                  ? "خودکشی روک تھام"
                  : "Suicide Prevention"),
              subtitle: const Text("Umang 1093"),
              trailing: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    );
  }
}