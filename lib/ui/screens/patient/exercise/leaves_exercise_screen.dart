import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/translations.dart';


class LeavesExerciseScreen extends StatefulWidget {
  const LeavesExerciseScreen({super.key});

  @override
  State<LeavesExerciseScreen> createState() =>
      _LeavesExerciseScreenState();
}

class _LeavesExerciseScreenState
    extends State<LeavesExerciseScreen> {

  final player = AudioPlayer();

  String tr(String key) => Translations.t(key);
  bool get isUrdu => tr("hello") == "سلام";

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }



  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/7SK2gFocOpw?si=LDz_5ZpHYDOzU7Ie",
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
          title: Text(tr("leavesTitle"),style: TextStyle(color: Colors.white),),

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
                        "assets/images/leaves.png",
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr("leavesIntro"),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF2F5D5C),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ================= INFO BOX =================
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _infoBox("assets/icons/time.png", tr("durationTime"), tr("duration")),
                      const SizedBox(width: 8),
                      _infoBox("assets/icons/level.png", tr("beginner"), tr("level")),
                      const SizedBox(width: 8),
                      _infoBox("assets/icons/relaxing.png", tr("audioAvailable"), tr("audio")),
                    ],
                  ),
                ),              ),

              const SizedBox(height: 15),

              // ================= START BUTTON =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: openVideo,
                    icon: const Icon(Icons.play_arrow,color:Colors.white ,),
                    label: Text(tr("startExercise") ,style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F7C7B),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
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
                subtitle: tr("leavesHowDesc"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _step("assets/images/leaves.png", tr("imagine")),
                      _arrow(),
                      _step("assets/images/notice.png", tr("notice")),
                      _arrow(),
                      _step("assets/images/place.png", tr("place")),
                      _arrow(),
                      _step("assets/images/letgo.PNG", tr("letGo")),
                    ],
                  ),
                ),              ),

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
                      _icon("assets/images/tension2.png", tr("relieveTension")),
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

  // ================= UI HELPERS =================

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
        mainAxisSize: MainAxisSize.min,
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
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.grey,
            ),
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
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
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
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        )
      ],
    );
  }
  Widget _arrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward,
          color: Colors.blue, size: 20),
    );
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
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
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
              color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }}