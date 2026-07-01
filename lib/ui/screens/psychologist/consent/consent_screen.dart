import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes.dart';
import '../../../../data/services/connection_service.dart';
import '../../../../view_model/consent_viewmodel.dart';

import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../widgets/background_wrapper.dart';


class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final _formKey = GlobalKey<FormState>();
// Procedures
  bool isUrdu = false;

  String tr(String en, String ur) {
    return isUrdu ? ur : en;
  }

  bool clinicalInterview = false;
  bool standardizedQuestionnaires = false;
  bool treatmentPlanning = false;

// Confidentiality
  bool riskToSelfOrOthers = false;
  bool requiredByLaw = false;

  final patientName = TextEditingController();
  final attendantName = TextEditingController();
  final clinicianName = TextEditingController();

  bool agree = false;

  DateTime consentDate = DateTime.now();
  String? connectionId;
  String? patientCode;
  String? patientUid;
  String? psychologistUid;


  @override

  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      debugPrint("❌ ConsentScreen: arguments are NULL");
      return;
    }

    patientUid = args['patientUid'];
    patientCode = args['patientCode'];
    psychologistUid = args['psychologistUid'];
    connectionId = args['connectionId'];
    debugPrint("✅ ConsentScreen args:");
    debugPrint("patientUid = $patientUid");
    debugPrint("patientCode = $patientCode");
    debugPrint("psychologistUid = $psychologistUid");
  }



  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: consentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => consentDate = picked);
    }
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
    );
  }

  Widget sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppColors.primary),
    );
  }
  Widget consentCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      value: value,
      onChanged: onChanged,
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConsentViewModel(),
      child: Consumer<ConsentViewModel>(
        builder: (context, vm, _) {
          return Directionality(
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(

                appBar: AppBar(
                  backgroundColor: AppColors.card(context),
                  elevation: 0,
                  title: Text(
                    tr("Consent Form", "رضامندی فارم"),
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Row(
                      children: [
                        Text(
                          isUrdu ? "اردو" : "EN",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        Switch(
                          value: isUrdu,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() {
                              isUrdu = v;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),

                body: BackgroundWrapper(
              imagePath: "assets/background/icons.png",

              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (patientCode != null)
                          Text(
                            tr("Patient ID:", "مریض کا شناختی نمبر:") + " $patientCode",
                            style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                          ),

                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: input(
                                "${consentDate.day}/${consentDate.month}/${consentDate.year}",
                                Icons.calendar_today,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: patientName,
                          decoration: input( tr("Patient Name", "مریض کا نام"), Icons.person),
                          validator: (v) =>
                          v!.isEmpty ?  tr("Required", "ضروری ہے") : null,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: attendantName,
                          decoration: input(
                              tr("Attendant (if applicable)", "ساتھ آنے والا (اگر ہو)"), Icons.people),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: clinicianName,
                          decoration:
                          input(tr("Clinician", "معالج"), Icons.medical_services),
                          validator: (v) =>
                          v!.isEmpty ? tr("Required", "ضروری ہے")  : null,
                        ),

                        const SizedBox(height: 18),

                        sectionTitle(tr("Purpose of Service", "سروس کا مقصد")),
                        sectionText(
                            tr(
                                'I am receiving psychological assessment/therapy to evaluate my mental health condition.',
                                'میں اپنی ذہنی صحت کی جانچ اور علاج کے لیے نفسیاتی خدمات حاصل کر رہا/رہی ہوں۔'
                            )),


                        const SizedBox(height: 12),

                        sectionTitle(tr("Procedures", "طریقہ کار")),

                        consentCheckbox(
                          value: clinicalInterview,
                          onChanged: (v) => setState(() => clinicalInterview = v!),
                          text:tr("Clinical interview(s)", "کلینیکل انٹرویو"),
                        ),

                        consentCheckbox(
                          value: standardizedQuestionnaires,
                          onChanged: (v) => setState(() => standardizedQuestionnaires = v!),
                          text: tr("Standardized questionnaires (if used)", "معیاری سوالنامے (اگر استعمال ہوں)"),
                        ),

                        consentCheckbox(
                          value: treatmentPlanning,
                          onChanged: (v) => setState(() => treatmentPlanning = v!),
                          text: tr("Treatment planning and feedback", "علاج کی منصوبہ بندی اور رہنمائی"),
                        ),


                        const SizedBox(height: 12),

                        sectionTitle(tr("Confidentiality", "رازداری")),
                        sectionText(tr(
                            "All information is kept confidential except when:",
                            "تمام معلومات خفیہ رکھی جائیں گی سوائے ان حالات کے جب:"
                        )),

                        consentCheckbox(
                          value: riskToSelfOrOthers,
                          onChanged: (v) => setState(() => riskToSelfOrOthers = v!),
                          text: tr("There is risk of harm to self or others", "اپنے یا دوسروں کو نقصان کا خطرہ ہو"),
                        ),

                        consentCheckbox(
                          value: requiredByLaw,
                          onChanged: (v) => setState(() => requiredByLaw = v!),
                          text: tr("Required by law (court order, abuse, reporting, etc.)", "قانونی تقاضے (عدالتی حکم، زیادتی کی رپورٹ وغیرہ)"),
                        ),

                        const SizedBox(height: 12),

                        sectionTitle(tr("Risks & Benefits", "خطرات اور فوائد")),
                        sectionText(
                            tr(
                                "Discussing personal issues may feel uncomfortable, but benefits include improved mental well-being.",
                                "ذاتی مسائل پر بات کرنا مشکل ہو سکتا ہے، مگر اس سے ذہنی صحت بہتر ہو سکتی ہے۔"
                            ) ),

                        const SizedBox(height: 12),

                        sectionTitle(tr("Voluntary Participation", "رضاکارانہ شرکت")),
                        sectionText(
                            tr(
                                "My participation is voluntary. I may stop at any time.",
                                "میری شرکت رضاکارانہ ہے اور میں کسی بھی وقت روک سکتا/سکتی ہوں۔"
                            ) ),
                        sectionTitle(tr("Consent", "رضامندی")),
                        sectionText(
                            tr(
                                "I have read the above information and agree to receive services.",
                                "میں نے اوپر دی گئی معلومات پڑھ لی ہیں اور خدمات حاصل کرنے پر رضامند ہوں۔"
                            )                        ),



                        const SizedBox(height: 18),

                        CheckboxListTile(

                          activeColor: AppColors.primary,
                          value: agree,
                          onChanged: (v) => setState(() => agree = v!),
                          title: Text(
                            tr("I agree to this consent form", "میں اس رضامندی فارم سے متفق ہوں"),
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                              if (!_formKey.currentState!.validate() || !agree) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr("Please complete the form","برائے مہربانی فارم مکمل کریں۔"))),
                                );
                                return;
                              }
                              debugPrint("patientUid: $patientUid");
                              debugPrint("patientCode: $patientCode");
                              debugPrint("psychologistUid: $psychologistUid");

                              if (patientUid == null ||
                                  patientCode == null ||
                                  psychologistUid == null ||
                                  connectionId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(tr("Invalid consent data","رضامندی کا غلط ڈیٹا"))),
                                );
                                return;
                              }
                              if (!clinicalInterview &&
                                  !standardizedQuestionnaires &&
                                  !treatmentPlanning) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text(tr("Please select at least one procedure","براہ کرم کم از کم ایک طریقہ کار منتخب کریں۔"))),
                                );
                                return;
                              }


                              final success = await vm.submitConsent(
                                patientUid: patientUid!,
                                patientCode: patientCode!,
                                psychologistUid: psychologistUid!,
                                patientName: patientName.text.trim(),
                                attendantName: attendantName.text.trim(),
                                clinicianName: clinicianName.text.trim(),
                                consentDate: consentDate,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr("Consent saved successfully","رضامندی کامیابی کے ساتھ محفوظ ہو گئی۔"))),
                                );

                                debugPrint("patientUid = $patientUid");
                                debugPrint("patientCode = $patientCode");
                                debugPrint("psychologistUid = $psychologistUid");


                                // ✅ USE YOUR ROUTE
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.patientDashboard
                                );
                                await ConnectionService().markConsentSubmitted(
                                  connectionId: connectionId!,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: vm.isLoading
                                ?  CircularProgressIndicator(color: AppColors.card(context))
                                :  Text(
                              tr("Next", "اگلا مرحلہ"),
                              style: TextStyle(color: AppColors.card(context), fontSize: 18),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
              )
          );
        },
      ),
    );
  }
}
