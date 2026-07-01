import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../../app/language_provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/translations.dart';
import '../../../common/patient_bottom_nav.dart';
import '../../styles/colors.dart';


class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {

  Map<String, dynamic>? data;
  final isUrdu = Translations.isUrdu;
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        data = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    String calculateAge(Timestamp? dob) {
      if (dob == null) return "--";
      final birth = dob.toDate();
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month) age--;
      return age.toString();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEAF6F6),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/patient-dashboard", // 🔥 IMPORTANT
                  (route) => false,
            );
          },
        ),

        title: Text(Translations.t("editProfile")),
      ),
      backgroundColor: AppColors.card(context),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              /// PROFILE IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xff4E7D7A),
                    backgroundImage: data!["profileImageUrl"] != null &&
                        data!["profileImageUrl"] != ""
                        ? NetworkImage(data!["profileImageUrl"])
                        : null,
                    child: (data!["profileImageUrl"] == null ||
                        data!["profileImageUrl"] == "")
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.patienteditProfile);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              Text(
                "${data!["firstName"]} ${data!["lastName"]}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Text(data!["email"] ?? "", style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              /// INFO GRID
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
                children: [
                  infoItem("assets/images/blood.png",
                      isUrdu ? "خون کا گروپ" : "Blood Group",
                      data!["bloodGroup"] ?? "--"),
                  infoItem("assets/images/age.png",
                      isUrdu ? "عمر" : "Age",
                      calculateAge(data!["dob"])),
                  infoItem("assets/images/gender.png",
                      isUrdu ? "جنس" : "Gender",
                      data!["gender"] ?? "--"),
                  infoItem("assets/images/maritial.png",
                      isUrdu ? "ازدواجی حیثیت" : "Marital",
                      data!["maritalStatus"] ?? "--"),
                  infoItem("assets/images/height.png",
                      isUrdu ? "قد" : "Height",
                      data!["height"] ?? "--"),
                  infoItem("assets/images/weight.png",
                      isUrdu ? "وزن" : "Weight",
                      data!["weight"] ?? "--"),                ],
              ),

              const SizedBox(height: 20),

              /// CONTACT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUrdu ? "رابطہ کی معلومات" : "Contact Details",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.patienteditProfile);
                    },
                  )
                ],
              ),

              const Divider(),

              Text(
                isUrdu
                    ? "فون: ${data!["phone"]}"
                    : "Phone: ${data!["phone"]}",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        selectedIndex: 0, // 👈 VERY IMPORTANT
      ),
    );
  }

  Widget infoItem(String image, String title, String value) {
    return Column(
      children: [
        Image.asset(image, height: 40),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}