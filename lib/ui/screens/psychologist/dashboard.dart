import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/ui/screens/psychologist/schedule/select_patient_screen.dart';

import '../../../app/routes.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';

class PsychologistDashboard extends StatefulWidget {
  const PsychologistDashboard({super.key});

  @override
  State<PsychologistDashboard> createState() =>
      _PsychologistDashboardState();
}

class _PsychologistDashboardState extends State<PsychologistDashboard> {
  List<DocumentSnapshot> notifications = [];
  bool showNotificationDropdown = false;
  String psychologistName = "";
  String psychologistEmail = "";
  bool isLoadingProfile = true;
  int totalPatients = 0;
  int todaySessions = 0;
  int completedSessions = 0;
  int pendingRequests = 0;

  List<DocumentSnapshot> todaySchedule = [];
  List<DocumentSnapshot> recentPatients = [];
  // 🔹 TEMP: no users yet
  int todaysSessions = 0;

  int selectedIndex = 1;

  int get hour => DateTime.now().hour;

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 15) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  String get bannerImage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "assets/images/morning_banner.PNG";
    } else {
      return "assets/images/evening_banner.PNG";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPsychologistFromCloud();
    fetchTotalPatients();
    listenNotifications();
    loadDashboardData();
  }
  Future<void> loadDashboardData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // TOTAL PATIENTS
    final patientsSnap = await FirebaseFirestore.instance
        .collection("patient_psychologist_connections")
        .where("psychologistUid", isEqualTo: uid)
        .get();

    // TODAY SESSIONS
    final today = DateTime.now();
    final todayDate = "${today.year}-${today.month}-${today.day}";

    final sessionsSnap = await FirebaseFirestore.instance
        .collection("sessions")
        .where("psychologistId", isEqualTo: uid)
        .get();

    int todayCount = 0;
    int completedCount = 0;

    List<DocumentSnapshot> todayList = [];

    for (var doc in sessionsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final todayDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      if (data["date"] == todayDate) {
        todayCount++;
        todayList.add(doc);
      }

      completedCount = sessionsSnap.docs.length;
    }

    // PENDING REQUESTS
    final appointmentSnap = await FirebaseFirestore.instance
        .collection("appointments")
        .where("psychologistId", isEqualTo: uid)
        .where("status", isEqualTo: "pending")
        .get();

    // RECENT PATIENTS
    final connectionsSnap = await FirebaseFirestore.instance
        .collection("patient_psychologist_connections")
        .where("psychologistUid", isEqualTo: uid)
        .get();

    List<DocumentSnapshot> patientDocs = [];

    for (var conn in connectionsSnap.docs) {
      final data = conn.data();
      final patientUid = data["patientUid"];

      final patientDoc = await FirebaseFirestore.instance
          .collection("patients")
          .doc(patientUid)
          .get();

      if (patientDoc.exists) {
        patientDocs.add(patientDoc);
      }
    }

    setState(() {
      recentPatients = patientDocs;
    });

    setState(() {
      totalPatients = patientsSnap.docs.length;
      todaySessions = todayCount;
      completedSessions = completedCount;
      pendingRequests = appointmentSnap.docs.length;
      todaySchedule = todayList;
      recentPatients = patientDocs; // ✅ CORRECT
    });
  }
  Future<void> fetchTotalPatients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("patients")
        .where("psychologistId", isEqualTo: user.uid)
        .get();

    setState(() {
      totalPatients = snapshot.docs.length;
    });
  }

  Future<void> fetchPsychologistFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('psychologists')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          psychologistName =
          "${doc['firstName']} ${doc['lastName']}";
          psychologistEmail = doc['email'];
          isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching psychologist: $e");
      setState(() => isLoadingProfile = false);
    }
  }
  void listenNotifications() {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("notifications")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {

      setState(() {
        notifications = snapshot.docs;
      });

    });

  }
  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),

      // ================= APP BAR (UNCHANGED) =================
      appBar: AppBar(
        backgroundColor: AppColors.card(context),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 30),

            Image.asset("assets/images/logo.png", height: 26),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "PSY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2A5A), // dark blue
                      letterSpacing: 1,
                    ),
                  ),
                  TextSpan(
                    text: "TRACK",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1AA39A), // teal
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),          ],
        ),
        actions: [
          Stack(
            children: [

              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    showNotificationDropdown = !showNotificationDropdown;
                  });
                },
              ),

              if (notifications.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifications.length.toString(),
                      style:  TextStyle(
                          color: AppColors.card(context), fontSize: 10),
                    ),
                  ),
                )
            ],
          )        ],
      ),

      // ================= DRAWER (UNCHANGED) =================
      drawer: Drawer(
        backgroundColor: const Color(0xFFE9F6F6),
        child: Column(
          children: [
            const SizedBox(height: 50),
           CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.card(context),
              child: Icon(Icons.person,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              isLoadingProfile ? "Loading..." : psychologistName,
              style: AppTextStyles.bodyBold,
            ),
            Text(psychologistEmail,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            drawerBtn(Icons.home, "Home"),
            drawerBtn(Icons.people, "My Patients"),
            drawerBtn(Icons.assignment, "Assessments"),
            drawerBtn(Icons.folder, "Records"),
            drawerBtn(Icons.settings, "Settings"),
            drawerBtn(Icons.description, "Terms & Conditions"),
            drawerBtn(Icons.privacy_tip, "Privacy Policy"),
            drawerBtn(Icons.event, "Help and Support"),


            const Spacer(),
            drawerBtn(Icons.logout, "Logout",
                color: Colors.red),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(



          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showNotificationDropdown)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text(context).withOpacity(0.1),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  children: notifications.map((doc) {

                    final data = doc.data() as Map<String, dynamic>;

                    return Dismissible(

                      key: Key(doc.id),

                      direction: DismissDirection.endToStart,

                      onDismissed: (direction) async {

                        await FirebaseFirestore.instance
                            .collection("notifications")
                            .doc(doc.id)
                            .delete();

                      },

                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child:  Icon(Icons.delete, color: AppColors.card(context)),
                      ),

                      child: ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(data["title"]),
                        subtitle: Text(data["message"]),
                        onTap: () {

                          Navigator.pushNamed(
                            context,
                            AppRoutes.psychologistSchedule,
                          );


                        },

                      ),

                    );

                  }).toList(),
                ),
              ),
            // SEARCH
            TextField(
              onChanged: (value) async {
                final results = await FirebaseFirestore.instance
                    .collection("patients")
                    .get();

                final filtered = results.docs.where((doc) {
                  final data = doc.data();
                  final name =
                  "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".toLowerCase();                  return name.contains(value.toLowerCase());
                }).toList();

                setState(() {
                  recentPatients = filtered;
                });
              },
              decoration: InputDecoration(
                hintText: "Search patient...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ================= GREETING BANNER (FIXED) =================
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      bannerImage,
                      fit: BoxFit.cover, // ✅ prevents overflow
                    ),
                    Container(
                      color: AppColors.text(context).withOpacity(0.25),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            greetingText,
                            style: AppTextStyles.welcomeText
                                .copyWith(color: AppColors.card(context)),
                          ),
                          Text(
                            isLoadingProfile
                                ? "Dr. ..."
                                : "Dr. $psychologistName",
                            style: AppTextStyles.bodyBold
                                .copyWith(color: AppColors.card(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "You have $todaySessions sessions today",
                            style:  TextStyle(
                                color: AppColors.card(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= STATS (ZERO VALUES) =================
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                statTile(Icons.person,"Total Patients", totalPatients),
                statTile(Icons.calendar_today, "Today's Sessions", todaySessions),
                statTile(Icons.hourglass_bottom,"Pending Request", pendingRequests),
                statTile(Icons.check_circle,"Completed Sessions", completedSessions),
              ],
            ),

            const SizedBox(height: 16),

            // ================= ACTION BUTTONS (UNCHANGED) =================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/addPatient",
                        arguments: {
                          "fromPsychologist": true,
                          "psychologistId": FirebaseAuth.instance.currentUser!.uid,
                        },
                      );

                    },
                    child: actionBtn(Icons.person_add, "Add Patient"),
                  ),

                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelectPatientScreen(),
                        ),
                      );

                    },
                    child:  actionBtn(Icons.calendar_today, "Create Session"),

                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.managePatients);
                    },
                    child: actionBtn(Icons.person_add, "Manage Patients"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text("Recent Patients",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            SizedBox(height: 12),

            recentPatients.isEmpty
                ? Text("No patients found")
                : Column(
              children: recentPatients.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final name =
                    "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}";

                final parts = name.trim().split(" ").where((e) => e.isNotEmpty).toList();

                final initials = parts.isNotEmpty
                    ? parts.map((e) => e[0]).take(2).join()
                    : "NA";
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(initials),
                      ),
                      SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(fontWeight: FontWeight.bold)),

                            SizedBox(height: 4),

                            Text(
                              "Recently Opened",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.managePatients);

                        },
                        child: Text("View Patient"),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            Text("Today's Schedule",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            SizedBox(height: 12),

            todaySchedule.isEmpty
                ? Text("No sessions today")
                : Column(
              children: todaySchedule.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final name = data["patientName"] ?? "";
                final initials = name.isNotEmpty
                    ? name.split(" ").map((e) => e[0]).take(2).join()
                    : "NA";

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(initials),
                      ),
                      SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: TextStyle(fontWeight: FontWeight.bold)),

                            SizedBox(height: 4),

                            Text(
                              "Time: ${data["startTime"]}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.managePatients);                        },
                        child: Text("View Patient"),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),          ],
        ),
      ),

      // ================= BOTTOM NAV (UNCHANGED) =================
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [

            // 🔹 MAIN BAR
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text(context).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bottomNavItem(
                      icon: Icons.settings,
                      label: "Setting",
                      index: 0,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.psySetting);
                      },
                    ),
                    bottomNavItem(
                      icon: Icons.pie_chart,
                      label: "Stats",
                      index: 1,

                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.statsPatients);
                      },
                    ),
                    const SizedBox(width: 48), // space for home
                    bottomNavItem(
                      icon: Icons.check_box_outlined,
                      label: "Schedule",
                      index: 3,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.psychologistSchedule,
                        );
                      },
                    ),
                    bottomNavItem(
                      icon: Icons.person_outline,
                      label: "Profile",
                      index: 4,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.psychologistProfile,
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),

            // 🔥 FLOATING HOME BUTTON (ABOVE BAR)
            Positioned(
              top: -5,
              child: GestureDetector(
                onTap: () => setState(() => selectedIndex = 2),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: selectedIndex == 2
                        ? AppColors.primary
                        : AppColors.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text(context).withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home,
                    size: 28,
                    color: selectedIndex == 2
                        ? AppColors.card(context)
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),



    );
  }

  // ================= COMPONENTS =================
  Widget statTile(IconData icon, String title, int value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 ICON CIRCLE
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.text(context),
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 6),

          // 🔹 VALUE
          Text(
            value.toString(),
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionBtn(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 🔑 KEY
        children: [
          Icon(icon, color: AppColors.card(context), size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.buttonWhite.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }



  Widget bottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    VoidCallback? onTap,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap ?? () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.card(context) : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget drawerBtn(IconData icon, String text,
      {Color color = AppColors.primary}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);

        switch (text) {
          case "Home":
            Navigator.pushNamed(context, AppRoutes.psychologistDashboard);
            break;

          case "My Patients":
            Navigator.pushNamed(context, AppRoutes.managePatients);
            break;

          case "Assessments":
            Navigator.pushNamed(context, AppRoutes.startAssessment);
            break;

          case "Records":
            Navigator.pushNamed(context, "/patients");
            break;

          case "Settings":
            Navigator.pushNamed(context, AppRoutes.psychologistSettings);
            break;

          case "Terms & Conditions":
            Navigator.pushNamed(context, "/terms");
            break;

          case "Privacy Policy":
            Navigator.pushNamed(context, "/privacy");
            break;
          case "Help and Support":
            Navigator.pushNamed(context, "/support");
            break;

          case "Logout":
            FirebaseAuth.instance.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (_) => false);
            break;
        }
      },
    );
  }
}
