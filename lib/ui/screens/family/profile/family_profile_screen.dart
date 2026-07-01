import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';


class FamilyProfileScreen extends StatelessWidget {
  const FamilyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Translations.isUrdu;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final patientUid = args?["patientUid"] ?? "";

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xffEAF6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        foregroundColor: Colors.white,

        title: Text(isUrdu ? "خاندانی پروفائل" : "Family Profile"),        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("family")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists || snapshot.data!.data() == null) {
            return  Center(child: Text(isUrdu ? "پروفائل نہیں ملا" : "Profile not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final firstName = (data["firstName"] ?? "").toString();
          final lastName = (data["lastName"] ?? "").toString();
          final fullName = ((firstName + " " + lastName).trim().isNotEmpty)
              ? "${firstName.trim()} ${lastName.trim()}".trim()
              : (data["fullName"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added").toString()
          );

          final email = (data["email"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final phone = (data["phone"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final cnic = (data["cnic"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final gender = (data["gender"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final maritalStatus = (data["maritalStatus"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final bloodGroup = (data["bloodGroup"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();

          final heightFeet = (data["heightFeet"] ?? "").toString();
          final heightInches = (data["heightInches"] ?? "").toString();
          final weightKg = (data["weightKg"] ?? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")).toString();
          final imageUrl = (data["profileImageUrl"] ?? "").toString();

          final dobRaw = data["dob"];
          final ageText = _calculateAgeText(dobRaw);
          final heightText = (heightFeet.isEmpty && heightInches.isEmpty)
              ? (isUrdu ? "شامل نہیں کیا گیا" : "Not added")
              : isUrdu
              ? "$heightFeet فٹ ${heightInches.isEmpty ? '0' : heightInches} انچ"
              : "$heightFeet ft ${heightInches.isEmpty ? '0' : heightInches} in";

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage("assets/images/profile.png")
                      as ImageProvider,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/edit-family-profile");
                        },
                        child: Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xff4E7D7A)),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xff4E7D7A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff2F5F5E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cnic,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/blood.png",
                        title: isUrdu ? "خون کا گروپ" : "Blood Group",
                        value: bloodGroup,
                      ),
                    ),
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/age.png",
                        title: isUrdu ? "عمر" : "Age",
                        value: ageText,
                      ),
                    ),
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/gender.png",
                        title: isUrdu ? "جنس" : "Gender",
                        value: gender,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/maritial.png",
                        title: isUrdu ? "ازدواجی حیثیت" : "Marital Status",
                        value: maritalStatus,
                      ),
                    ),
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/height.png",
                        title: isUrdu ? "قد" : "Height",
                        value: heightText,
                      ),
                    ),
                    Expanded(
                      child: _infoItem(
                        imagePath: "assets/images/weight.png",
                        title: isUrdu ? "وزن" : "Weight",
                        value: weightKg == "Not added"
                            ? weightKg
                            : "$weightKg kg",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Color(0xff2F7D79),
                          ),
                          const SizedBox(width: 8),
                           Text(
                            isUrdu ? "رابطہ کی معلومات" : "Contact Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff2F7D79),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "/edit-family-profile");
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xff2F5F5E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                     Text(
          isUrdu ? "فون نمبر" : "Phone Number",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FamilyBottomNav(
        selectedIndex: 4,
      ),    );
  }

  Widget _infoItem({
    required String imagePath,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 38,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAgeText(dynamic dobRaw) {
    if (dobRaw == null) {
      return Translations.isUrdu ? "شامل نہیں کیا گیا" : "Not added";
    }
    DateTime? dob;
    if (dobRaw is Timestamp) {
      dob = dobRaw.toDate();
    } else if (dobRaw is DateTime) {
      dob = dobRaw;
    }

    if (dob == null) return "Not added";

    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age.toString();
  }
}