import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/translations.dart';
import '../../../common/patient_bottom_nav.dart';

class PatientEditProfileScreen extends StatefulWidget {
  const PatientEditProfileScreen({super.key});

  @override
  State<PatientEditProfileScreen> createState() => _PatientEditProfileScreenState();
}

class _PatientEditProfileScreenState extends State<PatientEditProfileScreen> {

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  final isUrdu = Translations.isUrdu;
  DateTime? dob;

  String gender = "Male";
  String maritalStatus = "Single";
  String bloodGroup = "A+";

  String imageUrl = "";
  File? imageFile;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .get();

    final data = doc.data();

    firstName.text = data?["firstName"] ?? "";
    lastName.text = data?["lastName"] ?? "";
    phone.text = data?["phone"] ?? "";
    height.text = data?["height"] ?? "";
    weight.text = data?["weight"] ?? "";

    gender = data?["gender"] ?? "Male";
    maritalStatus = data?["maritalStatus"] ?? "Single";
    bloodGroup = data?["bloodGroup"] ?? "A+";

    if (data?["dob"] != null) {
      dob = (data!["dob"] as Timestamp).toDate();
    }

    imageUrl = data?["profileImageUrl"] ?? "";

    setState(() {});
  }

  // 📅 DATE PICKER
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      setState(() {});
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) return imageUrl;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final path = "patients/$uid/profile.jpg";

    await supabase.storage
        .from("patient-profile")
        .upload(path, imageFile!,
        fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from("patient-profile").getPublicUrl(path);
  }

  Future<void> saveChanges() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final uploadedUrl = await uploadImage();

    await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .update({
      "firstName": firstName.text,
      "lastName": lastName.text,
      "phone": phone.text,
      "gender": gender,
      "height": height.text,
      "weight": weight.text,
      "bloodGroup": bloodGroup,
      "maritalStatus": maritalStatus,
      "dob": dob,
      "profileImageUrl": uploadedUrl,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffEAF6F6),

      appBar: AppBar(
        backgroundColor: const Color(0xffEAF6F6),
        elevation: 0,
        title: Text(Translations.t("editProfile")),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// PROFILE IMAGE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffDFF3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : (imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null) as ImageProvider?,
                        child: imageFile == null && imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text("${firstName.text} ${lastName.text}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  Text(phone.text),
                ],
              ),
            ),

            const SizedBox(height: 15),
            buildCard( isUrdu ? "ذاتی معلومات" : "Personal Information", [
              field(firstName, isUrdu ? "پہلا نام" : "First Name"),
              field(lastName, isUrdu ? "آخری نام" : "Last Name"),
              dateField(),
              dropdown( isUrdu ? "جنس" : "Gender", gender, ["Male","Female","Other"],
                      (v)=>setState(()=>gender=v)),
              dropdown(  isUrdu ? "ازدواجی حیثیت" : "Marital Status", maritalStatus,
                  ["Single","Married","Divorced","Widowed"],
                      (v)=>setState(()=>maritalStatus=v)),
            ]),

            buildCard(isUrdu ? "رابطہ کی معلومات" : "Contact Information", [
              field(phone, isUrdu ? "فون نمبر" : "Phone Number"),
            ]),

            buildCard(isUrdu ? "صحت کی معلومات" : "Health Information", [
              dropdown(  isUrdu ? "خون کا گروپ" : "Blood Group", bloodGroup,
                  ["A+","A-","B+","B-","O+","O-","AB+","AB-"],
                      (v)=>setState(()=>bloodGroup=v)),
              field(height, isUrdu ? "قد" : "Height"),
              field(weight, isUrdu ? "وزن" : "Weight"),
            ]),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4E7D7A),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isUrdu ? "محفوظ کریں" : "Save Changes",style: TextStyle(color: Colors.white),),            )
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        selectedIndex: 0, // 👈 VERY IMPORTANT
      ),
    );
  }

  /// CARD
  Widget buildCard(String title, List<Widget> children){
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffDFF3F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    );
  }

  /// TEXT FIELD
  Widget field(TextEditingController controller, String label){
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  /// DATE FIELD
  Widget dateField(){
    return GestureDetector(
      onTap: pickDate,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dob == null
                  ? (isUrdu ? "تاریخ پیدائش منتخب کریں" : "Select Date of Birth")
                  : "${dob!.day}/${dob!.month}/${dob!.year}",
            ),
            const Icon(Icons.calendar_today)
          ],
        ),
      ),
    );
  }

  /// DROPDOWN
  Widget dropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChange,
      ) {
    final isUrdu = Translations.isUrdu;

    String translate(String e) {
      if (!isUrdu) return e;

      return {
        "Male": "مرد",
        "Female": "عورت",
        "Other": "دیگر",

        "Single": "غیر شادی شدہ",
        "Married": "شادی شدہ",
        "Divorced": "طلاق یافتہ",
        "Widowed": "بیوہ",

        "A+": "A+",
        "A-": "A-",
        "B+": "B+",
        "B-": "B-",
        "O+": "O+",
        "O-": "O-",
        "AB+": "AB+",
        "AB-": "AB-",
      }[e] ?? e;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: value,
        items: items.map((e) {
          return DropdownMenuItem(
            value: e, // 🔥 keep English for Firebase
            child: Text(translate(e)), // 🔥 show Urdu
          );
        }).toList(),
        onChanged: (val) => onChange(val!),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }}