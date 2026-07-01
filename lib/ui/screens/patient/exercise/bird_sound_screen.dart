import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/translations.dart';

class BirdSoundScreen extends StatelessWidget {
  const BirdSoundScreen({super.key});

  String tr(String key) => Translations.t(key);
  bool get isUrdu => Translations.isUrdu;

  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/odEUBurPo5M?si=5QLkrP4Vfmy23h3Q",
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
        backgroundColor: const Color(0xFFF4F6F6),

        /// 🔹 APP BAR
        appBar: AppBar(
          backgroundColor: const Color(0xFF4F7C7A),
          foregroundColor: Colors.white,
          title: Text(tr("birdTitle")),

        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// 🔹 TOP CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage:
                      AssetImage("assets/icons/birds.png"),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr("birdTitle"),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(tr("birdDesc")),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip("assets/icons/time.png", tr("durationTime")),
                    const SizedBox(width: 10),
                    _chip("assets/icons/headphone1.png", tr("audio")),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 BUTTONS
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF4F7C7A),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: openVideo,
                    icon: const Icon(Icons.play_arrow,color:Colors.white),
                    label: Text(tr("start"),style: TextStyle(color:Colors.white),),
                  ),


                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 HOW IT WORKS
              _section(
                tr("howItWorks"),
                Column(
                  children: [
                    Text(tr("birdHowDesc")),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _step("assets/icons/listen.png", tr("step1")),
                          const SizedBox(width: 15),
                          _step("assets/images/breathe.png", tr("step2")),
                          const SizedBox(width: 15),
                          _step("assets/images/relax.png", tr("step3")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 EXPECT
              _section(
                tr("whatExpect"),
                SingleChildScrollView(
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
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 TIPS
              _section(
                tr("tips"),
                Column(
                  children: [
                    _tip("assets/icons/headphone1.png",
                        tr("tip1")),
                    _tip("assets/icons/closeye.png",
                        tr("tip2")),
                    _tip("assets/icons/combinebreath.png",
                        tr("tip3")),
                    _tip("assets/icons/comfortable.png",
                        tr("tip4")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 WIDGETS

  Widget _chip(String icon, String text) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 10),
          child
        ],
      ),
    );
  }

  Widget _step(String icon, String text) {
    return Column(
      children: [
        Image.asset(icon, width: 40),
        const SizedBox(height: 5),
        Text(text),
      ],
    );
  }

  Widget _icon(String icon, String text) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Image.asset(icon, width: 32),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
  Widget _tip(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(icon, width: 35),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}