import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/language_provider.dart';
import '../../../../app/routes.dart';
import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF1F7F6),

      appBar: AppBar(
        title:  Text(Translations.isUrdu ? "سیٹنگز" : "Settings"),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff2F6F6D),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              Translations.isUrdu
                  ? "اپنے اکاؤنٹ اور ترجیحات کو منظم کریں"
                  : "Manage your account and preferences",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            /// 🔥 PROFILE SECTION
            _sectionCard(
              children: [

                _tile(
                  icon: "assets/icons/profile.png",
                  title: Translations.isUrdu ? "پروفائل سیٹنگز" : "Profile Settings",                  onTap: () {
                    Navigator.pushNamed(context,    "/family-profile");
                  },
                ),

                _divider(),

                _tile(
                  icon: "assets/icons/email.png",
                  title: Translations.isUrdu ? "ای میل" : "Email",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emailSettings);
                  },
                ),



            const SizedBox(height: 16),

            /// 🔥 SECURITY SECTION
            _sectionCard(
              children: [


                _tile(
                  icon: "assets/icons/password.png",
    title: Translations.isUrdu ? "پاس ورڈ تبدیل کریں" : "Change Password",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emailSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔥 SETTINGS OPTIONS
            _sectionCard(
              children: [

                _languageDropdownTile(),

                _divider(),

                _dropdownTile(
                  icon: "assets/icons/timezone.png",
                  title: Translations.isUrdu ? "ٹائم زون" : "Time Zone",
                  value: Translations.isUrdu ? "جی ایم ٹی +5 پاکستان" : "GMT+5 Pk",
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 SAVE BUTTON
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2F6F6D),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  Translations.isUrdu ? "تبدیلیاں محفوظ کریں" : "Save Changes",
                  style: const TextStyle(color: Colors.white),
                ),              ),
            ),

            const SizedBox(height: 80),
          ],
        ),

      ]),

    ),
      bottomNavigationBar: FamilyBottomNav(
      selectedIndex: 0,
    ),);
  }

  /// 🔥 CARD
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  /// 🔥 NORMAL TILE
  Widget _tile({
    required String icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Image.asset(icon, height: 28),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  /// 🔥 SWITCH TILE

  Widget _switchTile({
    required String icon,
    required String title,
    String? subtitle,
    required String field,
  }) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("family")
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final data =
        snapshot.data!.data() as Map<String, dynamic>?;

        bool value = data?[field] ?? true;

        return ListTile(
          leading: Image.asset(icon, height: 28),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: Switch(
            value: value,
            onChanged: (v) async {

              await FirebaseFirestore.instance
                  .collection("family")
                  .doc(uid)
                  .set({
                field: v,
              }, SetOptions(merge: true)); // 🔥 IMPORTANT
            },
          ),
        );
      },
    );
  }
  /// 🔥 DROPDOWN TILE
  Widget _dropdownTile({
    required String icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Image.asset(icon, height: 28),
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(value),
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade300);
  }
}

Widget _languageDropdownTile() {
  final uid = FirebaseAuth.instance.currentUser!.uid;


  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("family")
        .doc(uid)
        .snapshots(),
    builder: (context, snapshot) {

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const SizedBox();
      }

      final data =
      snapshot.data!.data() as Map<String, dynamic>?;

      String currentLang = data?["language"] ?? "en";

      return ListTile(
        leading: Image.asset("assets/icons/language.png", height: 28),
        title: Text(
          Translations.isUrdu
              ? "زبان کی ترجیحات"
              : "Language Preferences",
        ),
        trailing: DropdownButton<String>(
          value: currentLang,
          underline: const SizedBox(),

          items: const [
            DropdownMenuItem(value: "en", child: Text("English")),
            DropdownMenuItem(value: "ur", child: Text("اردو")),
          ],

          onChanged: (value) async {

            if (value == null) return;

            /// 🔥 SAVE TO FIRESTORE
            await FirebaseFirestore.instance
                .collection("family")
                .doc(uid)
                .set({
              "language": value,
            }, SetOptions(merge: true));

            /// 🔥 UPDATE GLOBAL STATE
            Provider.of<LanguageProvider>(context, listen: false)
                .setLanguage(value == "ur");
            /// force rebuild
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.familySettings,
            );
          },
        ),
      );
    },
  );
}