import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/translations.dart';

class PMRExerciseScreen extends StatelessWidget {
  const PMRExerciseScreen({super.key});

  String tr(String key) => Translations.t(key);

  bool get isUrdu => tr("hello") == "سلام";
  Future<void> openVideo() async {
    final url = Uri.parse(
      "https://youtu.be/GZ9PHsbt-m4?si=4CYO5jHhtSGmrcnv",
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
          title: Text(tr("pmrTitle"),style: TextStyle(color: Colors.white),),

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
                      child: Image.asset("assets/images/pmr.png", height: 60),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr("pmrFull"),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tr("pmrLongDesc"),
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

              // ================= INFO BOX =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _infoBox("assets/icons/time.png", "10-20 min", tr("duration"))),
                  Expanded(child: _infoBox("assets/icons/level.png", tr("beginner"), tr("level"))),
                  Expanded(child: _infoBox("assets/icons/relaxing.png", tr("available"), tr("audio"))),
                ],
              ),
              const SizedBox(height: 15),

              // ================= START BUTTON =================
              ElevatedButton.icon(
                onPressed: openVideo,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  tr("startExercise"),
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F7C7B),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // ================= HOW IT WORKS =================
              _sectionCard(
                title: tr("howItWorks"),
                child: Column(
                  children: [

                    Text(
                      tr("pmrHowDesc"),
                      style: const TextStyle(color: Color(0xFF2F5D5C)),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _circleStep("assets/images/tense.png", "1.${tr("tense")}"),

                        _circleStep("assets/images/hold.png", "2.${tr("hold")}"),

                        _circleStep("assets/images/relax.png", "3.${tr("relax")}"),

                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stepText(tr("tenseDesc")),
                        _stepText(tr("holdDesc")),
                        _stepText(tr("relaxDesc")),

                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ================= EXPECT =================
              _sectionCard(
                title: tr("whatExpect"),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _iconText("assets/images/brain.png",
                        tr("reduceStress")),
                    _iconText("assets/images/moodee.png",
                        tr("improveMood")),
                    _iconText("assets/images/tension.png",
                        tr("relieveTension")),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= MUSCLE GROUP =================
              _sectionCard(
                title: tr("muscleGroups"),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: [
                    _iconText("assets/images/arm.png",
                        tr("arms")),
                    _iconText("assets/images/shoulder.png",
                        tr("shoulders")),
                    _iconText("assets/images/face.png",
                        tr("face")),
                    _iconText("assets/images/lungs.png",
                        tr("lungs")),
                  ],
                ),
              ),
              const SizedBox(height: 15),

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

  Widget _infoBox(String img, String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Image.asset(img, height: 20), // Ensure correct image size
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title, // Ensure the title fits within the available space
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Adjust the font size
                  ),
                  overflow: TextOverflow.ellipsis, // Handle overflow text
                  maxLines: 1, // Limit to 1 line if needed
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sub, // Make sure this text fits in the container
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            overflow: TextOverflow.ellipsis, // Handle overflow text
            maxLines: 2, // Limit to 2 lines if the text is long
          ),
        ],
      ),
    );
  }  Widget _sectionCard({required String title, required Widget child}) {
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
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
  Widget _iconText(String img, String text) {
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
              style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
  Widget _step(String img, String title, String desc) {
    return Row(
      children: [
        Image.asset(img, height: 40),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(desc),
          ],
        )
      ],
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

  Widget _stepText(String text) {
    return SizedBox(
      width: 80,
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10)),
    );
  }

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

