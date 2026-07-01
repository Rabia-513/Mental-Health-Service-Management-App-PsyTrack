import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/routes.dart';
import '../../../app/translations.dart';
import '../screens/styles/colors.dart';

class PatientDrawer extends StatefulWidget {
  const PatientDrawer({super.key});

  @override
  State<PatientDrawer> createState() => _PatientDrawerState();
}

class _PatientDrawerState extends State<PatientDrawer> {

  String patientName = "";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .get();

    if (doc.exists) {

      final data = doc.data()!;

      setState(() {
        patientName = data["firstName"] ?? "";
        profileImage = data["profileImageUrl"] ?? "";
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(

      child: SafeArea(

        child: ListView(

          padding: EdgeInsets.zero,

          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xffE6F2EF),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundImage: profileImage.isEmpty
                        ? const AssetImage("assets/images/profile.png")
                        : NetworkImage(profileImage) as ImageProvider,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    patientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4E7D7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.patientProfile
                      );

                    },
                    child: Text(
                      Translations.t("viewprofile"),
                      style:  TextStyle(color: AppColors.card(context)),
                    ),
                  )

                ],
              ),
            ),

            const SizedBox(height: 10),

            /// MAIN
            sectionTitle("main"),
            drawerItemIcon(
                Icons.home_outlined,
                Translations.t("home"),
                    () {
                  Navigator.pushNamed(context, AppRoutes.patientDashboard);
                }
            ),

            drawerItemImage(
                "assets/icons/mood.png",
                Translations.t("id_moodTracker"),                    () {    Navigator.pushNamed(context, AppRoutes.patientMoodCheckIn);
                    }
            ),

            drawerItemImage(
                "assets/icons/mood_history.png",
                Translations.t("id_moodHistory"),
                    () {Navigator.pushNamed(context, AppRoutes.patientgraph);}
            ),

            drawerItemIcon(
              Icons.qr_code_2_outlined,
              Translations.t("id_myQr"),
                  () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.patientQrCode);
              },
            ),

            const Divider(),

            /// WELLNESS
            sectionTitle("wellness"),

            drawerItemImage(
                "assets/icons/breathing.png",
                Translations.t("id_breathing"),
                    () {    Navigator.pushNamed(context, "/breathing-exercises");
                    }
            ),

            drawerItemImage(
                "assets/icons/relaxing.png",
                Translations.t("id_relaxing"),
                    () {Navigator.pushNamed(context, "/relaxing-sounds");}
            ),



            const Divider(),

            /// RECORDS
            sectionTitle("records"),

            drawerItemIcon(
                Icons.medical_services_outlined,
                Translations.t("id_prescriptions"),
                    () {  Navigator.pushNamed(
                      context,
                      AppRoutes.familyPrescriptions,
                      arguments: {
                        "patientUid": FirebaseAuth.instance.currentUser!.uid,
                        "patientName": patientName,
                        "profileImage": profileImage,
                      },
                    );}
            ),


            const Divider(),

            /// SUPPORT
            sectionTitle("support"),
            drawerItemImage(
                "assets/icons/family.png",
                Translations.t("id_addFamilyMember"),
                    () { Navigator.pushNamed(context, "/addFamily");}
            ),

            drawerItemImage(
                "assets/icons/emergency.png",
                Translations.t("id_emergencyContact"),                    () {Navigator.pushNamed(context, "/emergency");}
            ),

            drawerItemIcon(
                Icons.star_rate,
              Translations.t("RateDoctor"),
                    () {
                  Navigator.pushNamed(context, "/rate-doctor");
                }
            ),

            const Divider(),

            drawerItemIcon(
                Icons.settings,
                Translations.t("settings"),
                    () {Navigator.pushNamed(context, AppRoutes.patSetting);}
            ),

            drawerItemImage(
                "assets/icons/terms.png",
                Translations.t("id_terms"),                    () { Navigator.pop(context);
                    Navigator.pushNamed(context, "/terms");}
            ),

            const Divider(),

            /// LOGOUT
            drawerItemImage(
                "assets/icons/logout.png",
                Translations.t("id_logout"),                    () async {

                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login
                  );

                }
            ),

          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget sectionTitle(String textKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        Translations.t(textKey),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
  /// ITEM WITH IMAGE
  Widget drawerItemImage(String image, String text, VoidCallback onTap) {

    return ListTile(

      leading: Image.asset(
        image,
        height: 24,
        width: 24,
      ),

      title: Text(text),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: onTap,

    );
  }

  /// ITEM WITH ICON
  Widget drawerItemIcon(IconData icon, String text, VoidCallback onTap) {

    return ListTile(

      leading: Icon(icon),

      title: Text(text),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: onTap,

    );
  }

}