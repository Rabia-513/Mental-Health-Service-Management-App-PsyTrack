import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/translations.dart';

class ForestSoundScreen extends StatelessWidget {
  const ForestSoundScreen({super.key});

  bool get isUrdu => Translations.isUrdu;

  String tr(String en, String ur) => isUrdu ? ur : en;
  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/AK-N2AdoTlg?si=WDxu-i5MHvt5gJFv",
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
          title: Text(tr("Forest Bird Sound", "جنگل کی آواز")),

        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// 🔹 TOP CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8E6CF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage:
                      AssetImage("assets/icons/forest.png"),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr("Forest Sound", "جنگل کی آواز"),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(
                              "Let the soothing sound of the forest surround you, helping to ease stress and calm your mind.",
                              "جنگل کی پرسکون آواز آپ کو گھیر لے گی جو ذہنی دباؤ کم کرے اور سکون دے۔",
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 CHIPS
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  _chip("assets/icons/time.png",
                      tr("5-10 min", "5-10 منٹ")),
                  _chip("assets/icons/headphone1.png",
                      tr("Audio Available", "آڈیو دستیاب")),
                ],
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
                    icon: const Icon(Icons.play_arrow,color: Colors.white),
                    label: Text(tr("Start", "شروع کریں"),style: TextStyle(color: Colors.white),),
                  ),

                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 HOW IT WORKS
              _section(
                tr("How it Works", "یہ کیسے کام کرتا ہے"),
                Column(
                  children: [
                    Text(
                      tr(
                        "Listen to calming forest sounds and relax deeply.",
                        "جنگل کی آواز سنیں اور گہرا سکون حاصل کریں۔",
                      ),
                    ),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _step("assets/icons/listen.png", tr("Listen", "سنیں")),
                          const SizedBox(width: 15),
                          _step("assets/images/breathe.png", tr("Breathe", "سانس")),
                          const SizedBox(width: 15),
                          _step("assets/images/relax.png", tr("Relax", "آرام")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 EXPECT
              _section(
                tr("What to Expect", "کیا توقع رکھیں"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _icon("assets/images/brain.png", tr("Reduces stress", "دباؤ کم")),
                      const SizedBox(width: 12),
                      _icon("assets/images/sleep.png", tr("Improves sleep", "نیند بہتر")),
                      const SizedBox(width: 12),
                      _icon("assets/images/tension.png", tr("Relieves tension", "تناؤ کم")),
                      const SizedBox(width: 12),
                      _icon("assets/images/boost.png", tr("Boosts mood", "موڈ بہتر")),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 TIPS
              _section(
                tr("Tips for Best Experience",
                    "بہترین تجربے کے لیے تجاویز"),
                Column(
                  children: [
                    _tip("assets/icons/headphone1.png",
                        tr("Use headphones",
                            "ہیڈ فون استعمال کریں")),
                    _tip("assets/icons/closeye.png",
                        tr("Close eyes", "آنکھیں بند کریں")),
                    _tip("assets/icons/combinebreath.png",
                        tr("Combine with breathing",
                            "سانس کے ساتھ کریں")),
                    _tip("assets/icons/comfortable.png",
                        tr("Sit comfortably",
                            "آرام سے بیٹھیں")),
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