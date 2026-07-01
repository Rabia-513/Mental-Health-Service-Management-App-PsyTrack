
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


class HistoryStep4 extends StatefulWidget {
  const HistoryStep4({super.key});

  @override
  State<HistoryStep4> createState() => _HistoryStep4State();
}

class _HistoryStep4State extends State<HistoryStep4> {
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isUrdu = false;

  String tr(String en, String ur) {
    return isUrdu ? ur : en;
  }
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  bool _argsLoaded = false;

  /// ================= DATA STRUCTURE =================
  Map<String, dynamic> father = {};
  Map<String, dynamic> mother = {};
  List<Map<String, dynamic>> siblings = [];
  Map<String, dynamic> home = {};
  List<Map<String, dynamic>> psychiatricMembers = [];
  Map<String, dynamic> marital = {};
  final Map<String, TextEditingController> controllers = {};

  /// ================= OPTIONS =================
  final yesNo = ["Yes", "No"];
  final familySystem = ["Nuclear", "Joint"];
  final rules = ["Rigid", "Flexible"];
  final jointNuclear = ["Joint", "Nuclear"];
  final childhoodPlace = ["Home", "Hostel", "Elsewhere"];
  final genderList = ["Male", "Female", "Other"];
  final oneToFive = ["1", "2", "3", "4", "5"];
  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }
  @override
  void dispose() {
    speech.stop();
    TTSService().stop();
    super.dispose();
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
      },
    );
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }
  String yesNoUrdu(String value) {
    switch (value) {
      case "Yes":
        return "ہاں";
      case "No":
        return "نہیں";
      default:
        return value;
    }
  }
  String familySystemUrdu(String value) {
    switch (value) {
      case "Nuclear":
        return "جوہری خاندان";
      case "Joint":
        return "مشترکہ خاندان";
      default:
        return value;
    }
  }
  String rulesUrdu(String value) {
    switch (value) {
      case "Rigid":
        return "سخت";
      case "Flexible":
        return "لچکدار";
      default:
        return value;
    }
  }
  String childhoodPlaceUrdu(String value) {
    switch (value) {
      case "Home":
        return "گھر";
      case "Hostel":
        return "ہاسٹل";
      case "Elsewhere":
        return "کسی اور جگہ";
      default:
        return value;
    }
  }
  String genderUrdu(String value) {
    switch (value) {
      case "Male":
        return "مرد";
      case "Female":
        return "عورت";
      case "Other":
        return "دیگر";
      default:
        return value;
    }
  }

  final temperamentOptions = [
    "Friendly",
    "Cooperative",
    "Quiet",
    "Introvert",
    "Extrovert",
    "Anger prone",
    "Careless",
    "Rigid",
    "Helpful",
    "Expressive",
  ];
  String temperamentUrdu(String value) {
    switch (value) {
      case "Friendly":
        return "ملنسار";
      case "Cooperative":
        return "تعاون کرنے والا";
      case "Quiet":
        return "خاموش";
      case "Introvert":
        return "درون مزاج";
      case "Extrovert":
        return "بیرون مزاج";
      case "Anger prone":
        return "جلد غصہ کرنے والا";
      case "Careless":
        return "لاپرواہ";
      case "Rigid":
        return "سخت مزاج";
      case "Helpful":
        return "مددگار";
      case "Expressive":
        return "اظہار کرنے والا";
      default:
        return value;
    }
  }

  @override
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
  }
  Widget textField(
      String label,
      Map<String, dynamic> map,
      String key,
      ) {
    String uniqueKey = "${map.hashCode}_$key";

    if (!controllers.containsKey(uniqueKey)) {
      controllers[uniqueKey] =
          TextEditingController(text: map[key]?.toString() ?? "");
    }

    final controller = controllers[uniqueKey]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: input(label, controller: controller),
        onChanged: (value) {
          map[key] = value;
        },
      ),
    );
  }
  Widget dropdown(
      String label, Map map, String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        value: map[key],
        decoration: input(label),
        items: options.map((e) {
          String displayValue = e;

          if (isUrdu) {
            if (options == yesNo) {
              displayValue = yesNoUrdu(e);
            } else if (options == familySystem ||
                options == jointNuclear) {
              displayValue = familySystemUrdu(e);
            } else if (options == rules) {
              displayValue = rulesUrdu(e);
            } else if (options == childhoodPlace) {
              displayValue = childhoodPlaceUrdu(e);
            } else if (options == genderList) {
              displayValue = genderUrdu(e);
            }
          }

          return DropdownMenuItem(
            value: e, // 🔐 Always store English
            child: Text(displayValue),
          );
        }).toList(),
        onChanged: (v) => setState(() => map[key] = v),
      ),
    );
  }

  Widget toggle(String label, Map map, String key) {
    return SwitchListTile(
      activeColor: AppColors.primary,
      title: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () {
              TTSService().speak(label, isUrdu);
            },
          ),
        ],
      ),
      value: map[key] ?? false,
      onChanged: (v) => setState(() => map[key] = v),
    );
  }
  InputDecoration input(String label, {TextEditingController? controller}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔊 Text to Speech
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () {
              TTSService().speak(label, isUrdu);
            },
          ),

          // 🎤 Speech to Text (only for text fields)
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }  Map<String, dynamic> collectData() => {
    "father": father,
    "mother": mother,
    "siblings": siblings,
    "home": home,
    "psychiatricMembers": psychiatricMembers,
    "marital": marital,
  };

  /// ================= BUILD =================
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
                    style: TextStyle(color: AppColors.card(context)),
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
            /// ---------- PROGRESS ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr("Step 3 of 4", "مرحلہ 4 از 3"), style: AppTextStyles.small),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: 4 / 6,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            /// ---------- CONTENT ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// ================= FATHER =================
                    ExpansionTile(title: Text(tr("Father","ابو")), children: [
                      dropdown( tr("Total family members", "کل اہل خانہ"), father,
                          tr("Family status", "خاندانی حیثیت"), List.generate(20, (i) => "${i + 1}")),
                      textField(tr("Family status", "خاندانی حیثیت"), father, "familyStatus"),
                      textField(tr("Name","نام"), father, "name"),
                      dropdown(tr("Alive","زندہ"), father, "alive", yesNo),
                      dropdown(tr("Age","عمر"), father, "age",
                          List.generate(100, (i) => "${i + 1}")),
                      textField(tr("Education","تعلیم"), father, "education"),
                      textField(tr("Occupation","پیشہ"), father, "occupation"),
                      textField(tr("Monthly income","ماہانہ آمدنی"), father, "income"),
                      textField(tr("No. of marriages","شادیوں کی تعداد"), father, "marriages"),
                      toggle(tr("Father dead","والد کا انتقال"), father, "dead"),
                      if (father["dead"] == true) ...[
                        textField(tr("Cause of death","انتقال کی وجہ"), father, "causeOfDeath"),
                        textField(tr("Client reaction","مریض کا ردعمل"), father, "reactionOnDeath"),
                      ],
                      const Divider(),
                      Text(tr("Temperament","مزاج"),
                          style: AppTextStyles.bodyBold),
                      Wrap(
                        children: temperamentOptions.map((t) {
                          List<String> list =
                          List<String>.from(father["temperament"] ?? []);


                          return CheckboxListTile(
                            value: list.contains(t),

                            // ✅ Fill color when checked
                            activeColor: AppColors.primary,

                            // ✅ Tick color
                            checkColor: AppColors.card(context),

                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isUrdu ? temperamentUrdu(t) : t,
                                    style: const TextStyle(color: AppColors.primary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                                  onPressed: () {
                                    TTSService().speak(
                                      isUrdu ? temperamentUrdu(t) : t,
                                      isUrdu,
                                    );
                                  },
                                ),
                              ],
                            ),
                            onChanged: (v) {
                              setState(() {
                                if (list.contains(t)) {
                                  list.remove(t);
                                } else {
                                  list.add(t);
                                }

                                father["temperament"] = list;   // important
                              });
                            },

                          );
                        }).toList(),
                      ),

                      toggle(tr("Any health problem","کیا کوئی صحت کا مسئلہ ہے؟"), father, "healthProblem"),
                      if (father["healthProblem"] == true) ...[
                        textField(tr("Duration","مدت"), father, "healthDuration"),
                        textField(tr("Treatment","علاج"), father, "healthTreatment"),
                        textField(tr("Effect","اثر"), father, "healthEffect"),
                      ],
                          toggle(tr("Any psychological problem","کیا نفسیاتی مسئلہ ہے؟"),
                          father, "psychProblem"),
                      if (father["psychProblem"] == true) ...[
                        textField(tr("Duration","مدت"), father, "psychDuration"),
                        textField(tr("Treatment","علاج"), father, "psychTreatment"),
                        textField(tr("Effect" ,"اثر"), father, "psychEffect"),
                      ],
                      textField(tr(
                          "Relationship with client","مریض کے ساتھ تعلق"), father, "relationClient"),
                      textField(tr("Relationship with children","بچوں کے ساتھ تعلق"),
                          father, "relationChildren"),
                      textField(tr("Client opinion","مریض کی رائے"), father, "clientOpinion"),
                      textField(tr("Client reaction to attitude","رویے پر مریض کا ردعمل"),
                          father, "reactionAttitude"),
                      textField(tr("Considers client opinion","مریض کی رائے کو اہمیت دینا"),
                          father, "considersOpinion"),
                    ]),

                    /// ================= MOTHER =================
                    ExpansionTile(title: Text(tr("Mother","ماں")), children: [
                      textField(tr("Name","نام"), mother, "name"),
                      dropdown(tr("Alive","زندہ"), mother, "alive", yesNo),
                      dropdown(tr("Age","عمر"), mother, "age",
                          List.generate(100, (i) => "${i + 1}")),
                      textField(tr("Education","تعلیم"), mother, "education"),
                      textField(tr("Occupation","پیشہ"), mother, "occupation"),
                      textField(tr("Monthly income","ماہانہ آمدنی"), mother, "income"),
                      textField(tr("No. of marriages","شادیوں کی تعداد"), mother, "marriages"),
                      toggle(tr("Mother dead","والدہ کا انتقال "), mother, "dead"),
                      if (mother["dead"] == true) ...[
                        textField(tr("Cause of death","انتقال کی وجہ"), mother, "causeOfDeath"),
                        textField(tr("Client reaction","مریض کا ردعمل"), mother, "reactionOnDeath"),
                      ],
                      const Divider(),
                      Text(tr("Temperament","مزاج"), style: AppTextStyles.bodyBold),

                      Wrap(
                        children: temperamentOptions.map((t) {
                          List<String> list =
                          List<String>.from(mother["temperament"] ?? []);


                          return CheckboxListTile(
                            value: list.contains(t),

                            // ✅ Primary fill color
                            activeColor: AppColors.primary,

                            // ✅ White tick
                            checkColor: AppColors.card(context),

                            // ✅ Optional border color
                            side: const BorderSide(color: AppColors.primary),

                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isUrdu ? temperamentUrdu(t) : t,
                                    style: const TextStyle(color: AppColors.primary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                                  onPressed: () {
                                    TTSService().speak(
                                      isUrdu ? temperamentUrdu(t) : t,
                                      isUrdu,
                                    );
                                  },
                                ),
                              ],
                            ),
                            onChanged: (v) {
                              setState(() {
                                if (list.contains(t)) {
                                  list.remove(t);
                                } else {
                                  list.add(t);
                                }

                                mother["temperament"] = list;   // important
                              });
                            },

                          );
                        }).toList(),
                      ),


                      const Divider(),
                      toggle(tr("Any health problem","کیا کوئی صحت کا مسئلہ ہے؟"), mother, "healthProblem"),
                      if (mother["healthProblem"] == true) ...[
                        textField(tr("Duration","مدت"), mother, "healthDuration"),
                        textField(tr("Treatment","علاج"), mother, "healthTreatment"),
                        textField(tr("Effect","اثر"), mother, "healthEffect"),
                      ],
                      toggle(tr("Any psychological problem","کیا نفسیاتی مسئلہ ہے؟"),
                          mother, "psychProblem"),
                      if (mother["psychProblem"] == true) ...[
                        textField(tr("Duration","مدت"), mother, "psychDuration"),
                        textField(tr("Treatment","علاج"), mother, "psychTreatment"),
                        textField(tr("Effect","اثر"), mother, "psychEffect"),
                      ],
                      textField(tr(
                          "Relationship with client","مریض کے ساتھ تعلق"), mother, "relationClient"),
                      textField(tr("Client opinion","مریض کی رائے"), mother, "clientOpinion"),
                      textField(tr("Reaction to attitude","رویے پر مریض کا ردعمل"),
                          mother, "reactionAttitude"),
                      textField(tr("Considers client opinion","مریض کی رائے کو اہمیت دینا"),
                          mother, "considersOpinion"),
                    ]),

                    /// ================= SIBLINGS =================
                    ///
                    ExpansionTile(title: Text(tr("Siblings","بہن بھائی")), children: [
                      dropdown(tr(
                        "Total siblings","کل بہن بھائی"),
                        home,
                        "totalSiblings",
                        List.generate(20, (i) => "${i + 1}"),
                      ),

                      dropdown(tr(
                        "Brothers","بھائی"),
                        home,
                        "brothers",
                        List.generate(20, (i) => "$i"),
                      ),

                      dropdown(tr(
                        "Sisters","بہن"),
                        home,
                        "sisters",
                        List.generate(20, (i) => "$i"),
                      ),

                      const Divider(),

                      for (int i = 0; i < siblings.length; i++)
                        Column(
                          children: [
                            textField(tr("Name","نام"), siblings[i], "name"),
                            dropdown(tr("Age","عمر"), siblings[i], "age",
                                List.generate(50, (i) => "${i + 1}")),
                            dropdown(tr(
                                "Gender","جنس"), siblings[i], "gender", genderList),
                            textField(tr(
                                "Education","تعلیم"), siblings[i], "education"),
                            dropdown(tr("Physical problem","جسمانی مسئلہ"), siblings[i],
                                "physicalProblem", yesNo),
                            dropdown(tr("Emotional problem","جذباتی مسئلہ"), siblings[i],
                                "emotionalProblem", yesNo),
                            textField(tr("Relation with client","مریض کے ساتھ تعلق"),
                                siblings[i], "relationClient"),
                            textField(tr("Relation with siblings"," بہن بھائیوں کے ساتھ رشتہ"),
                                siblings[i], "relationSiblings"),
                            textField(tr("Relation with step siblings","سوتیلے بہن بھائیوں کے ساتھ رشتہ"),
                                siblings[i], "relationStep"),
                            const Divider(),
                          ],
                        ),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => siblings.add({})),
                        icon: const Icon(Icons.add),
                        label: Text(tr("Add another sibling","دوسرے بہن بھائیوں کو شامل کریں")),
                      ),
                    ]),

                    /// ================= HOME ATMOSPHERE =================
                    ExpansionTile(
                        title: Text(tr("General Home Atmosphere","گھر کا ماحول")),
                        children: [
                          dropdown(tr("Attitude & Marital Relationship","رویہ اور ازدواجی تعلق"), home,
                              "familySystem", familySystem),
                          textField(tr(
                              "If joint specify members","اگر مشترکہ خاندان کی وضاحت کریں"), home, "jointMembers"),
                          dropdown(tr(
                              "Dependent members","منحصر اراکین"),
                              home,
                              "dependents",
                              List.generate(20, (i) => "${i + 1}")),
                          textField(tr("Extended family relations","توسیع شدہ خاندان کے ارکان"),
                              home, "extendedRelation"),
                          for (var k in [tr(
                            "Communicative","بات چیت کرنے والا"),
                            tr("Interactive","مل کر کام کرنا"),
                            tr("Rigid", "سخت"),
                            tr("Conservative", "محتاط"),
                            tr("Permissive", "لچکدار")
                          ])
                            dropdown(k, home, k.toLowerCase(), oneToFive),
                          dropdown(tr("Rules & regulations","قواعد و ضوابط"),
                              home, "rules", rules),
                          toggle(tr("Psychiatric illness in family", "خاندان میں نفسیاتی بیماری"),
                              home, "psychiatric"),
                          if (home["psychiatric"] == true) ...[
                            for (int i = 0;
                            i < psychiatricMembers.length;
                            i++)
                              Column(
                                children: [
                                  textField(tr("Treatment", "علاج"), psychiatricMembers[i], "treatment"),
                                  textField(tr("Effect", "اثر"), psychiatricMembers[i], "effect"),
                                  textField(tr("Family attitude", "خاندانی رویہ"), psychiatricMembers[i], "attitude"),
                                  textField(tr("Stressors", "دباؤ"), psychiatricMembers[i], "stressors"),
                                  textField(tr("Parents relationship", "والدین کا تعلق"), psychiatricMembers[i], "parentsRelation"),

                                  const Divider(),
                                ],
                              ),
                            TextButton.icon(
                              onPressed: () => setState(() =>
                                  psychiatricMembers.add({})),
                              icon: const Icon(Icons.add),
                              label:
                              Text(tr("Add another member", "مزید رکن شامل کریں")),
                            ),
                          ],
                        ]),

                    /// ================= MARITAL =================
                    ExpansionTile(
                        title:
                        Text(tr("Attitude & Marital Relationship","رویہ اور ازدواجی رشتہ")),
                        children: [
                          textField(tr("Parents attitude", "والدین کا رویہ"), marital, "parentsAttitude"),
                          textField(tr("Client reaction", "مریض کا ردعمل"), marital, "clientReaction"),
                          textField(tr("Salient happenings", "اہم واقعات"), marital, "salient"),
                          textField(tr("Home environment cause", "گھر کے ماحول کی وجہ"), marital, "environmentCause"),
                          // (5) Client opinion about home environment
                          textField(tr(
                            "Client’s opinion about home environment","گھر کے ماحول کے بارے میں کلائنٹ کی رائے"),
                            marital,
                            "homeOpinion",
                          ),
                          // Client opinion about home environment
                          textField(tr("Client’s opinion about home environment", "گھر کے ماحول کے بارے میں مریض کی رائے"), marital, "homeOpinion"),

                          textField(tr("Client role", "مریض کا کردار"), marital, "clientRole"),

                          dropdown(tr("Home broken", "گھر ٹوٹا"), marital, "homeBroken", yesNo),
                          dropdown(tr("Age at incident", "واقعے کی عمر"), marital, "ageAtIncident", List.generate(50, (i) => "${i + 1}")),

                          // Client reaction at incident
                          textField(tr("Client’s reaction at incident", "واقعے پر مریض کا ردعمل"), marital, "reactionAtIncident"),

// (10) Living with father / mother
                          // Living with father / mother
                          textField(tr("Living with father / mother", "والد یا والدہ کے ساتھ رہنا"), marital, "livingWith"),

                          // Responsible for home breaking
                          textField(tr("Who client thinks responsible for home breaking", "مریض کے خیال میں گھر کے ٹوٹنے کا ذمہ دار کون ہے؟"), marital, "responsibleForBreak"),

                          // Serious interpersonal conflict
                          textField(tr("Any serious interpersonal conflict in family", "خاندان میں کوئی سنگین ذاتی تنازعہ؟"), marital, "interpersonalConflict"),

                          dropdown(tr("Childhood family system", "بچپن کا خاندانی نظام"), marital, "childhoodSystem", jointNuclear),
                          dropdown(tr("Childhood spent", "بچپن کہاں گزارا؟"), marital, "childhoodPlace", childhoodPlace),
                          toggle(tr("Marital relationship", "ازدواجی تعلق"), marital, "marital"),

                          if (marital["marital"] == true) ...[
                            for (var k in [
                              tr("Adequate", "مناسب"),
                              tr("Congenial", "خوشگوار"),
                              tr("Conflicting", "تنازعہ"),
                            ])
                              CheckboxListTile(

                                title: Text(k),
                                // ✅ Fill color when checked
                                activeColor: AppColors.primary,

                                // ✅ Tick color
                                checkColor: AppColors.card(context),
                                value:
                                marital[k.toLowerCase()] ?? false,
                                onChanged: (v) => setState(() =>
                                marital[k.toLowerCase()] = v),
                              ),
                            textField(tr("Separation duration", "علیحدگی کی مدت"), marital, "separation"),
                            textField(tr("Divorce duration", "طلاق کی مدت"), marital, "divorce"),
                            textField(tr("Other", "دیگر"), marital, "other"),
                            dropdown(tr("Cousin marriage", "کزن کی شادی"), marital, "cousinMarriage", yesNo),
                            textField(tr("Other relatives", "دیگر رشتہ دار"), marital, "relatives"),
                            dropdown(tr("No of children", "بچوں کی تعداد"), marital, "children", yesNo),
                            textField(tr("Relationship with children", "بچوں کے ساتھ تعلق"), marital, "relationChildren"),
                            textField(tr("Any other detail", "کوئی اور تفصیل"), marital, "detail"),
                          ],
                        ]),
                  ],
                ),
              ),
            ),

            /// ---------- BUTTONS ----------
            HistoryActionButtons(
              isUrdu: isUrdu,
              onSaveDraft: () async {
                await vm.saveStep(step: 4, data: collectData());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text( tr("Draft saved","مسودہ محفوظ ہو گیا"))),
                );
              },
              onContinue: () async {
                await vm.saveStep(
                    step: 4, data: collectData(), moveNext: true);

                Navigator.pushNamed(
                  context,
                  AppRoutes.historyStep5,
                  arguments: {
                    "connectionId": connectionId,
                    "patientUid": patientUid,
                    "psychologistUid": psychologistUid,
                    "historyId": vm.historyId,
                  },
                );
              },
            ),
          ],
        ),
      ),
        )
    );
  }
}
