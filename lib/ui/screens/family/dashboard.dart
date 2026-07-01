import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/translations.dart';
import '../../../data/services/family_dashboard_service.dart';
import '../../common/family_bottom_nav.dart';
import '../../common/translated_text.dart';
import 'main_screens/family_upload_report_screen.dart';

class FamilyDashboard extends StatefulWidget {
  const FamilyDashboard({super.key});

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard> {
  final FamilyDashboardService service = FamilyDashboardService();
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> filteredNotifications = [];
  String fullName = "";
  String relation = "";
  String profileImageUrl = "";
  String patientUid = "";

  @override
  void initState() {
    super.initState();
    loadFamilyData();

  }
  List<DocumentSnapshot> notifications = [];
  bool showNotificationDropdown = false;


  Future<void> loadFamilyData() async {
    final data = await service.getFamilyData();

    if (data != null) {
      setState(() {
        fullName = data["fullName"] ?? "";
        relation = data["relation"] ?? "";
        profileImageUrl = data["profileImageUrl"] ?? "";
        patientUid = data["patientUid"] ?? "";

      });
      listenNotifications();
    }
  }

  void listenNotifications() {

    FirebaseFirestore.instance
        .collection("notifications")
        .where("userId", isEqualTo: patientUid)
        .snapshots()
        .listen((snapshot) {

      setState(() {
        notifications = snapshot.docs;
      });

    });
  }
  String getBannerImage() {
    final hour = DateTime.now().hour;
    if (hour < 15) {
      return "assets/images/morning_banner.PNG";
    }
    return "assets/images/evening_banner.PNG";
  }

  String todayDate() {
    final now = DateTime.now();
    return "${now.day} ${monthName(now.month)}, ${now.year}";
  }

  String monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return "";
    final dt = ts.toDate();

    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? "PM" : "AM";

    return "${dt.day} ${monthName(dt.month)}, ${dt.year} | $hour:$minute $ampm";
  }

  Future<void> openPdfUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  void onBottomTap(int index) {
    if (index == 2) return;

    // replace these with your routes
    // if (index == 0) Navigator.pushNamed(context, "/familySettings");
    // if (index == 1) Navigator.pushNamed(context, "/familyHistory");
    // if (index == 3) Navigator.pushNamed(context, "/familyAppointments");
    // if (index == 4) Navigator.pushNamed(context, "/familyProfile");
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = Translations.isUrdu;

    return Directionality(
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffEAF6F6),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 54,
                        ),
                        const SizedBox(width: 8),

                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Translations.isUrdu = false;
                                  });
                                },
                                child: Container(
                                  color: !Translations.isUrdu
                                      ? const Color(0xff466F6D)
                                      : Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: const Text(
                                    "Eng",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Translations.isUrdu = true;
                                  });
                                },
                                child: Container(
                                  color: Translations.isUrdu
                                      ? const Color(0xff466F6D)
                                      : Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: const Text(
                                    "اردو",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (patientUid.isEmpty)
                          const Icon(
                            Icons.notifications_none,
                            color: Color(0xff466F6D),
                            size: 28,
                          )
                        else
                          StreamBuilder<QuerySnapshot>(
                            stream: service.getUnreadNotifications(patientUid),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;

                              return Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_none, size: 28),
                                    onPressed: () {
                                      setState(() {
                                        showNotificationDropdown = !showNotificationDropdown;
                                      });
                                    },
                                  ),

                                  if (count > 0)
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              );
                            },
                          ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 18),

                /// SEARCH
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.8),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      final query = value.toLowerCase();

                      setState(() {
                        filteredNotifications = notifications.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final title = (data["title"] ?? "").toString().toLowerCase();
                          final msg = (data["message"] ?? "").toString().toLowerCase();

                          return title.contains(query) || msg.contains(query);
                        }).toList();
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: isUrdu
                          ? "رپورٹس، اپائنٹمنٹس، نسخے تلاش کریں..."
                          : "Search prescriptions, appointments, reports...",
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                if (showNotificationDropdown)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: (searchController.text.isEmpty ? notifications : filteredNotifications)
                          .map((doc) {

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
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(data["title"] ?? ""),
                            subtitle: Text(data["message"] ?? ""),
                          ),
                        );

                      }).toList(),
                    ),
                  ),

                /// BANNER
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    image: DecorationImage(
                      image: AssetImage(getBannerImage()),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child:Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        /// PROFILE IMAGE
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),

                        const SizedBox(width: 12),

                        /// TEXT SECTION
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                "${Translations.t("hello")}!",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                relation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 18),
                                  const SizedBox(width: 6),
                                  Text(todayDate()),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// EDIT PROFILE BUTTON
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/family-profile");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff5E8C8A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isUrdu ? "ایڈٹ" : "Edit",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  isUrdu ? "آپ کیا کر سکتے ہیں؟" : "What You Can Do?",
                  style: const TextStyle(
                    color: Color(0xff466F6D),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                /// ACTION CARDS
                Row(
                  children: [
                    Expanded(
                      child: actionCard(
                        imagePath: "assets/images/prescription.png",
                        title: isUrdu ? "نسخے" : "Prescription",
                        subtitle: isUrdu
                            ? "مریض کی دوا کی فہرست"
                            : "Patient medicine list",
                        buttonText: isUrdu ? "دیکھیں" : "View",
                        ontap: () {
                          Navigator.pushNamed(
                            context,
                            "/family-prescriptions",
                            arguments: {
                              "patientUid": patientUid,
                              "patientName": fullName,
                              "profileImage": profileImageUrl,
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: actionCard(
                        imagePath: "assets/images/schedule.jpg",
                        title: isUrdu ? "شیڈول" : "Schedules",
                        subtitle: isUrdu
                            ? "مریض کی آئندہ اپائنٹمنٹس"
                            : "Patient  appointments",
                        buttonText: isUrdu ? "دیکھیں" : "View",
                        ontap: () {
                          Navigator.pushNamed(
                            context,
                            "/family-schedule",
                            arguments: {
                              "patientUid": patientUid,
                            },
                          );                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: actionCard(
                        imagePath: "assets/images/freport.png",
                        title: isUrdu ? "نئی رپورٹ شامل کریں" : " Report",
                        subtitle: isUrdu
                            ? "میڈیکل رپورٹ اور فائل اپ لوڈ کریں"
                            : "Upload  reports ",
                        buttonText: isUrdu ? "اپ لوڈ" : "Upload",
                        ontap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FamilyUploadReportScreen(
                                patientUid: patientUid,
                              ),
                            ),
                          );                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// UPCOMING SESSION
                if (patientUid.isNotEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("sessions")
                        .where("patientUid", isEqualTo: patientUid)
                        .orderBy("followUpDate")
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SizedBox();
                      }

                      final doc = snapshot.data!.docs.first;
                      final data = doc.data() as Map<String, dynamic>;

                      final Timestamp? followUp = data["followUpDate"];
                      final String sessionType = data["sessionType"] ?? "";

                      final String formatted = formatTimestamp(followUp);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF6F5),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xffD5E6E3), width: 2),
                        ),
                        child: Row(
                          children: [

                            Image.asset("assets/images/bell.png", height: 60),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isUrdu ? "آنے والا سیشن" : "Upcoming Session",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff466F6D),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "$formatted\n$sessionType",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff5D7F7B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child:Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            "/family-prescriptions",                                            arguments: {
                                              "patientUid": patientUid,
                                              "patientName": fullName,
                                              "profileImage": profileImageUrl,
                                            },
                                          );
                                        },
                                        child: Text(
                                          isUrdu ? "تمام رپورٹس دیکھیں" : "View All Reports",
                                          style: const TextStyle(
                                            color: Color(0xff466F6D),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),

                                  )
                                ],
                              ),
                            ),

                            const Icon(Icons.chevron_right, color: Color(0xff5D7F7B))
                          ],
                        ),
                      );
                    },
                  ),


                const SizedBox(height: 24),

                Text(
                  isUrdu ? "حالیہ رپورٹس" : "Recent Reports",
                  style: const TextStyle(
                    color: Color(0xff466F6D),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                /// LATEST PRESCRIPTION PDF
                if (patientUid.isNotEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("patient_psychologist_connections")
                        .where("patientUid", isEqualTo: patientUid)
                        .where("status", isEqualTo: "active")
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SizedBox();
                      }

                      final doc = snapshot.data!.docs.first;
                      final data = doc.data() as Map<String, dynamic>;


                      final pdfUrl = data["latestPrescriptionPdfUrl"];
                      if (pdfUrl == null || pdfUrl.toString().isEmpty) {
                        return const SizedBox();
                      }
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [

                            Image.asset("assets/images/pdf.png", height: 40),

                            const SizedBox(width: 10),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Prescription.pdf",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Latest prescription"),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.teal),
                              onPressed: () async {

                                final url = Uri.parse(pdfUrl);

                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication, // 🔥 opens Chrome
                                );
                              },
                            )                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/family-prescriptions",
                        arguments: {
                          "patientUid": patientUid,
                          "patientName": fullName,
                          "profileImage": profileImageUrl,
                        },
                      );
                    },
                    child: Text(
                      isUrdu ? "تمام رپورٹس دیکھیں" : "View All Reports",
                      style: const TextStyle(
                        color: Color(0xff466F6D),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FamilyBottomNav(
          selectedIndex: 2,
        ),
      ),
    );
  }

  Widget actionCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback ontap,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xffF4F7F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffD9D9D9),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 86),

          const SizedBox(height: 8),

          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff466F6D),
                fontWeight: FontWeight.bold,
              )),

          const SizedBox(height: 6),

          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),

          const SizedBox(height: 10),

          /// 🔥 CLICKABLE BUTTON
          GestureDetector(
            onTap: ontap,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff5E8C8A),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}