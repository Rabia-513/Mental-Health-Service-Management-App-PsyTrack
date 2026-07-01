
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../app/routes.dart';
import '../../../../data/services/tts_service.dart.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../widgets/background_wrapper.dart';
import '../../widgets/history_action_buttons.dart';

class HistoryStep3 extends StatefulWidget {
  const HistoryStep3({super.key});

  @override
  State<HistoryStep3> createState() => _HistoryStep3State();
}

class _HistoryStep3State extends State<HistoryStep3> {
  late stt.SpeechToText speech;
  bool isListening = false;
  bool isUrdu = false;

  String tr(String en, String ur) {
    return isUrdu ? ur : en;
  }


  final _formKey = GlobalKey<FormState>();

  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  bool _argsLoaded = false;
  // ---- Controllers ----
  final treatmentEffect = TextEditingController();
  final seizurePresentStatus = TextEditingController();

  final onsetTime = TextEditingController();
  final presentation = TextEditingController();
  final modeOfOnset = TextEditingController();
  final circumstances = TextEditingController();
  final clientThoughts = TextEditingController();

  final addictionDetails = TextEditingController();

  final treatmentTaken = TextEditingController();
  final treatmentDuration = TextEditingController();
  final improvementLevel = TextEditingController();
  final treatmentReason = TextEditingController();
  final physicalIllnessHistory = TextEditingController();

  final seizureAge = TextEditingController();
  final seizureBehavior = TextEditingController();
  final seizureTreatment = TextEditingController();
  final seizureDuration = TextEditingController();

  // ---- Toggles / Dropdowns ----
  String addictionHistory = "No";
  bool treatmentToggle = false;
  bool seizureToggle = false;

  final List<String> yesNoList = ["Yes", "No"];
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
  }
  Map<String, dynamic> collectData() {
    return {
      "onsetTime": onsetTime.text,
      "presentation": presentation.text,
      "modeOfOnset": modeOfOnset.text,
      "circumstances": circumstances.text,
      "clientThoughts": clientThoughts.text,

      "addictionHistory": addictionHistory,
      "addictionDetails": addictionDetails.text,

      "treatmentToggle": treatmentToggle,
      "treatmentTaken": treatmentTaken.text,
      "treatmentDuration": treatmentDuration.text,
      "improvementLevel": improvementLevel.text,
      "treatmentReason": treatmentReason.text,
      "physicalIllnessHistory": physicalIllnessHistory.text,
      "treatmentTaken": treatmentTaken.text,
      "treatmentDuration": treatmentDuration.text,
      "treatmentEffect": treatmentEffect.text,


      "seizureToggle": seizureToggle,
      "seizureAge": seizureAge.text,
      "seizureBehavior": seizureBehavior.text,
      "seizureTreatment": seizureTreatment.text,
      "seizureDuration": seizureDuration.text,
      "seizurePresentStatus": seizurePresentStatus.text,

    };
  }

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
        child: SafeArea(
          child: Column(
            children: [
              // ---- PROGRESS BAR ----
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr("Step 2 of 4", "مرحلہ 2 ا45"), style: AppTextStyles.small),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 2 / 4,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              // ---- FORM ----
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr("History of Present Illness", "موجودہ بیماری کی تاریخ"),
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.primary),
                        ),


                        const SizedBox(height: 12),

                        TextFormField(
                            controller: onsetTime,
                            decoration: input(tr(
                                "When problem started for the first time","مسئلہ پہلی بار کب شروع ہوا"),controller:onsetTime)),

                        const SizedBox(height: 12),

                        TextFormField(
                            controller: presentation,
                            decoration:
                            input(tr("How it was presented","مسئلہ کس طرح ظاہر ہوا"),controller:presentation)),

                        const SizedBox(height: 12),

                        TextFormField(
                            controller: modeOfOnset,
                            decoration: input(tr("Mode of onset","آغاز کا طریقہ"),controller:modeOfOnset)),

                        const SizedBox(height: 12),

                        TextFormField(
                            controller: circumstances,
                            decoration: input(tr(
                                "What was circumstances causing problem?","کن حالات میں مسئلہ پیدا ہوا؟"),controller:circumstances)),

                        const SizedBox(height: 12),

                        TextFormField(
                            controller: clientThoughts,
                            decoration: input(tr(
                                " what was  Client’s thoughts about problem?"," مریض کے خیالات مسئلہ کے بارے میں"),controller:clientThoughts)),

                        const SizedBox(height: 16),

                        DropdownButtonFormField(
                          value: addictionHistory,
                          decoration: input(
                              tr("Any history of addiction", "کیا نشے کی کوئی پرانی تاریخ ہے؟")),
                          items: yesNoList.map((e) {
                            return DropdownMenuItem(
                              value: e, // ALWAYS English
                              child: Text(
                                isUrdu
                                    ? (e == "Yes" ? "ہاں" : "نہیں")
                                    : e,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => addictionHistory = v!),
                        ),


                        if (addictionHistory == "Yes")

                          ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: addictionDetails,
                            decoration:
                            input(tr("Addiction / illness details","نشے یا بیماری کی تفصیل"),controller:addictionDetails),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ---- TREATMENT TOGGLE ----
                        SwitchListTile(
                          activeColor: AppColors.primary,
                          title: Text(tr("Treatment","علاج")),
                          value: treatmentToggle,
                          onChanged: (v) =>
                              setState(() => treatmentToggle = v),
                        ),

                        if (treatmentToggle) ...[
                          TextFormField(
                              controller: treatmentTaken,
                              decoration:
                              input(tr("Any treatment taken","کیا کوئی علاج لیا گیا؟"),controller:treatmentTaken)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: treatmentDuration,
                              decoration:
                              input(tr("Duration of treatment","علاج کی مدت"),controller:treatmentDuration)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: improvementLevel,
                              decoration:
                              input(tr("Level of improvement","بہتری کی سطح"),controller:improvementLevel)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: treatmentReason,
                              decoration:
                              input(tr("Reason for leaving treatment","علاج چھوڑنے کی وجہ"),controller:treatmentReason)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: physicalIllnessHistory,
                              decoration: input(tr(
                                  "History of physical illness","جسمانی بیماری کی تاریخ"),controller:physicalIllnessHistory)),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: treatmentTaken,
                            decoration: input(tr("Any treatment taken","کیا کوئی علاج لیا گیا؟"),controller:treatmentTaken),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: treatmentDuration,
                            decoration: input(tr("Duration of treatment","علاج کی مدت"),controller:treatmentReason),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: treatmentEffect,
                            decoration: input(tr("Effect","اثر"),controller:treatmentEffect),
                          ),

                        ],

                        const SizedBox(height: 20),

                        // ---- SEIZURES TOGGLE ----
                        SwitchListTile(
                          activeColor: AppColors.primary,
                          title:
                          Text(tr("History of seizures / fits","دوروں کی تاریخ")),
                          value: seizureToggle,
                          onChanged: (v) =>
                              setState(() => seizureToggle = v),
                        ),

                        if (seizureToggle) ...[
                          TextFormField(
                              controller: seizureAge,
                              decoration:
                              input(tr("Age of onset","آغاز کی عمر"),controller:seizureAge)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: seizureBehavior,
                              decoration: input(tr(
                                  "Behavior/ psychological problems after wards:","بعد ازاں رویہ یا نفسیاتی مسائل"),controller:seizureBehavior)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: seizureTreatment,
                              decoration:
                              input(tr("Treatment taken","لیا گیا علاج"),controller:seizureTreatment)),
                          const SizedBox(height: 12),

                          TextFormField(
                              controller: seizureDuration,
                              decoration:
                              input(tr("Duration","مدت"),controller:seizureDuration)),
                          const SizedBox(height: 12),


                          TextFormField(
                            controller: seizurePresentStatus,
                            decoration: input(tr("Present status","موجودہ حالت"),controller:seizurePresentStatus),
                          ),


                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ---- ACTION BUTTONS ----
              HistoryActionButtons(
                isUrdu: isUrdu,

                onSaveDraft: () async {
                  await vm.saveStep(step: 3, data: collectData());
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr("Draft saved", "مسودہ محفوظ ہو گیا")),
                      )

                  );
                },
                onContinue: () async {
                  await vm.saveStep(
                      step: 3, data: collectData(), moveNext: true);

                  Navigator.pushNamed(
                    context,
                    AppRoutes.historyStep4,
                    arguments: {
                      "connectionId": connectionId,
                      "patientUid": patientUid,
                      "psychologistUid": psychologistUid,
                      "historyId": historyId,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
        )
    );
  }
}
