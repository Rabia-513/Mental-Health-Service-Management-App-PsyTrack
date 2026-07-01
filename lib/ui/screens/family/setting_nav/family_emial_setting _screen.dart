import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/translations.dart';

class FamilyEmailSettingsScreen extends StatefulWidget {
  const FamilyEmailSettingsScreen({super.key});

  @override
  State<FamilyEmailSettingsScreen> createState() =>
      _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends State<FamilyEmailSettingsScreen> {

  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool obscure = true;

  final user = FirebaseAuth.instance.currentUser;

  Future<void> updateEmail() async {
    try {
      await user!.verifyBeforeUpdateEmail(_emailController.text);

      /// update firestore
      await FirebaseFirestore.instance
          .collection("family")
          .doc(user!.uid)
          .update({
        "email": _emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text( Translations.isUrdu
            ? "تصدیقی ای میل بھیج دی گئی ہے"
            : "Verification email sent")),
      );

    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePassword() async {
    try {
      await user!.updatePassword(_passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(Translations.isUrdu
            ? "پاس ورڈ کامیابی سے اپ ڈیٹ ہو گیا"
            : "Password updated",)),
      );

    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = user?.email ?? "";
  }
  final isUrdu = Translations.isUrdu;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF1F7F6),

      appBar: AppBar(
        title: Text(isUrdu ? "ای میل" : "Email"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff2F6F6D),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(isUrdu ? "اکاؤنٹ کی ترتیبات " :"Account Settings",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            /// PASSWORD
          Text(isUrdu ? "پاس ورڈ تبدیل کریں" : "Change Password"),
            const SizedBox(height: 5),

            TextField(
              controller: _passwordController,
              obscureText: obscure,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(obscure
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// EMAIL
            const Text("Update Email"),
            const SizedBox(height: 5),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            /// SAVE BUTTON
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6F6D),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                ),
                onPressed: () async {
                  await updateEmail();
                  await updatePassword();
                },
                child: const Text("Save Changes",style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
  }
}