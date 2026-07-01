import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';
import '../../widgets/background_wrapper.dart';

class HistoryStep2 extends StatefulWidget {
  const HistoryStep2({super.key});

  @override
  State<HistoryStep2> createState() => _HistoryStep2State();
}

class _HistoryStep2State extends State<HistoryStep2> {
  final _formKey = GlobalKey<FormState>();

  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String historyId = '';
  bool _argsLoaded = false;

  final clientAccount = TextEditingController();
  final informantAccount = TextEditingController();
  final initialObservation = TextEditingController();

  @override
  void dispose() {
    clientAccount.dispose();
    informantAccount.dispose();
    initialObservation.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argsLoaded) return;
    _argsLoaded = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

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

    final draft = vm.getStepData(2);
    if (draft != null) {
      clientAccount.text = draft["clientAccount"] ?? "";
      informantAccount.text = draft["informantAccount"] ?? "";
      initialObservation.text = draft["initialObservation"] ?? "";
    }
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: AppColors.card(context),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Map<String, dynamic> collectData() {
    return {
      "clientAccount": clientAccount.text.trim(),
      "informantAccount": informantAccount.text.trim(),
      "initialObservation": initialObservation.text.trim(),
    };
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Psychologist Step 1 of 2"),
                    SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 0.5,
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
                        Text(
                          "Clinical Observations",
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: clientAccount,
                          maxLines: 5,
                          decoration: input("Client’s Account"),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: informantAccount,
                          maxLines: 5,
                          decoration: input("Informant’s Account"),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: initialObservation,
                          maxLines: 5,
                          decoration: input("Initial Observation"),
                        ),
                      ],
                    ),
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
                          await FirebaseFirestore.instance
                              .collection("psychologist_notes")
                              .add({
                                "connectionId": connectionId,
                                "patientUid": patientUid,
                                "psychologistUid": psychologistUid,
                                "stage": "clinical_observation",
                                "noteText":
                                    """
Client Account:
${clientAccount.text}

Informant Account:
${informantAccount.text}

Initial Observation:
${initialObservation.text}
""",
                                "createdAt": FieldValue.serverTimestamp(),
                              });

                          Navigator.pushNamed(
                            context,
                            AppRoutes.historyStep6,
                            arguments: {
                              "connectionId": connectionId,
                              "patientUid": patientUid,
                              "psychologistUid": psychologistUid,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Continue",
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
      ),
    );
  }
}
