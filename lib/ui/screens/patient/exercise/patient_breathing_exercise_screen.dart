import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/translations.dart';
import '../../styles/colors.dart';

class BreathingExercisesScreen extends StatelessWidget {
  const BreathingExercisesScreen({super.key});

  String tr(String key) => Translations.t(key);

  bool get isUrdu => tr("hello") == "سلام";
  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://www.youtube.com/watch?v=7SK2gFocOpw",
    );

    await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7F7),

        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: const Color(0xFF4F7C7B),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(
            tr("breathingExercises"),
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        // ================= BODY =================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // ================= TOP CARD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEAEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr("breathingIntro"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2F5D5C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 🔥 IMAGE (lungs)
                    Image.asset(
                      "assets/images/lungs.png",
                      height: 70,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= TITLE =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr("calmingTechniques"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F5D5C),
                    ),
                  ),
                  Image.asset(
                    "assets/icons/search.png",
                    height: 20,
                  )
                ],
              ),

              const SizedBox(height: 5),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr("chooseExercise"),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 15),

              // ================= CARDS =================
              _exerciseCard(
                context,
                image: "assets/images/pmr.png",
                title: tr("pmr"),
                subtitle: tr("pmrDesc"),
                duration: tr("10-15 min"),
                onTap: () {
                  Navigator.pushNamed(context, "/pmr-exercise");
                },
              ),

              _exerciseCard(
                context,
                image: "assets/images/leaves.png",
                title: tr("leaves"),
                subtitle: tr("leavesDesc"),
                duration: tr("10-15 min"),
                onTap: () {
                  Navigator.pushNamed(context, "/leaves-exercise");
                },
              ),

              _exerciseCard(
                context,
                image: "assets/images/meditation.png",
                title: tr("meditation"),
                subtitle: tr("meditationDesc"),
                duration: tr("10-15 min"),
                onTap: () {
                  Navigator.pushNamed(context, "/meditation-exercise");
                },
              ),

              _exerciseCard(
                context,
                image: "assets/images/yoga.png",
                title: tr("yoga"),
                subtitle: tr("yogaDesc"),
                duration: tr("10-15 min"),
                onTap: () {
                  Navigator.pushNamed(context, "/yoga-exercise");
                },
              ),

              _exerciseCard(
                context,
                image: "assets/images/guided.png",
                title: tr("guidedImagery"),
                subtitle: tr("guidedDesc"),
                duration: tr("10-15 min"),
                onTap: () {
                  Navigator.pushNamed(context, "/guided-imagery");
                },
              ),

              const SizedBox(height: 20),

              // ================= FOLLOW GUIDE =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEAEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr("followGuide"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F5D5C),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _guideItem(
                        "assets/icons/search.png",
                        tr("findQuiet")),
                    _guideItem(
                        "assets/icons/rhythm.png",
                        tr("followRhythm")),
                    _guideItem(
                        "assets/icons/repeat.png",
                        tr("repeat")),
                    _guideItem(
                        "assets/icons/sit.png",
                        tr("sitComfort")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _exerciseCard(
      BuildContext context, {
        required String image,
        required String title,
        required String subtitle,
        required String duration,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F5), // 👈 soft green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8FBABA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TOP ROW =================
          Row(
            children: [

              // IMAGE
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E8E8),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(image, height: 40),
              ),

              const SizedBox(width: 12),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ================= TIME + LEVEL =================
          Row(
            children: [

              // ⏱ TIME IMAGE
              Image.asset(
                "assets/icons/time.png",
                height: 18,
              ),
              const SizedBox(width: 5),
              Text(duration),

              const SizedBox(width: 20),

              // 🎯 LEVEL IMAGE
              Image.asset(
                "assets/icons/level.png",
                height: 18,
              ),
              const SizedBox(width: 5),
              Text(tr("beginner")),
            ],
          ),

          const SizedBox(height: 12),

          // ================= START BUTTON =================
          Center(
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7C7B),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(tr("start",),style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GUIDE ITEM =================
  Widget _guideItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 6),
      child: Row(
        children: [
          Image.asset(icon, height: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}