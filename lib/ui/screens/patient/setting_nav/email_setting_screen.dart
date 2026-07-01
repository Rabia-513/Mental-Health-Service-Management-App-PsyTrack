import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/translations.dart';

class EmailSettingsScreen extends StatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  State<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends State<EmailSettingsScreen> {
  final isUrdu = Translations.isUrdu;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  @override
  void initState() {
    super.initState();
    loadEmail();
  }

  void loadEmail() {
    final user = FirebaseAuth.instance.currentUser;
    emailController.text = user?.email ?? "";
  }

  // ================= UPDATE EMAIL =================
  Future<void> updateEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await user.verifyBeforeUpdateEmail(emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(isUrdu ? "محفوظ کریں" : "Save Changes"),),
    );
  }

  // ================= UPDATE PASSWORD =================
  Future<void> updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await user.updatePassword(passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isUrdu ? "پاس ورڈ اپ ڈیٹ ہو گیا" : "Password updated")),
    );
  }

  // ================= SAVE =================
  Future<void> saveChanges() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {

      /// 1. SEND EMAIL VERIFICATION LINK
      if (emailController.text != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification link sent to new email")),
        );
      }

      /// 2. UPDATE PASSWORD (ONLY IF ENTERED)
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      backgroundColor: const Color(0xffEAF6F6),

      appBar: AppBar(
        title: Text(isUrdu ? "ای میل" : "Email"),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: Text(isUrdu ? "اکاؤنٹ کی ترتیبات" : "Account Settings",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(()=>obscure=!obscure),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: isUrdu ? "ای میل اپ ڈیٹ کریں" : "Update Email",
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4E7D7A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(Translations.t("saveChanges"),style: TextStyle(color:Colors.white),),
              onPressed: saveChanges,

            )
          ],
        ),
      ),
    ));
  }
}