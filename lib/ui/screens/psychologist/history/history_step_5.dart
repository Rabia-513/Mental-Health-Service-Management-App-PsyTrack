import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../data/services/tts_service.dart.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../../../app/routes.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/history_action_buttons.dart';


class HistoryStep5 extends StatefulWidget {
  const HistoryStep5({super.key});

  @override
  State<HistoryStep5> createState() => _HistoryStep5State();
}

class _HistoryStep5State extends State<HistoryStep5> {
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isUrdu = false;
  String connectionId = '';
  String historyId = '';
  String patientUid = '';
  String psychologistUid = '';
  bool _argsLoaded = false;
  String tr(String en, String ur) {
    return isUrdu ? ur : en;
  }
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> startListening(TextEditingController controller) async {
    bool available = await speech.initialize();
    if (!available) return;

    setState(() => isListening = true);

    speech.listen(
      localeId: isUrdu ? "ur_PK" : "en_US",
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        controller.text = result.recognizedWords;

        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );

        if (result.finalResult) {
          stopListening();
        }
      },    );
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }
  final Map<String, dynamic> data = {};

  bool neurotic = false;
  bool sexual = false;
  bool work = false;
  bool premorbid = false;
  List<String> get yesNo =>
      isUrdu ? ["ہاں", "نہیں"] : ["Yes", "No"];

  List<String> get deliveryTypes =>
      isUrdu
          ? ["نارمل", "سی سیکشن", "مدد سے"]
          : ["Normal", "C-Section", "Assisted"];

  List<String> get behaviourType =>
      isUrdu
          ? ["تعمیری", "تخریبی"]
          : ["Constructive", "Destructive"];

  List<String> get regularity =>
      isUrdu
          ? ["باقاعدہ", "غیر باقاعدہ"]
          : ["Regular", "Irregular"];

  List<String> get attitude =>
      isUrdu
          ? ["مثبت", "منفی", "غیر جانبدار"]
          : ["Positive", "Negative", "Neutral"];

  List<String> get friendCount =>
      isUrdu
          ? ["0–2", "3–5", "6–10", "10+"]
          : ["0–2", "3–5", "6–10", "10+"];

  final ageList = List.generate(20, (i) => "${i + 1}");


  Widget dd(String label, String key, List<String> items) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: data[key],
      decoration: input(label),
      iconEnabledColor: AppColors.primary,
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: (v) => setState(() => data[key] = v),
    ),
  );
  @override
  void dispose() {
    TTSService().stop();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argsLoaded) return;
    _argsLoaded = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    connectionId = (args["connectionId"] ?? "").toString();
    patientUid = (args["patientUid"] ?? "").toString();
    psychologistUid = (args["psychologistUid"] ?? "").toString();
    historyId = (args["historyId"] ?? "").toString();

    final vm = context.read<HistoryViewModel>();

    if (historyId.isNotEmpty) {
      vm.setHistoryId(historyId);
    } else if (vm.historyId != null) {
      historyId = vm.historyId!;
    }

    final draft = vm.getStepData(5);
    if (draft != null) {
      data.addAll(draft);
      neurotic = (draft["neurotic"] as bool?) ?? false;
      sexual = (draft["sexual"] as bool?) ?? false;
      work = (draft["work"] as bool?) ?? false;
      premorbid = (draft["premorbid"] as bool?) ?? false;
    }

    debugPrint("Step5 connectionId = $connectionId");
    debugPrint("Step5 historyId = $historyId");
    debugPrint("Step5 patientUid = $patientUid");
    debugPrint("Step5 psychologistUid = $psychologistUid");
  }

  InputDecoration input(String label, {TextEditingController? controller}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔊 Speaker
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () {
              TTSService().speak(label, isUrdu);
            },
          ),

          // 🎤 Mic (only for text fields)
          if (controller != null)
            IconButton(
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.red : AppColors.primary,
              ),
              onPressed: () {
                if (isListening) {
                  stopListening();
                } else {
                  startListening(controller);
                }
              },
            ),
        ],
      ),
      labelStyle: const TextStyle(color: AppColors.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
  Widget tf(String label, String key) {
    if (!controllers.containsKey(key)) {
      controllers[key] =
          TextEditingController(text: data[key]?.toString() ?? "");
    }

    final controller = controllers[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: input(label, controller: controller),
        onChanged: (v) {
          data[key] = v;
        },
      ),
    );
  }
  Widget toggle(String title, bool value, Function(bool) onChanged) =>
      SwitchListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(color: AppColors.primary)),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: AppColors.primary),
              onPressed: () {
                TTSService().speak(title, isUrdu);
              },
            ),
          ],
        ),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      );
  Widget cb(String title, String key) => CheckboxListTile(
    title: Text(title),
    value: (data[key] as bool?) ?? false,
    activeColor: AppColors.primary,
    onChanged: (v) => setState(() => data[key] = v),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HistoryViewModel>();

    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        title: Text(tr("Case History Form", "کیس ہسٹری فارم")),
        actions: [
          Row(
            children: [
              Text(
                isUrdu ? "اردو" : "EN",
                style:  TextStyle(color: AppColors.card(context)),
              ),
              Switch(
                value: isUrdu,
                onChanged: (v) {
                  setState(() {
                    isUrdu = v;
                  });
                },
                activeColor: AppColors.card(context),
              ),
            ],
          )
        ],
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: Column(
          children: [
            // PROGRESS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isUrdu ? "مرحلہ 4 از 4" : "Step 4 of 4", style: AppTextStyles.small),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: 1,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr("Personal History", "ذاتی تاریخ"),
                        style: AppTextStyles.bodyBold),

// Birth & Development
                    tf(
                      tr("Mother’s health during pregnancy",
                          "حمل کے دوران ماں کی صحت"),
                      "pregnancyHealth",
                    ),

                    dd(
                      tr("Type of delivery", "پیدائش کی قسم"),
                      "deliveryType",
                      deliveryTypes,
                    ),

                    tf(
                      tr("Any complications during delivery",
                          "پیدائش کے دوران کوئی پیچیدگی"),
                      "deliveryComplications",
                    ),

// Neurotic Behaviors
                    toggle(
                      tr("Neurotic Behaviors", "نیوروٹک رویے"),
                      neurotic,
                          (v) => setState(() => neurotic = v),
                    ),

                    if (neurotic) ...[
                      cb(tr("Nail Biting", "ناخن چبانا"), "nailBiting"),
                      cb(tr("Thumb Sucking", "انگوٹھا چوسنا"), "thumbSucking"),
                      cb(tr("Head Banging", "سر مارنا"), "headBanging"),
                      cb(tr("Bed Wetting", "بستر گیلا کرنا"), "bedWetting"),
                      cb(tr("Temper Tantrums", "غصے کے دورے"), "temperTantrums"),
                      cb(tr("Hair Pulling", "بال نوچنا"), "hairPulling"),
                      cb(tr("Sleep Walking", "نیند میں چلنا"), "sleepWalking"),
                      tf(tr("Any other", "کوئی اور"), "neuroticOther"),
                    ],

// Childhood History
                    tf(tr("Opinion of childhood days", "بچپن کے دنوں کے بارے میں رائے"),
                        "childhoodOpinion"),

                    tf(tr("Attitude towards peer group",
                        "ہم عمر دوستوں کے ساتھ رویہ"),
                        "peerAttitude"),

                    dd(
                      tr("Was behaviour constructive/destructive",
                          "رویہ تعمیری تھا یا تخریبی"),
                      "behaviourType",
                      behaviourType,
                    ),

                    tf(tr("Punished behaviours", "جن رویوں پر سزا ملی"),
                        "punishedBehaviours"),

                    tf(
                        tr("Attitude towards reward/punishment",
                            "انعام اور سزا کے بارے میں رویہ"),
                        "rewardAttitude"),

                    tf(
                        tr("Methods of reward & punishment",
                            "انعام اور سزا کے طریقے"),
                        "rewardMethods"),

                    tf(tr("Stories liked in childhood",
                        "بچپن میں پسندیدہ کہانیاں"),
                        "stories"),

                    dd(
                      tr("At what age did child sleep with parents",
                          "بچپن میں والدین کے ساتھ کب تک سوتا رہا"),
                      "sleepAge",
                      ageList,
                    ),

                    tf(tr("Happiest childhood event",
                        "بچپن کا سب سے خوشگوار واقعہ"),
                        "happyEvent"),

                    tf(tr("Saddest childhood event",
                        "بچپن کا سب سے افسوسناک واقعہ"),
                        "sadEvent"),

                    tf(tr("Childhood hobbies", "بچپن کے مشاغل"),
                        "childhoodHobbies"),

                    tf(
                        tr("Circumstances of development",
                            "نشوونما کے حالات"),
                        "developmentCircumstances"),

// Sexual History
                    toggle(
                      tr("Sexual History", "جنسی تاریخ"),
                      sexual,
                          (v) => setState(() => sexual = v),
                    ),

                    if (sexual) ...[
                      tf(tr("Age of puberty", "بلوغت کی عمر"),
                          "pubertyAge"),
                      tf(tr("Other relevant detail", "دیگر متعلقہ تفصیل"),
                          "sexualDetail"),
                    ],

// Educational History
                    dd(
                      tr("Any history of childhood labor",
                          "کیا بچپن میں مزدوری کی؟"),
                      "childLabor",
                      yesNo,
                    ),

                    tf(tr("Age of starting school", "اسکول شروع کرنے کی عمر"),
                        "schoolStartAge"),

                    tf(tr("Age of finishing school", "اسکول ختم کرنے کی عمر"),
                        "schoolEndAge"),

                    tf(tr("Opinion about schools", "اسکول کے بارے میں رائے"),
                        "schoolOpinion"),

                    tf(tr("Relationship with teachers",
                        "اساتذہ کے ساتھ تعلق"),
                        "teacherRelation"),

                    dd(
                      tr("Client’s attitude towards studies",
                          "تعلیم کے بارے میں رویہ"),
                      "studyAttitude",
                      attitude,
                    ),

                    tf(tr("Popularity and why", "مقبولیت اور وجہ"),
                        "popularity"),

                    tf(
                        tr("Education according to aptitude",
                            "تعلیم صلاحیت کے مطابق تھی؟"),
                        "educationAptitude"),

                    tf(
                        tr("Academic activities",
                            "تعلیمی سرگرمیاں"),
                        "academicActivities"),

                    tf(
                        tr("Most disliked teacher & why",
                            "سب سے ناپسند استاد اور وجہ"),
                        "dislikedTeacher"),

                    tf(tr("Position in class", "کلاس میں پوزیشن"),
                        "classPosition"),

                    tf(
                        tr("Education adequate/inadequate",
                            "تعلیم کافی تھی یا ناکافی"),
                        "educationAdequacy"),

                    tf(
                        tr("Reaction to parents attitude",
                            "والدین کے رویے پر ردعمل"),
                        "parentStudyReaction"),

                    dd(
                      tr("Was subject regular/irregular",
                          "حاضری باقاعدہ تھی یا غیر باقاعدہ"),
                      "regularity",
                      regularity,
                    ),

                    tf(tr("Reasons", "وجوہات"), "educationReasons"),

// Work Records
                    toggle(
                      tr("Work Records", "کام کا ریکارڈ"),
                      work,
                          (v) => setState(() => work = v),
                    ),

                    if (work) ...[
                      tf(tr("Age starting professional life",
                          "پیشہ ورانہ زندگی شروع کرنے کی عمر"),
                          "workStartAge"),

                      tf(tr("Present occupation", "موجودہ پیشہ"),
                          "presentOccupation"),

                      tf(tr("Previous jobs", "سابقہ نوکریاں"),
                          "previousJobs"),

                      tf(tr("Reasons for leaving job",
                          "نوکری چھوڑنے کی وجہ"),
                          "leaveReason"),

                      tf(tr("Colleague attitude",
                          "ساتھیوں کا رویہ"),
                          "colleagueAttitude"),

                      tf(tr("Client reaction", "مریض کا ردعمل"),
                          "workReaction"),

                      tf(tr("Boss behaviour & reaction",
                          "افسر کا رویہ اور ردعمل"),
                          "bossBehaviour"),

                      tf(tr("Satisfied with job & why",
                          "نوکری سے مطمئن؟ وجہ"),
                          "jobSatisfaction"),

                      dd(
                        tr("Is job according to aptitude",
                            "کیا نوکری صلاحیت کے مطابق ہے؟"),
                        "jobAptitude",
                        yesNo,
                      ),

                      tf(tr("Attitude towards income",
                          "آمدنی کے بارے میں رویہ"),
                          "incomeAttitude"),
                    ],

// Pre-Morbid & Social
                    toggle(
                      tr("Pre-Morbid Personality",
                          "پری موربڈ شخصیت"),
                      premorbid,
                          (v) => setState(() => premorbid = v),
                    ),

                    tf(tr("(specify)", "وضاحت کریں"),
                        "Pre-Morbid Personality"),

                    dd(
                      tr("No. of friends", "دوستوں کی تعداد"),
                      "friends",
                      friendCount,
                    ),

                    tf(tr("Activities with friends",
                        "دوستوں کے ساتھ سرگرمیاں"),
                        "friendActivities"),

                    tf(tr("Hobbies", "مشاغل"),
                        "hobbies"),

                    tf(tr("Dislikes", "ناپسندیدہ چیزیں"),
                        "dislikes"),
                  ],
                ),
              ),
            ),

            // BUTTONS
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    data["neurotic"] = neurotic;
                    data["sexual"] = sexual;
                    data["work"] = work;
                    data["premorbid"] = premorbid;

                    await vm.saveStep(step: 5, data: data);

                    if (connectionId.isEmpty ||
                        patientUid.isEmpty ||
                        psychologistUid.isEmpty ||
                        historyId.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Missing connection/history data")),
                      );
                      return;
                    }

                    Navigator.pushNamed(
                      context,
                      AppRoutes.historyPdfView,
                      arguments: {
                        "connectionId": connectionId,
                        "patientUid": patientUid,
                        "psychologistUid": psychologistUid,
                        "historyId": historyId,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isUrdu ? "مکمل ہسٹری دیکھیں" : "See Full History",
                    style: TextStyle(color: AppColors.card(context)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
        )
    );
  }
}
