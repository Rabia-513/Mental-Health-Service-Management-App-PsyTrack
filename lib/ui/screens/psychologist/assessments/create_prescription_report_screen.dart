import 'package:flutter/material.dart';

import '../../../../data/services/prescription_report_service.dart';
import '../../../common/psychologist_main_screen.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class CreatePrescriptionReportScreen extends StatefulWidget {
  const CreatePrescriptionReportScreen({super.key});

  @override
  State<CreatePrescriptionReportScreen> createState() =>
      _CreatePrescriptionReportScreenState();
}

class _CreatePrescriptionReportScreenState
    extends State<CreatePrescriptionReportScreen> {
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String assessmentId = '';
  String patientName = '';
  String patientCode = '';
  String patientAge = '26';
  bool _argsLoaded = false;
  double sessionImprovement = 0;
  final medNameController = TextEditingController();
  final dosageController = TextEditingController();
  final frequencyController = TextEditingController();
  final instructionsController = TextEditingController();
  final suggestionController = TextEditingController();
  final notesController = TextEditingController();
  final notesUrduController = TextEditingController();
  final lifestyleController = TextEditingController();
  int? sessionNumber;
  final List<Map<String, String>> medications = [];
  final List<String> lifestyleRecommendations = [];
  final List<String> suggestions = [];

  String selectedDuration = "7 days";
  bool medicationReminder = true;
  bool saving = false;

  @override
  void dispose() {
    medNameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    instructionsController.dispose();
    suggestionController.dispose();
    notesController.dispose();
    notesUrduController.dispose();
    lifestyleController.dispose();
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
    assessmentId = (args["assessmentId"] ?? "").toString();
    patientName = (args["patientName"] ?? "").toString();
    patientCode = (args["patientCode"] ?? "").toString();
    patientAge = (args["patientAge"] ?? "26").toString();
    sessionNumber = args["sessionNumber"];
  }

  void addMedication() {
    if (medNameController.text.trim().isEmpty) return;

    setState(() {
      medications.add({
        "name": medNameController.text.trim(),
        "dosage": dosageController.text.trim(),
        "frequency": frequencyController.text.trim(),
      });
      medNameController.clear();
      dosageController.clear();
      frequencyController.clear();
    });
  }

  void addSuggestion() {
    if (suggestionController.text.trim().isEmpty) return;
    setState(() {
      suggestions.add(suggestionController.text.trim());
      suggestionController.clear();
    });
  }
  void addLifestyleRecommendation() {
    if (lifestyleController.text.trim().isEmpty) return;

    setState(() {
      lifestyleRecommendations.add(lifestyleController.text.trim());
      lifestyleController.clear();
    });
  }
  Future<void> savePrescription() async {
    setState(() => saving = true);

    try {
      await PrescriptionReportService().createAndSavePrescriptionReport(
        connectionId: connectionId,
        patientUid: patientUid,
        psychologistUid: psychologistUid,
        assessmentId: assessmentId,
        patientName: patientName,
        patientCode: patientCode,
        patientAge: patientAge,
        notes: notesController.text.trim(),
        notesUrdu: notesUrduController.text.trim(),
        medications: medications,
        instructions: instructionsController.text.trim(),
        duration: selectedDuration,
        medicationReminder: medicationReminder,
        lifestyleRecommendations: lifestyleRecommendations,
        suggestions: suggestions,
        sessionImprovement: sessionImprovement,
        sessionNumber: sessionNumber,

      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prescription PDF saved successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save prescription: $e")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.primary),
    filled: true,
    fillColor: const Color(0xffDDEAE6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PsychologistMainScreen(
        selectedIndex: 3, // stats

        child: Scaffold(
      backgroundColor: const Color(0xffF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F7F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Prescription",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "Prescribe medication for the patient",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _patientHeader(),
                const SizedBox(height: 16),
                _medicationCard(),
                const SizedBox(height: 16),
                _lifestyleCard(),
                const SizedBox(height: 16),
                _suggestionCard(),
                const SizedBox(height: 16),
                _notesCard(),
                const SizedBox(height: 16),
                _sessionImprovementCard(),
                const SizedBox(height: 16),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving ? null : savePrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: saving
                        ?  CircularProgressIndicator(color: AppColors.card(context))
                        : Text(
                      "Save",
                      style: TextStyle(
                        color: AppColors.card(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _patientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffDDEAE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff8FB9B4), width: 3),
            ),
            child: const Icon(Icons.person, size: 52, color: Color(0xff8FB9B4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName.isEmpty ? "Patient" : patientName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),                const SizedBox(height: 6),
                Text(
                  "Age: $patientAge",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Patient ID: $patientCode",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.assignment_add,
            size: 70,
            color: Color(0xff6D67A9),
          ),
        ],
      ),
    );
  }

  Widget _medicationCard() {
    final durations = ["5 days", "7 days", "10 days", "15 days"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Medication Details",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: medNameController,
            decoration: _input("Sertraline (Zoloft)"),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dosageController,
                  decoration: _input("50 mg"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: frequencyController,
                  decoration: _input("1 tablet daily"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Instructions",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: instructionsController,
            decoration: _input("Take after breakfast. Avoid smoking."),
          ),
          const SizedBox(height: 14),
          const Text(
            "Duration",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: durations.map((d) {
              final selected = selectedDuration == d;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedDuration = d);
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : const Color(0xffE8F1EF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      color: selected ? AppColors.card(context) : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) {
              if (v.trim().isNotEmpty) {
                selectedDuration = v.trim();
              }
            },
            decoration: _input("Custom days"),
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 320,
              child: OutlinedButton.icon(
                onPressed: addMedication,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                label: const Text(
                  "Add Another Medication",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),
          if (medications.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...medications.map(
                  (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.medication, color: AppColors.primary),
                title: Text(m["name"] ?? ""),
                subtitle: Text(
                  "${m["dosage"] ?? ""} | ${m["frequency"] ?? ""}",
                ),
              ),
            ),
          ],

        ],
      ),
    );
  }

  Widget _lifestyleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lifestyle Recommendations",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Provide additional wellbeing tips for the patient.",
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: lifestyleController,
            decoration: _input("Enter lifestyle recommendation"),
          ),
          const SizedBox(height: 12),

          Center(
            child: SizedBox(
              width: 320,
              child: OutlinedButton.icon(
                onPressed: addLifestyleRecommendation,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                label: const Text(
                  "Add Another Recommendation",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),

          if (lifestyleRecommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...lifestyleRecommendations.map(
                  (e) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffDDEAE6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  e,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _suggestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suggestions",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Provide additional advice tips for the patient",
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: suggestionController,
            decoration: _input("Any advice"),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 320,
              child: OutlinedButton.icon(
                onPressed: addSuggestion,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                label: const Text(
                  "Add Another Suggestion",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...suggestions.map(
                  (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                title: Text(
                  e,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patient Advice / Report",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "English Advice",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 5,
            decoration: _input("Write psychologist advice and report"),
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 8),
          TextField(
            controller: notesUrduController,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            decoration: _input("اردو میں ہدایات لکھیں"),
          ),
        ],
      ),
    );
  }
  Widget _sessionImprovementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Session Improvement",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${sessionImprovement.toInt()}%",
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: sessionImprovement,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primary,
            label: "${sessionImprovement.toInt()}%",
            onChanged: (value) {
              setState(() {
                sessionImprovement = value;
              });
            },
          ),
          const Text(
            "This is saved in Firestore but not shown in PDF.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }}