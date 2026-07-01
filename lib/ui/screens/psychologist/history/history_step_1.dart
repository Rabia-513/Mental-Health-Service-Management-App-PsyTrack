import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../data/services/tts_service.dart.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../widgets/background_wrapper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HistoryStep1 extends StatefulWidget {
  const HistoryStep1({super.key});

  @override
  State<HistoryStep1> createState() => _HistoryStep1State();
}

class _HistoryStep1State extends State<HistoryStep1> {

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

  // Controllers
  final name = TextEditingController();
  final education = TextEditingController();
  final occupation = TextEditingController();
  final informant = TextEditingController();
  final hospital = TextEditingController();
  final caseNo = TextEditingController();
  final previousDx = TextEditingController();
  final presentDx = TextEditingController();
  final address = TextEditingController();
  final referralSource = TextEditingController();

  String? age;
  String? gender;
  String? siblings;
  String? birthOrder;
  String? maritalStatus;
  String? religion;

  DateTime? selectedDate;
  late stt.SpeechToText speech;
  bool isListening = false;
  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();

  }


  @override
  void dispose() {
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
      pauseFor: Duration(seconds: 3),
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
  final ageList = List.generate(100, (i) => "${i + 1}");
  final siblingList = List.generate(100, (i) => "${i + 1}");
  List<String> get genderList =>
      isUrdu ? ["مرد", "عورت", "دیگر"] : ["Male", "Female", "Other"];

  List<String> get birthOrderList =>
      isUrdu
          ? ["بڑا", "درمیانی", "چھوٹا"]
          : ["Elder", "Middle", "Younger"];

  List<String> get maritalList =>
      isUrdu
          ? ["شادی شدہ", "غیر شادی شدہ", "طلاق یافتہ", "بیوہ"]
          : ["Married", "Unmarried", "Divorced", "Widowed"];

  List<String> get religionList =>
      isUrdu
          ? ["اسلام", "عیسائیت", "ہندومت", "دیگر"]
          : ["Islam", "Christian", "Hindu", "Other"];


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
                color: isListening ? Colors.red : AppColors.primary,              ),
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

  Future<void> pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // 👈 HEADER + SELECTED DATE
              onPrimary: AppColors.card(context),    // 👈 TEXT ON HEADER
              onSurface: AppColors.primary, // 👈 DEFAULT TEXT COLOR
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // 👈 OK / CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (d != null) {
      setState(() {
        selectedDate = d;
      });
    }
  }



  Map<String, dynamic> collectData() {
    return {
      "name": name.text,
      "age": age,
      "gender": gender,
      "siblings": siblings,
      "birthOrder": birthOrder,
      "education": education.text,
      "maritalStatus": maritalStatus,
      "occupation": occupation.text,
      "religion": religion,
      "informant": informant.text,
      "hospital": hospital.text,
      "caseNo": caseNo.text,
      "date": selectedDate?.toIso8601String(),
      "previousDx": previousDx.text,
      "presentDx": presentDx.text,
      "address": address.text,
      "referralSource": referralSource.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HistoryViewModel>();
    return Directionality(
        textDirection:
        isUrdu ? TextDirection.rtl : TextDirection.ltr,child: Scaffold(
      appBar: AppBar(
        title: Text(tr("Case History Form", "کیس ہسٹری فارم")),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
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
                  context.read<HistoryViewModel>().setLanguage(v);
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr("Step 1 of 5", "مرحلہ 1 از 5"), style: AppTextStyles.small),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 1 / 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr("Bio Data", "ذاتی معلومات"),
                            style: AppTextStyles.bodyBold
                                .copyWith(color: AppColors.primary)),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: name,
                          style: const TextStyle(
                            color: AppColors
                                .primary, // 👈 text color inside field
                          ),
                          decoration: input(
                            tr("Name", "نام"),
                            controller: name,
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: age,
                          decoration: input(tr("Age","عمر")),
                          items: ageList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => age = v,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: gender,
                          decoration: input(tr("Gender","جنس")),
                          items: genderList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => gender = v,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: siblings,
                          decoration: input(tr("No. of siblings","بہن بھائیوں کی تعداد")),
                          items: siblingList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => siblings = v,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: birthOrder,
                          decoration: input(tr("Birth order","پیدائشی ترتیب")),
                          items: birthOrderList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => birthOrder = v,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: education,
                            decoration: input(tr("Education","تعلیم"),controller: education,)),
                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: maritalStatus,
                          decoration: input(tr("Marital Status","ازدواجی حیثیت"),),
                          items: maritalList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => maritalStatus = v,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: occupation,
                            decoration: input(tr("Occupation","پیشہ"),controller: occupation)),
                        const SizedBox(height: 12),

                        DropdownButtonFormField(
                          value: religion,
                          decoration: input(tr("Religion","مذہب"),),
                          items: religionList
                              .map((e) =>
                              DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => religion = v,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: informant,
                            decoration:
                            input(tr("Informant (if any)","معلومات فراہم کرنے والا"),controller: informant)),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: hospital,
                            decoration: input(tr("Hospital","ہسپتال"),controller: hospital)),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: caseNo,
                            decoration: input(tr("Case No","کیس نمبر"),controller: caseNo)),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: input(
                                selectedDate == null
                                    ? tr("Select Date", "تاریخ منتخب کریں")
                                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              ),

                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: previousDx,
                            decoration:
                            input(tr("Previous diagnosis","سابقہ تشخیص"),controller:previousDx)),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: presentDx,
                            decoration:
                            input(tr("Present diagnosis","موجودہ تشخیص"),controller:presentDx)),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: address,
                            decoration: input(tr("Address","پتہ"),controller:address)),
                        const SizedBox(height: 12),

                        TextFormField(
                            controller: referralSource,
                            decoration:
                            input(tr("Source of Referral","ریفرل کا ذریعہ"),controller:referralSource)),
                        const SizedBox(height: 25),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await vm.saveStep1(
                                    data: collectData(),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(tr("Draft saved","مسودہ محفوظ کریں"))),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    // 👈 PRIMARY BORDER
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(tr(
                                  "Save Draft","مسودہ محفوظ ہو گیا"),
                                  style: const TextStyle(
                                    color: AppColors.primary, // 👈 PRIMARY TEXT
                                  ),
                                ),
                              ),

                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;

                                  if (connectionId.isEmpty || patientUid.isEmpty || psychologistUid.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Missing connection data in Step 1")),
                                    );
                                    return;
                                  }

                                  await vm.startHistory(
                                    patientUid: patientUid,
                                    psychologistUid: psychologistUid,
                                  );

                                  historyId = vm.historyId ?? '';

                                  if (historyId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("History ID not created")),
                                    );
                                    return;
                                  }

                                  final ok = await vm.saveStep1(
                                    data: collectData(),
                                    moveNext: true,
                                  );

                                  if (!mounted) return;

                                  if (ok) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.historyStep3,
                                      arguments: {
                                        "connectionId": connectionId,
                                        "historyId": historyId,
                                        "patientUid": patientUid,
                                        "psychologistUid": psychologistUid,
                                      },
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    // 👈 PRIMARY BORDER
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(tr(
                                  "Continue","آگے بڑھیں"),
                                  style:  TextStyle(color: AppColors.card(context)),
                                ),
                              ),

                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  }
