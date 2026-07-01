import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/translations.dart';
import '../../../../data/services/mood_model_service.dart';
import '../../styles/colors.dart';

class RecommendationStyle {
  final String emoji;
  final Color bgColor;
  final Color emojiBgColor;

  const RecommendationStyle({
    required this.emoji,
    required this.bgColor,
    required this.emojiBgColor,
  });
}

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  final TextEditingController noteController = TextEditingController();

  int selectedMoodIndex = 2;
  double intensity = 2.0;
  String? selectedCauseKey;
  bool isSaving = false;

  List<String> recommendations = ["", "", "", ""];

  final List<Map<String, dynamic>> moods = [
    {
      "key": "very_happy",
      "labelKey": "moodVeryHappy",
      "image": "assets/images/very_happy.png",
      "scale": 0.90,
    },
    {
      "key": "happy",
      "labelKey": "Happy",
      "image": "assets/images/happy.png",
      "scale": 0.90,
    },
    {
      "key": "good",
      "labelKey": "moodHappy",
      "image": "assets/images/good.png",
      "scale": 0.88,
    },
    {
      "key": "neutral",
      "labelKey": "moodNeutral",
      "image": "assets/images/neutral.png",
      "scale": 0.88,
    },
    {
      "key": "angry",
      "labelKey": "moodAngry",
      "image": "assets/images/angry.png",
      "scale": 0.82,
    },
    {
      "key": "sad",
      "labelKey": "moodSad",
      "image": "assets/images/sad.png",
      "scale": 0.78,
    },
    {
      "key": "sick",
      "labelKey": "moodSickLazy",
    "image": "assets/images/lazy.png",
      "scale": 0.80,
    },




  ];

  final List<Map<String, String>> causes = [
    {"key": "work_study", "labelKey": "causeWorkStudy"},
    {"key": "family", "labelKey": "causeFamily"},
    {"key": "health", "labelKey": "causeHealth"},
    {"key": "relationships", "labelKey": "causeRelationships"},
    {"key": "sleep", "labelKey": "causeSleep"},
    {"key": "financial_stress", "labelKey": "causeFinancialStress"},
  ];

  bool get isUrdu => Translations.isUrdu;
  ui.TextDirection get appTextDirection =>
      isUrdu ? ui.TextDirection.rtl : ui.TextDirection.ltr;

  String tr(String key) {
    if (isUrdu) {
      return Translations.ur[key] ?? Translations.en[key] ?? key;
    }
    return Translations.en[key] ?? key;
  }

  String get todayText =>
      "${tr("today")}, ${DateFormat('d MMM').format(DateTime.now())}";

  String get todayDocId => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, dynamic> get currentMood => moods[selectedMoodIndex];

  Map<String, dynamic>? get previousMoodData =>
      selectedMoodIndex > 0 ? moods[selectedMoodIndex - 1] : null;

  Map<String, dynamic>? get nextMoodData =>
      selectedMoodIndex < moods.length - 1 ? moods[selectedMoodIndex + 1] : null;

  String get currentMoodLabel => tr(currentMood["labelKey"] as String);

  String _causeLabelEnFromKey(String? key) {
    if (key == null || key.isEmpty) return "";
    try {
      final cause = causes.firstWhere((c) => c["key"] == key);
      return Translations.en[cause["labelKey"]] ?? "";
    } catch (_) {
      return "";
    }
  }

  String _causeLabelUrFromKey(String? key) {
    if (key == null || key.isEmpty) return "";
    try {
      final cause = causes.firstWhere((c) => c["key"] == key);
      return Translations.ur[cause["labelKey"]] ?? "";
    } catch (_) {
      return "";
    }
  }

  Widget buildMoodImage(
      String imagePath, {
        double boxSize = 210,
        double scale = 1.0,
      }) {
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  RecommendationStyle getRecommendationStyle(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('talk') ||
        lower.contains('call') ||
        lower.contains('friend') ||
        lower.contains('someone')) {
      return const RecommendationStyle(
        emoji: '💬',
        bgColor: Color(0xffF4FBF7),
        emojiBgColor: Color(0xffDDF4E6),
      );
    }

    if (lower.contains('read') || lower.contains('book')) {
      return const RecommendationStyle(
        emoji: '📚',
        bgColor: Color(0xffF7F5FF),
        emojiBgColor: Color(0xffE7E1FF),
      );
    }

    if (lower.contains('walk') ||
        lower.contains('exercise') ||
        lower.contains('move') ||
        lower.contains('stretch')) {
      return const RecommendationStyle(
        emoji: '🚶',
        bgColor: Color(0xffFFF8F1),
        emojiBgColor: Color(0xffFFE8CC),
      );
    }

    if (lower.contains('sleep') ||
        lower.contains('rest') ||
        lower.contains('nap')) {
      return const RecommendationStyle(
        emoji: '😴',
        bgColor: Color(0xffF3F7FF),
        emojiBgColor: Color(0xffDCE8FF),
      );
    }

    if (lower.contains('music') || lower.contains('song')) {
      return const RecommendationStyle(
        emoji: '🎵',
        bgColor: Color(0xffFFF4FA),
        emojiBgColor: Color(0xffFFDDF0),
      );
    }

    if (lower.contains('water') || lower.contains('drink')) {
      return const RecommendationStyle(
        emoji: '💧',
        bgColor: Color(0xffF1FAFF),
        emojiBgColor: Color(0xffD6F0FF),
      );
    }

    if (lower.contains('breathe') ||
        lower.contains('breathing') ||
        lower.contains('calm') ||
        lower.contains('relax')) {
      return const RecommendationStyle(
        emoji: '🌿',
        bgColor: Color(0xffF3FBF5),
        emojiBgColor: Color(0xffDDF3E2),
      );
    }

    if (lower.contains('write') ||
        lower.contains('journal') ||
        lower.contains('note')) {
      return const RecommendationStyle(
        emoji: '✍️',
        bgColor: Color(0xffFFF9F2),
        emojiBgColor: Color(0xffFFECCF),
      );
    }

    if (lower.contains('clean') ||
        lower.contains('organize') ||
        lower.contains('space')) {
      return const RecommendationStyle(
        emoji: '🧹',
        bgColor: Color(0xffF7FBFC),
        emojiBgColor: Color(0xffDDEEF2),
      );
    }

    if (lower.contains('pray') || lower.contains('spiritual')) {
      return const RecommendationStyle(
        emoji: '🤲',
        bgColor: Color(0xffF8F6FF),
        emojiBgColor: Color(0xffE7E0FF),
      );
    }

    return const RecommendationStyle(
      emoji: '✨',
      bgColor: Color(0xffFAFAFA),
      emojiBgColor: Color(0xffEEEEEE),
    );
  }

  Widget buildRecommendationCard({
    required String title,
    required int index,
    required Color primary,
    required bool isPlaceholder,
  }) {
    final style = isPlaceholder
        ?  RecommendationStyle(
      emoji: '💡',
      bgColor: AppColors.card(context),
      emojiBgColor: Color(0xffF3F4F6),
    )
        : getRecommendationStyle(title);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaceholder
              ? Colors.grey.shade300
              : primary.withOpacity(0.12),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.emojiBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                style.emoji,
                style: const TextStyle(fontSize: 21),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlaceholder
                        ? const Color(0xffF7F7F7)
                        : AppColors.card(context).withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${isUrdu ? "تجویز" : "Suggestion"} ${index + 1}",
                    textDirection: appTextDirection,
                    style: TextStyle(
                      color: isPlaceholder ? Colors.grey : primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textDirection: appTextDirection,
                  style: TextStyle(
                    color: isPlaceholder ? Colors.grey : const Color(0xff294C4A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refreshRecommendations() async {
    try {
      final result = await MoodModelService.instance
          .predictTop4Recommendations(currentMood["key"] as String);

      if (!mounted) return;

      setState(() {
        recommendations = result;
      });
    } catch (e) {
      debugPrint("Recommendation error: $e");
    }
  }

  void previousMood() {
    if (selectedMoodIndex > 0) {
      setState(() {
        selectedMoodIndex--;
      });
      refreshRecommendations();
    }
  }

  void nextMood() {
    if (selectedMoodIndex < moods.length - 1) {
      setState(() {
        selectedMoodIndex++;
      });
      refreshRecommendations();
    }
  }

  Future<void> loadTodayMoodCheckin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .collection('mood_checkins')
          .doc(todayDocId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final moodKey = (data["moodKey"] ?? "").toString();
      final causeKey = (data["affectingMoodKey"] ?? "").toString();

      final moodIndex = moods.indexWhere((m) => m["key"] == moodKey);

      List<String> loadedRecommendations = ["", "", "", ""];
      if (data["recommendations"] is List) {
        loadedRecommendations = List<String>.from(data["recommendations"]);
        while (loadedRecommendations.length < 4) {
          loadedRecommendations.add("");
        }
        if (loadedRecommendations.length > 4) {
          loadedRecommendations = loadedRecommendations.take(4).toList();
        }
      }

      if (!mounted) return;

      setState(() {
        if (moodIndex != -1) {
          selectedMoodIndex = moodIndex;
        }
        intensity = (data["intensity"] as num?)?.toDouble() ?? 2.0;
        selectedCauseKey = causeKey.isEmpty ? null : causeKey;
        noteController.text = (data["note"] ?? "").toString();
        recommendations = loadedRecommendations;
      });
    } catch (e) {
      debugPrint("Error loading mood check-in: $e");
    }
  }

  Future<void> saveMoodCheckin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      final predictedRecommendations =
      await MoodModelService.instance.predictTop4Recommendations(
        currentMood["key"] as String,
      );

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .collection('mood_checkins')
          .doc(todayDocId)
          .set({
        "patientId": user.uid,
        "dateId": todayDocId,
        "moodKey": currentMood["key"],
        "moodLabelEn":
        Translations.en[currentMood["labelKey"]] ?? currentMood["key"],
        "moodLabelUr":
        Translations.ur[currentMood["labelKey"]] ?? currentMood["key"],
        "moodLabelShown": currentMoodLabel,
        "moodImage": currentMood["image"],
        "intensity": intensity,
        "affectingMoodKey": selectedCauseKey ?? "",
        "affectingMoodEn": _causeLabelEnFromKey(selectedCauseKey),
        "affectingMoodUr": _causeLabelUrFromKey(selectedCauseKey),
        "note": noteController.text.trim(),
        "recommendations": predictedRecommendations,
        "languageAtSave": isUrdu ? "ur" : "en",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        recommendations = predictedRecommendations;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("moodSavedSuccessfully"))),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu
            ? "موڈ محفوظ کرنے میں خرابی"
            : "Error saving mood")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _initScreen() async {
    try {
      await MoodModelService.instance.load();
      await loadTodayMoodCheckin();

      final allEmpty = recommendations.every((e) => e.trim().isEmpty);
      if (allEmpty) {
        await refreshRecommendations();
      }
    } catch (e) {
      debugPrint("Init error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4E7D7A);
    const background = Color(0xffF5F5F5);
    const chipBg = Color(0xffDDEAE8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:  Icon(Icons.arrow_back_ios, color: AppColors.card(context)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr("moodCheckIn"),
                          textDirection: appTextDirection,
                          style:  TextStyle(
                            color: AppColors.card(context),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayText,
                          textDirection: appTextDirection,
                          style:TextStyle(
                            color: AppColors.card(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                     Icon(Icons.timer_outlined, color: AppColors.card(context)),
                      const SizedBox(width: 6),
                      Text(
                        tr("takes30Sec"),
                        textDirection: appTextDirection,
                        style:  TextStyle(
                          color: AppColors.card(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr("howFeelingNowDetailed"),
                      textDirection: appTextDirection,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr("moodChoiceHint"),
                      textDirection: appTextDirection,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 290,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (previousMoodData != null)
                            Positioned(
                              left: 18,
                              top: 45,
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scale: 0.62,
                                  child: Opacity(
                                    opacity: 0.35,
                                    child: ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(
                                        sigmaX: 2.0,
                                        sigmaY: 2.0,
                                      ),
                                      child: buildMoodImage(
                                        previousMoodData!["image"] as String,
                                        boxSize: 120,
                                        scale: (previousMoodData!["scale"] as num)
                                            .toDouble(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (nextMoodData != null)
                            Positioned(
                              right: 18,
                              top: 45,
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scale: 0.62,
                                  child: Opacity(
                                    opacity: 0.35,
                                    child: ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(
                                        sigmaX: 2.0,
                                        sigmaY: 2.0,
                                      ),
                                      child: buildMoodImage(
                                        nextMoodData!["image"] as String,
                                        boxSize: 120,
                                        scale: (nextMoodData!["scale"] as num)
                                            .toDouble(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildMoodImage(
                                currentMood["image"] as String,
                                boxSize: 210,
                                scale: (currentMood["scale"] as num).toDouble(),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentMoodLabel,
                                textDirection: appTextDirection,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            top: 78,
                            child: IconButton(
                              onPressed: selectedMoodIndex == 0 ? null : previousMood,
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 34,
                                color: selectedMoodIndex == 0
                                    ? Colors.grey.shade400
                                    : primary,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 78,
                            child: IconButton(
                              onPressed: selectedMoodIndex == moods.length - 1
                                  ? null
                                  : nextMood,
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 34,
                                color: selectedMoodIndex == moods.length - 1
                                    ? Colors.grey.shade400
                                    : primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      tr("howStrongFeeling"),
                      textDirection: appTextDirection,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 18,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.amber,
                        inactiveTrackColor: Colors.amber.withOpacity(0.2),
                        thumbColor: Colors.amber,
                        overlayColor: Colors.amber.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: intensity,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: intensity.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            intensity = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr("low"),
                          textDirection: appTextDirection,
                          style: const TextStyle(color: primary),
                        ),
                        Text(
                          tr("high"),
                          textDirection: appTextDirection,
                          style: const TextStyle(color: primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr("affectingMoodToday"),
                      textDirection: appTextDirection,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: causes.map((cause) {
                        final bool isSelected = selectedCauseKey == cause["key"];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCauseKey =
                              isSelected ? null : cause["key"];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : chipBg,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: primary.withOpacity(0.7),
                              ),
                            ),
                            child: Text(
                              tr(cause["labelKey"]!),
                              textDirection: appTextDirection,
                              style: TextStyle(
                                color: isSelected ? AppColors.card(context) : primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),




                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note_alt_outlined, color: primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tr("addNoteOptional"),
                                  textDirection: appTextDirection,
                                  style: const TextStyle(
                                    color: primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tr("notePrivateHint"),
                            textDirection: appTextDirection,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: noteController,
                            maxLines: 4,
                            textDirection: appTextDirection,
                            textAlign:
                            isUrdu ? TextAlign.right : TextAlign.left,
                            decoration: InputDecoration(
                              hintText: tr("writeThoughtsHere"),
                              hintTextDirection: appTextDirection,
                              filled: true,
                              fillColor: const Color(0xffF7F7F7),
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FBFA),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: primary.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr("recommendedForYou"),
                                      textDirection: appTextDirection,
                                      style: const TextStyle(
                                        color: primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isUrdu
                                          ? "آپ کے موجودہ موڈ کی بنیاد پر تجاویز"
                                          : "Suggestions based on your current mood",
                                      textDirection: appTextDirection,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: List.generate(4, (index) {
                              final isPlaceholder =
                                  recommendations[index].trim().isEmpty;

                              final text = isPlaceholder
                                  ? (isUrdu
                                  ? "تجویز یہاں ظاہر ہوگی"
                                  : "Recommendation will appear here")
                                  : recommendations[index];

                              return buildRecommendationCard(
                                title: text,
                                index: index,
                                primary: primary,
                                isPlaceholder: isPlaceholder,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : saveMoodCheckin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: AppColors.card(context),
                            elevation: 4,
                            shadowColor: primary.withOpacity(0.30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSaving
                              ? CircularProgressIndicator(color: AppColors.card(context))
                              : Text(
                            tr("saveMyMood"),
                            textDirection: appTextDirection,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}