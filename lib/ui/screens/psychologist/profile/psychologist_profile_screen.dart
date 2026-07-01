import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../common/psychologist_drawer.dart';
import '../../../common/psychologist_bottom_nav.dart';
import '../../../common/psychologist_main_screen.dart';
import '../../styles/colors.dart';
import '../../../../app/routes.dart';

class PsychologistProfileScreen extends StatefulWidget {
  const PsychologistProfileScreen({super.key});

  @override
  State<PsychologistProfileScreen> createState() =>
      _PsychologistProfileScreenState();
}

class _PsychologistProfileScreenState
    extends State<PsychologistProfileScreen> {

   int selectedIndex = 4;
   double averageRating = 0;

  String name = "";
  String email = "";
  int patientCount = 0;
   String psychologistName = "";
   String psychologistEmail = "";
   String? profileImageUrl;


  @override
  void initState() {
    super.initState();
    fetchProfileData();


  }


   Future<void> fetchProfileData() async {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null) return;

     final psychologistDoc = await FirebaseFirestore.instance
         .collection("psychologists")
         .doc(user.uid)
         .get();

     final patientsSnap = await FirebaseFirestore.instance
         .collection("patients")
         .where("psychologistId", isEqualTo: user.uid)
         .get();

     if (psychologistDoc.exists) {
       final data = psychologistDoc.data()!;
       setState(() {
         name = "${data['firstName']} ${data['lastName']}";
         email = data['email'] ?? "";
         profileImageUrl = data['profileImageUrl'];
         patientCount = patientsSnap.docs.length;
         averageRating = (data["averageRating"] ?? 0).toDouble();

       });
     }
   }


  // ================= MENU ITEM =================
  Widget menuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(icon, height: 24),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF3A5A5A),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF3A5A5A),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PsychologistMainScreen(
        selectedIndex: 4, //
   child: Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),

      drawer: const PsychologistDrawer(),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 26,
            ),
            const SizedBox(width: 8),
            const Text(
              "PsyTrack",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= PROFILE IMAGE =================
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  backgroundImage: profileImageUrl != null &&
                      profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null ||
                      profileImageUrl!.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        AppRoutes.editProfile,
                      );

                      if (updated == true) {
                        fetchProfileData(); // or loadProfile()
                      }


                      if (updated == true) {
                        fetchProfileData(); // 🔥 refresh profile
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text(context).withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),



            const SizedBox(height: 12),

            // ================= NAME & INFO =================
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            const Text("Clinical Psychologist"),
            const SizedBox(height: 2),
            const Text(
              "PMDC / License",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 22),

            // ================= STATS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                // Patients
                Column(
                  children: [
                    Image.asset(
                      "assets/images/patients.png",
                      height: 40,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$patientCount+",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text("Patients Treated"),
                  ],
                ),

                // Rating
                Column(
                  children: [
                    Image.asset(
                      "assets/images/rating.png",
                      height: 40,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text("Rating"),
                  ],
                ),

                // Experience
                Column(
                  children: [
                    Image.asset(
                      "assets/images/experience.png",
                      height: 40,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "5 Years",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text("Experience"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= MENU =================
            menuItem(
              icon: "assets/images/info.png",
              title: "Professional Information",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.professionalInfo),
            ),
            menuItem(
              icon: "assets/images/availability.png",
              title: "Availability",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.availability),            ),
            menuItem(
              icon: "assets/images/clinic.png",
              title: "Clinic Details",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.clinicDetails),
            ),
            menuItem(
              icon: "assets/images/about.png",
              title: "About Me",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.aboutMe),
            ),
            menuItem(
              icon: "assets/images/contact.png",
              title: "Contact Details",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.contactDetails),
            ),
            menuItem(
              icon: "assets/images/settings.png",
              title: "Settings",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.psychologistSettings),
            ),
            menuItem(
              icon: "assets/images/logout.png",
              title: "Logout",
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                      (_) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================

    ));
  }
}
