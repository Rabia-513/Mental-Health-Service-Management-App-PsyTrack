import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';

class FamilyEditProfileScreen extends StatefulWidget {
  const FamilyEditProfileScreen({super.key});

  @override
  State<FamilyEditProfileScreen> createState() =>
      _FamilyEditProfileScreenState();
}

class _FamilyEditProfileScreenState extends State<FamilyEditProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  late String patientUid;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final cnicController = TextEditingController();
  final weightController = TextEditingController();
  final isUrdu = Translations.isUrdu;

  DateTime? dob;
  String gender = "Male";
  String maritalStatus = "Single";
  String bloodGroup = "A+";
  String heightFeet = "5";
  String heightInches = "0";

  String imageUrl = "";
  File? imageFile;
  bool loading = false;

  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc =
    await FirebaseFirestore.instance.collection("family").doc(uid).get();

    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;

    firstNameController.text = (data["firstName"] ?? "").toString();
    lastNameController.text = (data["lastName"] ?? "").toString();
    cnicController.text = (data["cnic"] ?? "").toString();
    weightController.text = (data["weightKg"] ?? "").toString();

    if (data["dob"] is Timestamp) {
      dob = (data["dob"] as Timestamp).toDate();
    }

    gender = (data["gender"] ?? "Male").toString();
    maritalStatus = (data["maritalStatus"] ?? "Single").toString();
    bloodGroup = (data["bloodGroup"] ?? "A+").toString();
    heightFeet = (data["heightFeet"] ?? "5").toString();
    heightInches = (data["heightInches"] ?? "0").toString();
    imageUrl = (data["profileImageUrl"] ?? "").toString();

    if (mounted) setState(() {});
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      setState(() {});
    }
  }

  Future<String> uploadImageIfNeeded() async {
    if (imageFile == null) return imageUrl;

    final path = "family-images/$uid.jpg";

    await supabase.storage.from("family-images").upload(
      path,
      imageFile!,
      fileOptions: const FileOptions(upsert: true),
    );

    return supabase.storage.from("family-images").getPublicUrl(path);
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final uploadedUrl = await uploadImageIfNeeded();

      await FirebaseFirestore.instance.collection("family").doc(uid).update({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "fullName":
        "${firstNameController.text.trim()} ${lastNameController.text.trim()}"
            .trim(),
        "cnic": cnicController.text.trim(),
        "dob": dob,
        "gender": gender,
        "maritalStatus": maritalStatus,
        "heightFeet": heightFeet,
        "heightInches": heightInches,
        "bloodGroup": bloodGroup,
        "weightKg": weightController.text.trim(),
        "profileImageUrl": uploadedUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu ? "پروفائل کامیابی سے اپ ڈیٹ ہو گیا" : "Profile updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu ? "پروفائل اپ ڈیٹ نہیں ہو سکا" : "Failed to update profile")),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  String get dobText {
    if (dob == null) return "";
    return "${_monthName(dob!.month)} ${dob!.day}, ${dob!.year}";
  }

  String _monthName(int month) {
    const monthsUrdu = [
      "جنوری",
      "فروری",
      "مارچ",
      "اپریل",
      "مئی",
      "جون",
      "جولائی",
      "اگست",
      "ستمبر",
      "اکتوبر",
      "نومبر",
      "دسمبر"
    ];

    const monthsEn = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return Translations.isUrdu
        ? monthsUrdu[month - 1]
        : monthsEn[month - 1];
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xff2F5F5E),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(color: Color(0xff2F7D79), width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: fieldDecoration(label),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      backgroundColor: const Color(0xffEAF6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        foregroundColor: Colors.white,

        title: Text(isUrdu ? "بنیادی معلومات میں ترمیم" : "Edit Basic Information"),        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  children: [

                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage("assets/images/profile.png")
                      as ImageProvider),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xff4E7D7A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: firstNameController,
                decoration: fieldDecoration(isUrdu ? "پہلا نام" : "First Name"),
                validator: (v) =>
                v == null || v.trim().isEmpty ? isUrdu ? "پہلا نام درج کریں" : "Enter first name": null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: lastNameController,
                decoration: fieldDecoration(isUrdu ? "آخری نام" : "Last Name"),
                validator: (v) =>
                v == null || v.trim().isEmpty ? isUrdu ? "آخری نام درج کریں" : "Enter last name" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: dobText),
                decoration: fieldDecoration(isUrdu ? "تاریخ پیدائش" : "Date of Birth"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dob ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1950, 1, 1),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => dob = picked);
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: cnicController,
                decoration: fieldDecoration(isUrdu ? "شناختی کارڈ نمبر" : "CNIC"),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                      label: isUrdu ? "جنس" : "Gender",
                      value: gender,
                  items: isUrdu
                      ? ["مرد", "عورت"]
                      : ["Male", "Female"],
                      onChanged: (val) {
                        setState(() => gender = val ?? "Male");
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildDropdown(
                      label: isUrdu ? "ازدواجی حیثیت" : "Marital Status",
                      value: maritalStatus,
                        items: isUrdu
                            ? ["اکیلا", "شادی شدہ", "طلاق یافتہ", "بیوہ"]
                            : ["Single", "Married", "Divorced", "Widowed"],
                        onChanged: (val) {
                        setState(() => maritalStatus = val ?? "Single");
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                      label: isUrdu ? "قد" : "Height",
                      value: heightFeet,
                      items: List.generate(8, (i) => "${i + 1}"),
                      onChanged: (val) {
                        setState(() => heightFeet = val ?? "5");
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildDropdown(
                      label: isUrdu ? "انچ" : "Inches",
                      value: heightInches,
                      items: List.generate(12, (i) => "$i"),
                      onChanged: (val) {
                        setState(() => heightInches = val ?? "0");
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                      label: isUrdu ? "خون کا گروپ" : "Blood Group",
                      value: bloodGroup,
                      items: const [
                        "A+",
                        "A-",
                        "B+",
                        "B-",
                        "AB+",
                        "AB-",
                        "O+",
                        "O-"
                      ],
                      onChanged: (val) {
                        setState(() => bloodGroup = val ?? "A+");
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: fieldDecoration(isUrdu ? "وزن (کلوگرام)" : "Weight(KG)"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: loading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2F7D79),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      :  Text(
                      isUrdu ? "محفوظ کریں" : "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FamilyBottomNav(
        selectedIndex: 2,
      ),    ));
  }
}