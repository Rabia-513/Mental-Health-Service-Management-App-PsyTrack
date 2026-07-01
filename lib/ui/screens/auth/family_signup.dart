import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/translations.dart';
import '../../../data/services/family_service.dart';

class AddFamilyScreen extends StatefulWidget {
  const AddFamilyScreen({super.key});

  @override
  State<AddFamilyScreen> createState() => _AddFamilyScreenState();
}

class _AddFamilyScreenState extends State<AddFamilyScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final relationController = TextEditingController();

  String gender = "Male";
  String relation = "Father";

  late final List<Map<String, String>> relationItems = [
    {"value": "Father", "label": isUrdu ? "والد" : "Father"},
    {"value": "Mother", "label": isUrdu ? "والدہ" : "Mother"},
    {"value": "Brother", "label": isUrdu ? "بھائی" : "Brother"},
    {"value": "Sister", "label": isUrdu ? "بہن" : "Sister"},
  ];
  DateTime? dob;
  File? imageFile;

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final FamilyService familyService = FamilyService();
  final isUrdu = Translations.isUrdu;
  /// 📸 PICK IMAGE
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// 🔥 CREATE FAMILY ACCOUNT
  Future createFamilyAccount() async {

    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(isUrdu
          ? "خاندانی رکن کامیابی سے شامل ہو گیا"
          : "Family member added successfully")));
      return;
    }

    try {
      setState(() => loading = true);

      /// 1️⃣ CREATE AUTH USER
      /// 🔥 STEP 0: SAVE PATIENT UID FIRST
      final patientUid = FirebaseAuth.instance.currentUser!.uid;

      /// 🔥 STEP 1: CREATE FAMILY ACCOUNT
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final familyUid = cred.user!.uid;

      /// 3️⃣ UPLOAD IMAGE
      String imageUrl = "";
      if (imageFile != null) {
        imageUrl = await familyService.uploadFamilyImage(
          imageFile: imageFile!,
          familyUid: familyUid,
        );
      }

      /// 4️⃣ SAVE DATA
      await familyService.saveFamily(
        familyUid: familyUid,
        patientUid: patientUid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        gender: gender,
        relation: relationController.text.trim(),
        dob: dob,
        imageUrl: imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:  Text(
        isUrdu ? "خاندانی رکن شامل کریں" : "Add Family Member",
        ),),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(isUrdu
          ? "خرابی: $e"
          : "Error: $e")));
    }

    setState(() => loading = false);
  }

  /// 🎨 CUSTOM FIELD (THICK BORDER UI)
  Widget customField({
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    bool obscure = false,
    bool isConfirm = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,

        obscureText: obscure
            ? (isConfirm
            ? obscureConfirmPassword
            : obscurePassword)
            : false,

        decoration: InputDecoration(
          hintText: hint,

          suffixIcon: obscure
              ? IconButton(
            icon: Icon(
              (isConfirm
                  ? obscureConfirmPassword
                  : obscurePassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {

                if (isConfirm) {
                  obscureConfirmPassword =
                  !obscureConfirmPassword;
                } else {
                  obscurePassword = !obscurePassword;
                }

              });
            },
          )
              : null,

          contentPadding:
          const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xff4E7D7A),
              width: 2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xff4E7D7A),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffEAF6F6),
      appBar: AppBar(
        title:  Text(        isUrdu ? "خاندانی رکن شامل کریں" : "Add Family Member",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff4E7D7A),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// PROFILE IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: imageFile != null
                        ? FileImage(imageFile!)
                        : const AssetImage("assets/images/profile.png")
                    as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xff4E7D7A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// RELATION
              customField(

                hint: isUrdu ? "رشتہ" : "Relation",
                controller: relationController,              ),
              /// NAME
              customField(
                hint: isUrdu ? "مکمل نام" : "Full Name",
                controller: nameController,
              ),

              /// DOB
              customField(
                hint: dob == null
                    ? (isUrdu ? "تاریخ پیدائش" : "Date of Birth")
                    : "${dob!.day}/${dob!.month}/${dob!.year}",
                controller: TextEditingController(),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    initialDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => dob = picked);
                  }
                },
              ),

              /// GENDER
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: Text(isUrdu ? "مرد" : "Male"),
                      value: "Male",
                      groupValue: gender,
                      onChanged: (val) =>
                          setState(() => gender = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text(isUrdu ? "عورت" : "Female"),
                      value: "Female",
                      groupValue: gender,
                      onChanged: (val) =>
                          setState(() => gender = val!),
                    ),
                  ),
                ],
              ),

              customField(
                hint: isUrdu ? "فون نمبر" : "Phone Number",
                controller: phoneController,
              ),

              customField(
                hint: isUrdu ? "ای میل" : "Email",
                controller: emailController,
              ),

              customField(
                hint: isUrdu ? "پاس ورڈ" : "Password",
                controller: passwordController,
                obscure: true,
              ),

              customField(
                hint: isUrdu ? "پاس ورڈ کی تصدیق" : "Confirm Password",
                controller: confirmPasswordController,
                obscure: true,
                isConfirm: true,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : createFamilyAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4E7D7A),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isUrdu ? "خاندانی رکن شامل کریں" : "Add Family Member",
                  style: const TextStyle(color: Colors.white),
                ),  ),
            ],
          ),
        ),
      ),
    );
  }
}