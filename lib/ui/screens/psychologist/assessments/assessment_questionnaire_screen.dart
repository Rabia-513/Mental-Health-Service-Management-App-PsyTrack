import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../data/constants/assessment_data.dart';
import '../../../../data/services/assessment_scoring_service.dart';
import '../../../../data/services/assessment_service.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class AssessmentQuestionnaireScreen extends StatefulWidget {
  const AssessmentQuestionnaireScreen({super.key});

  @override
  State<AssessmentQuestionnaireScreen> createState() =>
      _AssessmentQuestionnaireScreenState();
}

class _AssessmentQuestionnaireScreenState
    extends State<AssessmentQuestionnaireScreen> {
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  String assessmentCode = '';
  String assessmentName = '';
  bool _argsLoaded = false;

  int currentIndex = 0;
  late List<int> selectedAnswers;
  bool saving = false;

  List<AssessmentQuestion> get currentQuestions {
    switch (assessmentCode) {
      case 'bdi':
        return beckDepressionQuestions;
      case 'stress':
        return stressChecklistQuestions;
      case 'anxiety':
        return beckAnxietyQuestions;
      case 'wellbeing':
        return bbcWellbeingQuestions;
      case 'ptsd':
        return pclcQuestions;
      case 'ocd':
        return ocdQuestions;
      case 'adhd':
        return adhdQuestions;
      case 'suicide_intent':
        return suicideIntentQuestions;
      case 'self_esteem':
        return selfEsteemQuestions;
      case 'insomnia':
        return insomniaQuestions;

      default:
        return [];
    }
  }
  String get assessmentHelperText {
    switch (assessmentCode) {
      case 'bdi':
        return "This Assessment helps measure the severity of depression.";
      case 'stress':
        return "This Assessment helps measure vulnerability to stress.";
      case 'anxiety':
        return "This Assessment helps measure the severity of anxiety.";
      case 'wellbeing':
        return "This Assessment helps measure overall wellbeing.";
      case 'ptsd':
        return "This Assessment helps screen PTSD symptoms over the past month.";
      case 'ocd':
        return "This assessment screens obsessive compulsive symptoms.";
      case 'adhd':
        return "This assessment screens symptoms of Adult ADHD using the ASRS v1.1 scale.";
      case 'suicide_intent':
        return "This assessment evaluates suicide intent and level of risk.";
      case 'self_esteem':
        return "This assessment measures overall self-esteem using the Rosenberg scale.";
      case 'insomnia':
        return "This assessment measures the severity of insomnia symptoms over the past two weeks.";
      default:
        return "This Assessment helps measure the patient's condition.";
    }
  }

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(currentQuestions.length, -1);  }

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
    assessmentCode = (args["assessmentCode"] ?? "").toString();
    assessmentName = (args["assessmentName"] ?? "").toString();

    selectedAnswers = List.filled(currentQuestions.length, -1);
  }

  Future<void> submitAssessment() async {
    if (selectedAnswers.contains(-1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final result = AssessmentScoringService.scoreAssessment(
        assessmentCode: assessmentCode,
        answers: selectedAnswers,
      );

      final assessmentId = await AssessmentService().saveAssessment(
        connectionId: connectionId,
        patientUid: patientUid,
        psychologistUid: psychologistUid,
        historyId: historyId,
        assessmentCode: assessmentCode,
        assessmentName: assessmentName,
        answers: selectedAnswers,
        score: result["score"],
        severity: result["severity"],
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.assessmentResult,
        arguments: {
          "assessmentId": assessmentId,
          "connectionId": connectionId,
          "patientUid": patientUid,
          "psychologistUid": psychologistUid,
          "historyId": historyId,
          "assessmentCode": assessmentCode,
          "score": result["score"],
          "severity": result["severity"],
          "suicidalRiskFlag": result["suicidalRiskFlag"],
          "probablePtsd": result["probablePtsd"] ?? false,
          "bClusterCount": result["bClusterCount"] ?? 0,
          "cClusterCount": result["cClusterCount"] ?? 0,
          "dClusterCount": result["dClusterCount"] ?? 0,
          "adhdLikely": result["adhdLikely"] ?? false,
          "recommendation": result["recommendation"],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save assessment: $e")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Assessment"),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.card(context),
        ),
        body: const Center(child: Text("Assessment not found")),
      );
    }

    final question = currentQuestions[currentIndex];
    final progress = (currentIndex + 1) / currentQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8F7),
      appBar: AppBar(
        title: const Text("Assessment"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        elevation: 0,
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Text(
                      "Question ${question.number} / ${currentQuestions.length}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xffE4ECEA),
                        color: const Color(0xff9BD6C9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card(context).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "assets/background/assiicons.png",
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                             Text(
                              assessmentHelperText,                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xff527775),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Question ${question.number}:",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...List.generate(question.options.length, (optionIndex) {
                              final selected =
                                  selectedAnswers[currentIndex] == optionIndex;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswers[currentIndex] = optionIndex;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xffDDF3EC)
                                        : AppColors.card(context),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xff4ABF87)
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: selected
                                            ? const Color(0xff18B66A)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          question.options[optionIndex],
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: currentIndex == 0
                              ? null
                              : () {
                            setState(() {
                              currentIndex--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: AppColors.card(context).withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            "Previous",
                            style: TextStyle(
                              color: currentIndex == 0
                                  ? Colors.grey
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () {
                            if (currentIndex == currentQuestions.length - 1) {
                              submitAssessment();
                            } else {
                              if (selectedAnswers[currentIndex] == -1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Select one option"),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                currentIndex++;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: saving
                              ?  CircularProgressIndicator(color: AppColors.card(context))
                              : Text(
                            currentIndex == currentQuestions.length - 1
                                ? "SUBMIT"
                                : "Next",
                            style:  TextStyle(
                              color: AppColors.card(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}