import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../styles/colors.dart';

class MyPatientCodeScreen extends StatefulWidget {
  const MyPatientCodeScreen({super.key});

  @override
  State<MyPatientCodeScreen> createState() => _MyPatientCodeScreenState();
}

class _MyPatientCodeScreenState extends State<MyPatientCodeScreen> {
  String patientCode = "";
  String patientName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatientCode();
  }

  Future<void> loadPatientCode() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("patients")
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          patientCode = data["patientCode"] ?? "";
          patientName = "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading patient code: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        title: Text(
          "My QR Code",
          style: TextStyle(color: Theme.of(context).cardColor),
        ),
        iconTheme:  IconThemeData(color: Theme.of(context).cardColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patientCode.isEmpty
          ? const Center(
        child: Text(
          "Patient code not found",
          style: TextStyle(fontSize: 16),
        ),
      )
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 60,
                color: Color(0xff4E7D7A),
              ),
              const SizedBox(height: 12),

              Text(
                patientName.isEmpty ? "Patient" : patientName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1F2937),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Show this code to your psychologist for connection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text(context).withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: patientCode,
                      version: QrVersions.auto,
                      size: 220,
                      gapless: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Patient Code",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      patientCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xff4E7D7A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}