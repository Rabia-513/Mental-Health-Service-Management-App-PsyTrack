import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/styles/colors.dart';
import '../../app/routes.dart';

class PsychologistDrawer extends StatefulWidget {
  const PsychologistDrawer({super.key});

  @override
  State<PsychologistDrawer> createState() => _PsychologistDrawerState();
}

class _PsychologistDrawerState extends State<PsychologistDrawer> {
  String name = "";
  String email = "";
  String imageUrl = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          name = (data["name"] ?? "").toString().isNotEmpty
              ? data["name"]
              : "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}";

          email = data["contactDetails"]?["email"] ??
              data["email"] ??
              "";

          imageUrl = data["profileImageUrl"] ?? "";

          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Drawer error: $e");
    }
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3A5A5A)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Color(0xFF3A5A5A)),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEAF6F6),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ✅ HEADER
            Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).cardColor,
                  backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(height: 8),

                Text(
                  loading ? "Loading..." : name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),

                Text(
                  loading ? "" : email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// MENU
            drawerItem(
              icon: Icons.home_outlined,
              title: "Home",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                    context, AppRoutes.psychologistDashboard);
              },
            ),

            drawerItem(
              icon: Icons.people_outline,
              title: "My Patients",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.managePatients);
              },
            ),

            drawerItem(
              icon: Icons.assignment_outlined,
              title: "Assessments",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.startAssessment);
              },
            ),

            drawerItem(
              icon: Icons.folder_open_outlined,
              title: "Records",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/patients");              },
            ),

            drawerItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/psySetting"
                );
              },
            ),

            drawerItem(
              icon: Icons.support_agent,
              title: "Help & Support",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/support");
              },
            ),

            drawerItem(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/terms");
              },
            ),

            drawerItem(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/privacy");
              },
            ),

            const Spacer(),

            drawerItem(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}