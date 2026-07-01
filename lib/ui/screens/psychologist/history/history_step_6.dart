import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../data/services/connection_service.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class HistoryStep6 extends StatefulWidget {
  const HistoryStep6({super.key});

  @override
  State<HistoryStep6> createState() => _HistoryStep6State();
}

class _HistoryStep6State extends State<HistoryStep6> {
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  bool _argsLoaded = false;
  bool isLoading = false;
  final suspectedProblems = TextEditingController();

  final List<Map<String, String>> tests = [];
  final List<String> shortGoals = [];
  final List<String> longGoals = [];

  @override
  void dispose() {
    suspectedProblems.dispose();
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

    final draft = vm.getStepData(6);
    if (draft != null) {
      suspectedProblems.text = draft["suspectedProblems"] ?? "";

      final savedTests = (draft["tests"] as List?) ?? [];
      for (final t in savedTests) {
        tests.add({
          "name": (t["name"] ?? "").toString(),
          "rationale": (t["rationale"] ?? "").toString(),
        });
      }

      final savedShort = (draft["shortGoals"] as List?) ?? [];
      for (final g in savedShort) {
        shortGoals.add(g.toString());
      }

      final savedLong = (draft["longGoals"] as List?) ?? [];
      for (final g in savedLong) {
        longGoals.add(g.toString());
      }
    }
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.primary),
    filled: true,
    fillColor: AppColors.card(context),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  Widget _tf({
    required String label,
    required Function(String) onChanged,
    String initialValue = '',
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: _input(label),
        onChanged: onChanged,
      ),
    );
  }

  Map<String, dynamic> collectData() {
    return {
      "suspectedProblems": suspectedProblems.text.trim(),
      "tests": tests,
      "shortGoals": shortGoals,
      "longGoals": longGoals,
    };
  }

  String buildSummaryNote() {
    final buffer = StringBuffer();

    if (suspectedProblems.text.trim().isNotEmpty) {
      buffer.writeln("Suspected Problems:");
      buffer.writeln(suspectedProblems.text.trim());
      buffer.writeln();
    }

    if (tests.isNotEmpty) {
      buffer.writeln("Assessment Plan:");
      for (int i = 0; i < tests.length; i++) {
        final test = tests[i];
        buffer.writeln("- Test: ${test["name"] ?? ""}");
        buffer.writeln("  Rationale: ${test["rationale"] ?? ""}");
      }
      buffer.writeln();
    }

    if (shortGoals.isNotEmpty) {
      buffer.writeln("Short Term Goals:");
      for (final goal in shortGoals) {
        if (goal.trim().isNotEmpty) {
          buffer.writeln("- $goal");
        }
      }
      buffer.writeln();
    }

    if (longGoals.isNotEmpty) {
      buffer.writeln("Long Term Goals:");
      for (final goal in longGoals) {
        if (goal.trim().isNotEmpty) {
          buffer.writeln("- $goal");
        }
      }
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        title: const Text("Psychologist Notes"),
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Psychologist Step 2 of 2",
                    style: TextStyle(color: AppColors.primary),
                  ),
                  SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: 1,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: suspectedProblems,
                      maxLines: 4,
                      decoration: _input("Suspected Problems"),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      "Assessment Planning",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    for (int i = 0; i < tests.length; i++) ...[
                      _tf(
                        label: "Name of Test",
                        initialValue: tests[i]["name"] ?? "",
                        onChanged: (v) => tests[i]["name"] = v,
                      ),
                      _tf(
                        label: "Rationale of using the test",
                        initialValue: tests[i]["rationale"] ?? "",
                        onChanged: (v) => tests[i]["rationale"] = v,
                      ),
                      const Divider(),
                    ],

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          tests.add({"name": "", "rationale": ""});
                        });
                      },
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text(
                        "Add another test",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      "Management Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    for (int i = 0; i < shortGoals.length; i++)
                      _tf(
                        label: "Short Term Goal",
                        initialValue: shortGoals[i],
                        onChanged: (v) => shortGoals[i] = v,
                      ),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          shortGoals.add("");
                        });
                      },
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text(
                        "Add short term goal",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 10),

                    for (int i = 0; i < longGoals.length; i++)
                      _tf(
                        label: "Long Term Goal",
                        initialValue: longGoals[i],
                        onChanged: (v) => longGoals[i] = v,
                      ),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          longGoals.add("");
                        });
                      },
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text(
                        "Add long term goal",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final stepData = collectData();



                        final summaryNote = buildSummaryNote();
                        if (summaryNote.isNotEmpty) {
                          await ConnectionService().savePsychologistNote(
                            connectionId: connectionId,
                            patientUid: patientUid,
                            noteText: summaryNote,
                            stage: 'pre_assessment',
                          );
                        }

                        if (!mounted) return;

                        Navigator.pushNamed(
                          context,
                          AppRoutes.startAssessment,
                          arguments: {
                            "connectionId": connectionId,
                            "patientUid": patientUid,
                            "psychologistUid": psychologistUid,
                            "historyId": vm.historyId,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(
                        "Continue to Assessment",
                        style: TextStyle(color: AppColors.card(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}