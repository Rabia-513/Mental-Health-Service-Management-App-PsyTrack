import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../app/translations.dart';

class GuidedImageryScreen extends StatelessWidget {
  const GuidedImageryScreen({super.key});

  String tr(String key) => Translations.t(key);
  bool get isUrdu => Translations.isUrdu;
  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/PIzWG8kkr6w?si=QimHJBIy77MdaDpJ",
    );

    await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
    );
  }

  @override
  Widget build(BuildContext context) {
    final urdu = isUrdu;

    return Directionality(
      textDirection: urdu ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF5F5),

        appBar: AppBar(
          backgroundColor: const Color(0xFF4F7C7B),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(tr("guidedImageryTitle")),
          centerTitle: true,

        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// TOP CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEAEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xFFCFE3E3),
                      child: Image.asset("assets/images/guided.png", height: 60),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr("guidedImageryDesc"),
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

              /// INFO BOXES
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
              ),
              const SizedBox(height: 15),

              /// START BUTTON
              Row(
                children: [
                  Expanded(
                    child:                   ElevatedButton.icon(
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

                  ),
                  const SizedBox(width: 10),
                ],
              ),

              const SizedBox(height: 20),

              /// HOW IT WORKS
              _sectionCard(
                title: tr("howItWorks"),
                subtitle: tr("guidedHowDesc"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _step("assets/images/warmup.png", tr("step1")),
                      _arrow(),
                      _step("assets/images/breathe.png", tr("step2")),
                      _arrow(),
                      _step("assets/images/visualize.png", tr("step3")),
                      _arrow(),
                      _step("assets/images/relax.png", tr("step4")),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// WHAT TO EXPECT
              _sectionCard(
                title: tr("whatExpect"),
                subtitle: tr("expectDesc"),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _icon("assets/images/brain.png", tr("reduceStress")),
                      const SizedBox(width: 12),
                      _icon("assets/images/sleep.png", tr("safety")),
                      const SizedBox(width: 12),
                      _icon("assets/images/relax.png", tr("deepRelax")),
                      const SizedBox(width: 12),
                      _icon("assets/images/focus.png", tr("focus")),
                    ],
                  ),
                ),              ),

              const SizedBox(height: 20),

              /// TIPS
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

  /// INFO BOX
  Widget _infoBox(String img, String title, String sub) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8FBABA)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(img, height: 18),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
  Widget _sectionCard(
      {required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEAEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(subtitle, textAlign: TextAlign.center),
            ),
          const SizedBox(height: 12),
          child
        ],
      ),
    );
  }

  Widget _step(String img, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFCFE3E3),
          child: Image.asset(img, height: 25),
        ),
        const SizedBox(height: 6),
        Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10))
      ],
    );
  }

  Widget _arrow() =>
      const Icon(Icons.arrow_forward, color: Colors.blue);

  Widget _icon(String img, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFCFE3E3),
          child: Image.asset(img, height: 25),
        ),
        const SizedBox(height: 6),
        Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10))
      ],
    );
  }

  Widget _tip(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text))
      ],
    );
  }
}