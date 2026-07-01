import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/routes.dart';
import '../../../common/provider.dart';


class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final Color mainColor = const Color(0xff4E7D7A);
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).cardColor
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= ACCOUNT =================
            _section(
              context,
              title: "Account",
              children: [
                _tile(
                  icon: "assets/icons/lock.png",
                  title: "Change Password",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.psychologistSettings);                  },
                ),
                _tile(
                  icon: "assets/icons/email.png",
                  title: "Update Email",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.psychologistSettings);                  },
                ),

                _tile(
                  icon: "assets/icons/eye.png",
                  title: "Profile Visibility",
                  onTap: () {
                    _showVisibilityDialog(context);
                  },
                ),
              ],
            ),

            /// ================= PREFERENCES =================
            _section(
              context,
              title: "Preferences",
              children: [




            /// ================= APPEARANCE =================

            /// ================= LEGAL =================
            _section(
              context,
              title: "Legal",
              children: [
                _tile(
                  icon: "assets/icons/terms.png",
                  title: "Terms & Conditions",
                  onTap: () {
                    Navigator.pushNamed(context, "/terms");
                  },
                ),
                _tile(
                  icon: "assets/icons/policy.png",
                  title: "Privacy Policy",
                  onTap: () {Navigator.pushNamed(context, "/privacy");},
                ),
              ],
            ),

            /// ================= DATA =================
            _section(
              context,
              title: "Data & Records",
              children: [
                _switchTile(
                  icon: "assets/icons/backup.png",
                  title: "Auto Backup Data",
                  value: true,
                  onChanged: (val) {},
                ),
                _switchTile(
                  icon: "assets/icons/export.png",
                  title: "Export Reports (PDF)",
                  value: true,
                  onChanged: (val) {},
                ),
                _tile(
                  icon: "assets/icons/delete.png",
                  title: "Delete Patient Records",
                  onTap: () {
                    Navigator.pushNamed(context, "/patients");                    },
                ),
              ],
            ),
          ],
        ),
      ]),
    ));
  }

  /// ================= UI COMPONENTS =================

  Widget _section(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding:  EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _tile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(icon, width: 28),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required String icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Image.asset(icon, width: 28),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// ================= DIALOGS =================

  void _showVisibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        String selected = "public";

        return AlertDialog(
          title: const Text("Profile Visibility"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    title: const Text("Public"),
                    value: "public",
                    groupValue: selected,
                    onChanged: (val) {
                      setState(() => selected = val!);
                    },
                  ),
                  RadioListTile(
                    title: const Text("Private"),
                    value: "private",
                    groupValue: selected,
                    onChanged: (val) {
                      setState(() => selected = val!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await firestore.collection("psychologists").doc(uid).update({
                  "profileVisibility": selected,
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Theme Colors"),
        content: Text("Coming Soon"),
      ),
    );
  }

  void _showFontDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Font Size"),
        content: Text("Coming Soon"),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Records"),
        content: const Text("Are you sure you want to delete all records?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Firebase delete logic
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}