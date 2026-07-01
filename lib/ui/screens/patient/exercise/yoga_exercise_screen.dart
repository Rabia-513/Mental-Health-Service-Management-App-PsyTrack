import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/translations.dart';

class YogaExerciseScreen extends StatelessWidget {
  const YogaExerciseScreen({super.key});

  String tr(String key) => Translations.t(key);

  bool get isUrdu => tr("hello") == "سلام";
  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/VrQ3s-7sBtk?si=piLTYpgYr3aFQGQu",
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
          foregroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(tr("yogaTitle")),

        ),

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
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFCFE3E3),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/images/yoga.png",
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr("calmnessYoga"),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tr("yogaIntro"),
                            style: const TextStyle(
                              height: 1.5,
                              color: Color(0xFF2F5D5C),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= INFO =================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  _infoBox("assets/icons/time.png",
                      "5-10 min", tr("duration")),
                  _infoBox("assets/icons/level.png",
                      tr("beginner"), tr("level")),
                  _infoBox("assets/icons/relaxing.png",
                      tr("available"), tr("audio")),
                ],
              ),

              const SizedBox(height: 15),

              // ================= START =================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: openVideo,
                    icon: const Icon(Icons.play_arrow,color: Colors.white),
                    label: Text(tr("startExercise"),style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF4F7C7B),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                ],
              ),

              const SizedBox(height: 20),

              // ================= HOW IT WORKS =================
              _sectionCard(
                title: tr("howItWorks"),
                subtitle: tr("yogaHow"),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    _circleStep("assets/images/warmup.png", tr("warmUp")),
                    _arrow(),
                    _circleStep("assets/images/breathe.png", tr("breathe")),
                    _arrow(),
                    _circleStep("assets/images/focus.png", tr("basicPoses")),
                    _arrow(),
                    _circleStep("assets/images/refocus.png", tr("relax")),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= EXPECT =================
              _sectionCard(
                title: tr("whatExpect"),
                subtitle: tr("expectDesc"),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _icon("assets/images/brain.png",
                        tr("reduceStress")),
                    _icon("assets/images/yoga.png",
                        tr("improveFlexibility")),
                    _icon("assets/images/reducestress.png",
                        tr("reduceStress")),
                    _icon("assets/images/focus.png",
                        tr("enhanceFocus")),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= TIPS =================
              _sectionCard(
                title: tr("tips"),
                child: Column(
                  children: [
                    _tip(tr("tip1")),
                    _tip(tr("tip2")),
                    _tip(tr("tip3")),
                    _tip(tr("tip4")),
                    _tip(tr("tip5")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _infoBox(String img, String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8FBABA)),
      ),
      child: Row(
        children: [
          Image.asset(img, height: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(sub,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEAEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8FBABA)),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          if (subtitle != null) Text(subtitle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _circleStep(String img, String text) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFCFE3E3),
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset(img, height: 30),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _arrow() {
    return const Icon(Icons.arrow_forward,
        color: Colors.blue, size: 20);
  }

  Widget _icon(String img, String text) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFCFE3E3),
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset(img, height: 30),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 70,
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        )
      ],
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}