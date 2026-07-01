import 'package:flutter/material.dart';

import '../../../../app/translations.dart';

class RelaxingSoundsScreen extends StatelessWidget {
  const RelaxingSoundsScreen({super.key});

  // 👉 Replace with your global toggle
  bool get isUrdu => Translations.isUrdu;
  String tr(String en, String ur) => isUrdu ? ur : en;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F7),

        appBar: AppBar(
          backgroundColor: const Color(0xFF4F7C7A),
          foregroundColor: Colors.white,

          title: Text(tr("Relaxing Sounds", "پرسکون آوازیں")),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              /// 🔹 TOP CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr(
                          "Unwind your body, ease your mind, and enhance relaxation with soothing sounds.",
                          "اپنے جسم کو آرام دیں، ذہن کو سکون دیں اور پرسکون آوازوں سے سکون حاصل کریں۔",
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 👉 Replace with your image
                    Image.asset(
                      "assets/icons/headphone1.png",
                      width: 70,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 TITLE
              Text(
                tr("Sounds", "آوازیں"),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                tr(
                  "Choose calming sounds to relax your mind.",
                  "اپنے ذہن کو آرام دینے کے لیے پرسکون آوازیں منتخب کریں۔",
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 SOUND LIST
              _soundCard(
                icon: "assets/icons/rain.png",
                title: tr("Rain Sound", "بارش کی آواز"),
                desc: tr(
                    "Gentle rain for relaxation",
                    "آرام کے لیے ہلکی بارش"),
                color: const Color(0xFFE0F2F1),
                onTap: () {
                  Navigator.pushNamed(context, "/rain-sound");
                },
              ),

              _soundCard(
                icon: "assets/icons/ocean.png",
                title: tr("Ocean Waves Sound",
                    "سمندر کی لہروں کی آواز"),
                desc: tr(
                    "Calming ocean waves for a peaceful and relaxing experience.",
                    "پرامن اور آرام دہ تجربے کے لیے سمندر کی لہروں کو پرسکون کرنا۔"),
                color: const Color(0xFFD6ECF3),
                  onTap: () {
                    Navigator.pushNamed(context, "/ocean-sound");
                  }

              ),

              _soundCard(
                icon: "assets/icons/forest.png",
                title: tr("Forest Ambience",
                    "جنگل کی فضا"),
                desc: tr(
                    "Soothing forest sounds for a calm and refreshing escape.",
                    "پُرسکون اور تازگی بخش فرار کے لیے پُرسکون جنگل کی آوازیں۔"),
                color: const Color(0xFFD6F5E3),
                onTap: () {

                  Navigator.pushNamed(context, "/forest-sound");
                },
              ),

              _soundCard(
                icon: "assets/icons/birds.png",
                title: tr("Birds Chirping",
                    "پرندوں کی چہچہاہٹ"),
                desc: tr(
                    "Gentle bird chirping for a peaceful and calming experience.",
                    "پُرسکون اور پرسکون تجربے کے لیے پرندوں کی چہچہاہٹ۔"),
                color: const Color(0xFFDCE3F5),
                  onTap: () {
                    Navigator.pushNamed(context, "/bird-sound");
                  }
              ),

              const SizedBox(height: 20),

              /// 🔹 TIPS
              Text(
                tr("Follow the Tips",
                    "ان ہدایات پر عمل کریں"),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _tip("assets/icons/headphone1.png",
                        tr("Use headphones",
                            "ہیڈ فون استعمال کریں")),
                    _tip("assets/icons/closeye.png",
                        tr("Sit comfortably",
                            "آرام سے بیٹھیں")),
                    _tip("assets/icons/combinebreath.png",
                        tr("Focus on breathing",
                            "سانس پر توجہ دیں")),
                    _tip("assets/icons/comfortable.png",
                        tr("Stay calm",
                            "پرسکون رہیں")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 SOUND CARD
  Widget _soundCard({
    required String icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }){
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 50),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(desc),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16),
                    const SizedBox(width: 5),
                    Text(tr("5-10 min", "5-10 منٹ"))
                  ],
                ),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFF4F7C7A),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20),
              ),
            ),
           onPressed: onTap,
            child: Text(tr("Start", "شروع کریں"),style: TextStyle(color:Colors.white),),
          )
        ],
      ),
    );
  }

  /// 🔹 TIP ITEM
  Widget _tip(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(icon, width: 35),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}