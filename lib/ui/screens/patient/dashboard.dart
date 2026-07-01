import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/routes.dart';
import '../../../app/translations.dart';
import '../../common/patient_bottom_nav.dart';
import '../../common/patient_drawer.dart';
import '../styles/colors.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  TextEditingController searchController = TextEditingController();
  int navIndex = 2;
  int bannerIndex = 0;
  int selectedMood = -1;
  String patientName = "";
  String profileImage = "";
  String patientCode="";

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  final List<Map<String, String>> tips = [
    {
      "en": "Taking a short walk can reduce anxiety and refresh your mind.",
      "ur": "مختصر چہل قدمی بے چینی کم کر سکتی ہے اور ذہن کو تازہ کرتی ہے۔"
    },
    {
      "en": "Deep breathing for 5 minutes helps calm the nervous system.",
      "ur": "پانچ منٹ تک گہری سانس لینے سے اعصابی نظام پرسکون ہوتا ہے۔"
    },
    {
      "en": "Writing your thoughts in a journal can improve emotional clarity.",
      "ur": "اپنے خیالات کو ڈائری میں لکھنا جذباتی وضاحت کو بہتر بناتا ہے۔"
    },
    {
      "en": "Listening to relaxing music helps reduce stress.",
      "ur": "پرسکون موسیقی سننا ذہنی دباؤ کو کم کرنے میں مدد دیتا ہے۔"
    },
    {
      "en": "Talking to someone you trust improves mental wellbeing.",
      "ur": "کسی قابل اعتماد شخص سے بات کرنا ذہنی صحت کو بہتر بناتا ہے۔"
    }
  ];
  List<DocumentSnapshot> notifications = [];
  bool showNotificationDropdown = false;
  late Map<String, String> randomTip;
  @override
  void initState() {
    super.initState();

    randomTip = tips[Random().nextInt(tips.length)];
    loadPatientData();
    listenNotifications();
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
  Future<void> loadPatientData() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(uid)
        .get();

    if (doc.exists) {

      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        patientName = data["firstName"] ?? "";
        profileImage = data["profileImageUrl"] ?? "";
        patientCode = data["patientCode"] ?? "";
      });

    }
  }  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.card(context),
      drawer: const PatientDrawer(),
    body: Directionality(
    textDirection: Translations.isUrdu
    ? TextDirection.rtl
        : TextDirection.ltr,
    child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// MENU
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu, size: 28),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),

                  /// LOGO + NAME
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        height: 30,
                      ),
                      const SizedBox(width: 6),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "PSY",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2A5A),
                              ),
                            ),
                            TextSpan(
                              text: "TRACK",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1AA39A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// ONLY NOTIFICATION HERE
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
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
                              style: TextStyle(
                                color: AppColors.card(context),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color: !Translations.isUrdu
                                ? Colors.teal
                                : Colors.grey.shade300,
                            child: Text(
                              "Eng",
                              style: TextStyle(color: AppColors.card(context)),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color: Translations.isUrdu
                                ? Colors.teal
                                : Colors.grey.shade300,
                            child: Text(
                              "اردو",
                              style: TextStyle(color: AppColors.card(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


              /// ✅ MOVE IT HERE
              if (showNotificationDropdown)
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
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
                          child: Icon(Icons.delete, color: AppColors.card(context)),
                        ),

                        child: ListTile(
                          leading: const Icon(Icons.notifications),
                          title: Text(data["title"] ?? ""),
                          subtitle: Text(data["body"] ?? ""),
                        ),
                      );

                    }).toList(),
                  ),
                ),

              const SizedBox(height: 10),
              /// HELLO
              /// ✅ IMPROVED HELLO SECTION
              Row(
                children: [

                  /// PROFILE IMAGE
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profileImage.isNotEmpty
                        ? NetworkImage(profileImage)
                        : null,
                    child: profileImage.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  /// NAME + ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "${Translations.t("hello")}, $patientName 👋",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${Translations.t("patientCode")}: $patientCode",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),

              /// SEARCH BAR
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  Navigator.pushNamed(
                    context,
                    "/searchScreen",
                    arguments: value,
                  );
                },
                decoration: InputDecoration(
                  hintText: Translations.t("search"),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// BANNER SLIDER
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  viewportFraction: 1,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() => bannerIndex = index);
                  },
                ),
                items: banners.map((image) {

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );

                }).toList(),
              ),

              const SizedBox(height: 10),

              Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: bannerIndex,
                  count: banners.length,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.teal,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// MOOD TEXT
              Text(
                  Translations.t("howFeeling"),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                Translations.t("moodExplain"),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              /// MOOD BUTTONS
              /// CHECK MOOD BUTTON
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4E7D7A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {

                    /// Navigate to mood screen later
                    Navigator.pushNamed(context,  AppRoutes.patientMoodCheckIn);

                  },
                  icon:  Icon(Icons.auto_awesome, color: AppColors.card(context)),
                  label: Text(
                    Translations.t("moodCheckIn"),
                    style:  TextStyle(
                      color: AppColors.card(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const AllowedFormsSection(),
              /// ACTION GRID
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,                ),
                children: [

                  actionCard(
                    "assets/images/add_family.png",
                    Translations.t("addFamilyMember"),
                    Translations.t("addNow"),
                    onTap: () {
                      Navigator.pushNamed(context, "/addFamily");
                    },

                  ),

                  actionCard(
                    "assets/images/book.png",
                    Translations.t("bookAppointment"),
                      Translations.t("Appointment"),                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.psychologistList);
                    },
                  ),

                  actionCard(
                    "assets/images/prescription.png",
                    Translations.t("digitalPrescription"),
                    Translations.t("download"),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.familyPrescriptions,
                        arguments: {
                          "patientUid": FirebaseAuth.instance.currentUser!.uid,
                          "patientName": patientName,
                          "profileImage": profileImage,
                        },
                      );
                    },
                  ),

                  actionCard(
                    "assets/images/progress.png",
                    Translations.t("mentalProgress"),
                    Translations.t("trackNow"),
                    onTap: (){
                      Navigator.pushNamed(context, AppRoutes.patientgraph);
                    },
                  ),

                ],
              ),

              const SizedBox(height: 25),

              /// TODAY TASK
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffe6f2ef),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            Translations.t("todayTask"),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),
                          Text(
                            Translations.t("todayTaskDesc"),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            Translations.t("CompleteNow"),
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),

                    Image.asset(
                      "assets/images/task.png",
                      height: 60,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// TIP OF DAY
              Text(
                Translations.t("tipDay"),                style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 18),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Text(
                        Translations.isUrdu
                            ? randomTip["ur"]!
                            : randomTip["en"]!,
                        textDirection: Translations.isUrdu
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),

                    const Icon(
                      Icons.lightbulb,
                      color: Colors.orange,
                      size: 40,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),



              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    ),
      bottomNavigationBar:  PatientBottomNav(
        selectedIndex: 2,
      ),    );
  }

  Widget actionCard(String image, String title, String button, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.text(context).withOpacity(0.06),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              button,
              style: const TextStyle(color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }}




class AllowedFormsSection extends StatelessWidget {
  const AllowedFormsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patient_psychologist_connections')
          .where('patientUid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) return const SizedBox();
        final connectionId = doc.id;
        final historyAllowed = data['historyAllowed'] ?? false;
        final consentAllowed = data['consentAllowed'] ?? false;
        final historySubmitted = data['historySubmitted'] ?? false;
        final consentSubmitted = data['consentSubmitted'] ?? false;
        final patientUid = data['patientUid'] ?? '';
        final patientCode = data['patientCode'] ?? '';
        final psychologistUid = data['psychologistUid'] ?? '';

        final shouldShowCard =
            (historyAllowed || consentAllowed) &&
                !(historySubmitted && consentSubmitted);

        if (!shouldShowCard) {
          return const SizedBox();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffDDE9E6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xff2F6F6D), size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Action Required",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2F6F6D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Before continue, please complete the following:",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xff456B69),
                ),
              ),
              const SizedBox(height: 14),

              if (consentAllowed)
                _formRow(
                  context: context,
                  icon: Icons.fact_check_outlined,
                  title: "Consent Form",
                  completed: consentSubmitted,
                  onTap: consentSubmitted
                      ? null
                      : () {
                    Navigator.pushNamed(
                      context,
                      '/consent', // keep this if your route already works
                      arguments: {
                        'connectionId': connectionId,
                        'patientUid': patientUid,
                        'patientCode': patientCode,
                        'psychologistUid': psychologistUid,
                      },
                    );
                  },
                ),

              if (historyAllowed)
                _formRow(
                  context: context,
                  icon: Icons.history_edu,
                  title: "History Form",
                  completed: historySubmitted,
                  onTap: historySubmitted
                      ? null
                      : () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.mainHistory,
                      arguments: {
                        'connectionId': connectionId,
                        'patientUid': patientUid,
                        'patientCode': patientCode,
                        'psychologistUid': psychologistUid,
                      },
                    );
                  },
                ),

              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.hourglass_bottom,
                      color: Color(0xff9C6B00), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Takes only 5-7 minutes",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff456B69),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Why we need this?\nThis helps your psychologist understand you better 💙",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xff456B69),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _formRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool completed,
    required VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff2F6F6D), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.grey.shade400
                      : const Color(0xff2F7D79),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.card(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            completed ? "(Completed)" : "(Not completed)",
            style: TextStyle(
              color: completed ? Colors.green : Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("userId", isEqualTo: uid)
          .orderBy("createdAt", descending: true)
          .limit(3) // show only latest 3
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Dismissible(
              key: Key(doc.id),

              /// SWIPE TO DELETE
              onDismissed: (direction) {
                FirebaseFirestore.instance
                    .collection("notifications")
                    .doc(doc.id)
                    .delete();
              },

              background: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),

              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF4E5), // light alert color
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [

                    const Icon(Icons.notifications, color: Colors.orange),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            data["title"] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            data["body"] ?? "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

          }).toList(),
        );
      },
    );
  }
}