import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageFamilyScreen extends StatelessWidget {
  const ManageFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final uid = user.uid;
    return Scaffold(
      backgroundColor: const Color(0xffEAF6F6),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("family")
              .where("patientUid", isEqualTo: uid)
              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No family members"));
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    children: const [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 10),
                      Text("Manage Family Members",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Add and Manage family member who help support your health.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  /// HOW IT WORKS CARD
                  card(
                    icon: Icons.lightbulb,
                    title: "How it works",
                    subtitle:
                    "Add trusted family members to get reminders, share reports and support you.",
                  ),

                  const SizedBox(height: 15),

                  /// FAMILY MEMBER CARD
                  card(
                    icon: Icons.group,
                    title: "Your Family Member",
                    child: Column(
                      children: docs.map((doc) {

                        final data = doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.teal),
                          ),
                          child: Row(
                            children: [

                              CircleAvatar(
                                radius: 28,
                                backgroundImage: data["profileImageUrl"] != null &&
                                    data["profileImageUrl"] != ""
                                    ? NetworkImage(data["profileImageUrl"])
                                    : null,
                                child: (data["profileImageUrl"] == null ||
                                    data["profileImageUrl"] == "")
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data["fullName"] ?? "",
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(data["relation"] ?? ""),
                                    Text(data["email"] ?? ""),
                                    Text(data["phone"] ?? ""),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );

                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// PERMISSIONS
                  card(
                    icon: Icons.lock,
                    title: "Member permissions",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        permissionItem(Icons.notifications, "Reminders",
                            "Receive session reminders."),

                        permissionItem(Icons.description, "Reports",
                            "View and receive your health reports."),

                        permissionItem(Icons.bar_chart, "Progress",
                            "View your mental health progress."),

                        permissionItem(Icons.history, "History",
                            "View your medical history."),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// DELETE SECTION
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        const Text("Remove family Member",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),

                        const SizedBox(height: 5),

                        const Text("Remove a family member from your account"),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {

                            if (docs.isEmpty) return;

                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Are you sure?"),
                                content: const Text("Delete family member?"),
                                actions: [

                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel")),

                                  TextButton(
                                      onPressed: () async {

                                        await FirebaseFirestore.instance
                                            .collection("family")
                                            .doc(docs.first.id)
                                            .delete();

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Delete")),
                                ],
                              ),
                            );
                          },
                          child: const Text("Remove"),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// INFO BOX
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      "Your information is safe and confidential",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// CARD UI
  Widget card({required IconData icon, required String title, String? subtitle, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffDFF3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle),
          ],

          if (child != null) ...[
            const SizedBox(height: 10),
            child
          ]
        ],
      ),
    );
  }
}

Widget permissionItem(IconData icon, String title, String subtitle){
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(icon, size: 20, color: Colors.teal),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 2),

              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        )
      ],
    ),
  );
}