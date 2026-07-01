import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({super.key});

  String getRecommendation(String code, int score) {
    switch (code) {

      case "bdi": // depression
        if (score >= 30) {
          return "Severe depression → CBT + psychiatric referral recommended.";
        } else if (score >= 20) {
          return "Moderate depression → CBT + lifestyle changes.";
        } else {
          return "Mild depression → Counseling + lifestyle improvement.";
        }

      case "anxiety":
        if (score >= 25) {
          return "High anxiety → CBT + relaxation techniques.";
        } else {
          return "Mild anxiety → Breathing exercises + stress management.";
        }

      case "insomnia":
        if (score >= 21) {
          return "Severe insomnia → Sleep therapy + medical consultation.";
        } else {
          return "Mild insomnia → Sleep hygiene improvement.";
        }

      default:
        return "Follow clinical evaluation for appropriate treatment.";
    }
  }
  String _shortLabel(String severity) {
    final s = severity.toLowerCase();
    if (s.contains("normal")) return "Normal";
    if (s.contains("mild")) return "Mild";
    if (s.contains("borderline")) return "Borderline";
    if (s.contains("moderate")) return "Moderate";
    if (s.contains("severe")) return "Severe";
    if (s.contains("extreme")) return "Extreme";
    return severity;
  }
  List<String> _diagnosisLabels(String assessmentCode) {
    switch (assessmentCode) {
      case "bdi":
        return ["Normal", "Mild", "Borderline", "Moderate", "Severe+"];

      case "stress":
        return ["Low", "Vulnerable", "Serious", "Extreme", "High"];

      case "anxiety":
        return ["Low", "Moderate", "High", "Very High", "Extreme"];

      case "wellbeing":
        return ["Poor", "Low", "Average", "Good", "Excellent"];

      case "ptsd":
        return ["Low", "Mild", "Moderate", "High", "Positive"];

      case "ocd":
        return ["Minimal", "Mild", "Moderate", "Severe", "Extreme"];

      case "adhd":
        return ["Low", "Borderline", "Likely", "High", "Very High"];

      case "suicide_intent":
        return ["Low", "Guarded", "Medium", "High", "Critical"];

      case "self_esteem":
        return ["Low", "Below Avg", "Normal", "Good", "High"];

      case "insomnia":
        return ["None", "Subthreshold", "Moderate", "Severe", "Very Severe"];

      default:
        return ["Low", "Mild", "Moderate", "High", "Severe"];
    }
  }
  double _categoryPositionFromScore(int score, String assessmentCode) {
    double position = 0.5;

    switch (assessmentCode) {

      case "anxiety":
        if (score <= 21) return 0.2; // Low
        if (score <= 35) return 0.5; // Moderate
        return 0.8; // High

      case "wellbeing":
        if (score <= 60) return 0.2; // Low wellbeing
        if (score <= 90) return 0.5; // Moderate
        return 0.8; // High wellbeing

      case "self_esteem":
        if (score < 15) return 0.2; // Low
        if (score < 25) return 0.5; // Normal
        return 0.8; // High

      case "bdi":
        if (score <= 10) return 0.1;
        if (score <= 16) return 0.3;
        if (score <= 20) return 0.5;
        if (score <= 30) return 0.7;
        return 0.9;

      case "stress":
        if (score <= 5) return 0.2;
        if (score <= 24) return 0.5;
        return 0.8;

      case "ocd":
        if (score < 8) return 0.1;
        if (score <= 15) return 0.3;
        if (score <= 23) return 0.5;
        if (score <= 31) return 0.7;
        return 0.9;

      case "insomnia":
        if (score <= 7) return 0.2;
        if (score <= 14) return 0.4;
        if (score <= 21) return 0.6;
        return 0.85;

      case "suicide_intent":
        if (score <= 10) return 0.2;
        if (score <= 20) return 0.5;
        return 0.9;

      case "adhd":
        if (score <= 2) return 0.3;
        return 0.8;

      case "ptsd":
        return score >= 50 ? 0.85 : 0.35;

      default:
        return 0.5;
    }
  }  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final score = args["score"] ?? 0;
    final severity = (args["severity"] ?? "").toString();
    final assessmentCode = (args["assessmentCode"] ?? "").toString();
    final recommendation = getRecommendation(assessmentCode, score);
    final suicidalRiskFlag = args["suicidalRiskFlag"] ?? false;

    final labels = _diagnosisLabels(assessmentCode);
    final pointerPosition = _categoryPositionFromScore(score, assessmentCode);
    final probablePtsd = args["probablePtsd"] ?? false;
    final bClusterCount = args["bClusterCount"] ?? 0;
    final cClusterCount = args["cClusterCount"] ?? 0;
    final dClusterCount = args["dClusterCount"] ?? 0;
    String helperText;
    switch (assessmentCode) {
      case "stress":
        helperText = "This Assessment helps measure vulnerability to stress.";
        break;
      case "anxiety":
        helperText = "This Assessment helps measure the severity of anxiety.";
        break;
      case "wellbeing":
        helperText = "This Assessment helps measure overall wellbeing.";
        break;
      case "bdi":
        helperText = "This Assessment helps measure the severity of depression.";
        break;
      case "ptsd":
        helperText = "This Assessment helps screen PTSD symptoms over the past month.";
        break;
      case "ocd":
        helperText = "This assessment screens obsessive compulsive symptoms.";
        break;
      case "adhd":
        helperText = "This screening evaluates symptoms consistent with Adult ADHD.";
        break;
      case "suicide_intent":
        helperText =
        "This assessment measures suicide intent and risk level.";
        break;
      case "insomnia":
        helperText = "This assessment measures insomnia severity and sleep disturbance.";
        break;
      default:
        helperText = "This Assessment helps measure the patient's condition.";
    }
    if (recommendation.isNotEmpty) [...[
    const SizedBox(height: 16),
    Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.orange.shade50,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.orange),
    ),
    child: Text(
    recommendation,
    style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    ),
    ]];
    return Scaffold(
      backgroundColor: const Color(0xffF6F8F7),
      appBar: AppBar(
        title: const Text("Assessment Result"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        elevation: 0,
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffEAF4F1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xffBFD8D2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        size: 42,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Total Score",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$score",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _shortLabel(severity),
                          style:  TextStyle(
                            color: AppColors.card(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Diagnosis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: labels
                          .map(
                            (label) => Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff51C1AF),
                                  Color(0xff83D0BA),
                                  Color(0xffE9D77B),
                                  Color(0xffF3A26F),
                                  Color(0xffE26A87),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(
                              pointerPosition * 2 - 1,
                              0,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (assessmentCode == "ptsd") ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card(context).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffC9D9D4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PTSD Screening Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("B cluster symptoms: $bClusterCount / required 1"),
                        Text("C cluster symptoms: $cClusterCount / required 3"),
                        Text("D cluster symptoms: $dClusterCount / required 2"),
                        const SizedBox(height: 10),
                        Text(
                          probablePtsd
                              ? "Result: Probable PTSD screen positive"
                              : "Result: PTSD screen negative by DSM-IV symptom rule",
                          style: TextStyle(
                            color: probablePtsd ? Colors.redAccent : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                 Text(
                  helperText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff527775),
                    fontSize: 13,
                  ),
                ),

                if (suicidalRiskFlag == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: const Text(
                      "Alert: suicidal thoughts item is above zero. Please review clinically.",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Color(0xffF3AA28), size: 28),
                      SizedBox(width: 8),


                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (recommendation.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  const Text(
                    "Clinical Recommendation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Text(recommendation),
                  ),
                ],


                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.psychologistDashboard,
                                (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.reply, color: AppColors.primary),
                        label: const Text(
                          "Return",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.prescriptionFollowup,
                            arguments: {
                              "assessmentId": args["assessmentId"],
                              "connectionId": args["connectionId"],
                              "patientUid": args["patientUid"],
                              "psychologistUid": args["psychologistUid"],
                              "historyId": args["historyId"],
                              "score": args["score"],
                              "severity": args["severity"],
                              "assessmentCode": args["assessmentCode"],
                              "assessmentName": args["assessmentName"],

                            },
                          );
                        },                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(Icons.note_alt_outlined, color: AppColors.card(context)),
                        label:  Text(
                          "Prescription",
                          style: TextStyle(color: AppColors.card(context)),
                        ),
                      ),
                    ),
                  ],
                )              ],
            ),
          ),
        ),
      ),
    );
  }


}