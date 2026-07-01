import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/translations.dart';

class MeditationExerciseScreen extends StatelessWidget {
  const MeditationExerciseScreen({super.key});

  String tr(String key) => Translations.t(key);
  bool get isUrdu => tr("hello") == "سلام";

  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/JslvBcIVtDg?si=04VuTvBG9TMcxoL9",
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
          title: Text(tr("meditationTitle")),

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
                        "assets/images/meditation.png",
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
                            tr("mindfulnessMeditation"),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tr("meditationIntro"),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _infoBox("assets/icons/time.png", "10-20 min", tr("duration")),
                    const SizedBox(width: 8),
                    _infoBox("assets/icons/level.png", tr("beginner"), tr("level")),
                    const SizedBox(width: 8),
                    _infoBox("assets/icons/relaxing.png", tr("available"), tr("audio")),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ================= START =================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: openVideo,
                    icon: const Icon(Icons.play_arrow,color:Colors.white),
                    label: Text(tr("startExercise"),style: TextStyle(color:Colors.white),),
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
                subtitle: tr("meditationHow"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _step("assets/images/confort.png", tr("comfort")),
                      _arrow(),
                      _step("assets/images/breathe.png", tr("breathe")),
                      _arrow(),
                      _step("assets/images/focus.png", tr("focus")),
                      _arrow(),
                      _step("assets/images/refocus.png", tr("refocus")),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= EXPECT =================
              _sectionCard(
                title: tr("whatExpect"),
                subtitle: tr("expectDesc"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _icon("assets/images/brain.png", tr("reduceStress")),
                      const SizedBox(width: 12),
                      _icon("assets/images/sleep.png", tr("improveSleep")),
                      const SizedBox(width: 12),
                      _icon("assets/images/tension.png", tr("relieveTension")),
                      const SizedBox(width: 12),
                      _icon("assets/images/boost.png", tr("boostMood")),
                    ],
                  ),
                ),              ),

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
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8FBABA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(img, height: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
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

  Widget _step(String img, String text) {
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
          width: 60,
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        )
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
          const Icon(Icons.check_circle,
              color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}