import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/translations.dart';
import '../../../common/patient_bottom_nav.dart';
import 'email_setting_screen.dart';
import 'manage_family_screen.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({super.key});

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool enableNotifications = true;
  bool appointmentNotifications = true;

  Future<void> loadSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        enableNotifications = data["enableNotifications"] ?? true;
        appointmentNotifications = data["appointmentNotifications"] ?? true;
      });
    }
  }
  Future<void> saveSettings() async {
    await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .set({
      "enableNotifications": enableNotifications,
      "appointmentNotifications": appointmentNotifications,
    }, SetOptions(merge: true));
  }
  @override
  void initState() {
    super.initState();
    loadSettings();
  }
  String language = "English";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffEAF6F6),

      appBar: AppBar(
        backgroundColor: const Color(0xffEAF6F6),
        elevation: 0,
        title: Text(Translations.t("settings")),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// PROFILE SECTION
            section([
              item("assets/icons/profile.png", "profileSettings", onTap: () {
                Navigator.pushNamed(context, "/patientProfile");
              }),
              item("assets/icons/email.png", "email", onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmailSettingsScreen()),
                );
              }),
              item("assets/icons/family.png", "manageFamily", onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageFamilyScreen()),
                );
              }),            ]),

            /// PRIVACY
            section([
              item("assets/icons/password.png", "changePassword",
              onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EmailSettingsScreen()),
    );
    }),


            ]),


            /// SETTINGS
            section([


              dropdownItem("assets/icons/language.png", "language", language,
                  ["English","اردو"], (v){
                    setState(()=>language=v);

                    /// CHANGE LANGUAGE
                    Translations.isUrdu = v == "اردو";
                  }),

              item("assets/icons/timezone.png", "timeZone", trailing: "GMT+5 Pak"),
            ]),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            ElevatedButton(
              onPressed: () async {
                await saveSettings();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Translations.t("settingsSaved")),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4E7D7A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(Translations.t("SaveChanges"),style: TextStyle(color:Colors.white),),
            )
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        selectedIndex: 0, // 👈 VERY IMPORTANT
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget section(List<Widget> children){
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffDFF3F3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget item(String icon, String key, {String? trailing, VoidCallback? onTap}){
    return ListTile(
      onTap: onTap,
      leading: Image.asset(icon, height: 24),
      title: Text(Translations.t(key)),
      trailing: trailing != null
          ? Text(trailing)
          : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
  Widget toggleItem(String icon, String key, bool value, Function(bool) onChanged){
    return ListTile(
      leading: Image.asset(icon, height: 24),
      title: Text(Translations.t(key)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xff4E7D7A),
      ),
    );
  }

  Widget dropdownItem(String icon, String key, String value,
      List<String> items, Function(String) onChanged){
    return ListTile(
      leading: Image.asset(icon, height: 24),
      title: Text(Translations.t(key)),
      trailing: DropdownButton(
        value: value,
        underline: const SizedBox(),
        items: items.map((e)=>DropdownMenuItem(
          value: e,
          child: Text(e),
        )).toList(),
        onChanged: (val)=>onChanged(val!),
      ),
    );
  }
}