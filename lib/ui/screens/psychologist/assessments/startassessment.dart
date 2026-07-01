import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../data/constants/assessment_data.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class StartAssessmentScreen extends StatefulWidget {
  const StartAssessmentScreen({super.key});

  @override
  State<StartAssessmentScreen> createState() => _StartAssessmentScreenState();
}

class _StartAssessmentScreenState extends State<StartAssessmentScreen> {
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  bool _argsLoaded = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8F7),
      appBar: AppBar(
        title: const Text("Patient Assessment"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        elevation: 0,
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: assessmentCategories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = assessmentCategories[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(context).withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text(context).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xffD9E7E4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xffEAF4F1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!item.enabled) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${item.title} coming soon"),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.assessmentQuestionnaire,
                                  arguments: {
                                    "connectionId": connectionId,
                                    "patientUid": patientUid,
                                    "psychologistUid": psychologistUid,
                                    "historyId": historyId,
                                    "assessmentCode": item.code,
                                    "assessmentName": item.subtitle,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.enabled
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                item.enabled ? "Begin Assessment" : "Coming Soon",
                                style:  TextStyle(
                                  color: AppColors.card(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}