
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../ui/screens/styles/colors.dart';

class PdfService {

  final List<String> visiblePatientSteps = [
    "step1",
    "step3",
    "step4",
    "step5",
  ];

  final Map<String, String> stepTitlesEn = {
    "step1": "Bio Data",
    "step3": "History of Present Illness",
    "step4": "Family & Home Background",
    "step5": "Personal History",
  };

  final Map<String, String> stepTitlesUr = {
    "step1": "ذاتی معلومات",
    "step3": "موجودہ بیماری کی تاریخ",
    "step4": "خاندانی اور گھریلو پس منظر",
    "step5": "ذاتی تاریخ",
  };
  String _normalizeKey(String key) {
    return key.replaceAll(" ", "").toLowerCase();
  }
  String getStepTitle(String stepKey, bool isUrdu) {
    if (isUrdu) {
      return stepTitlesUr[stepKey] ?? stepKey.toUpperCase();
    }
    return stepTitlesEn[stepKey] ?? stepKey.toUpperCase();
  }
  final Map<String, List<String>> stepOrder = {

    "step1": [
      "name",
      "age",
      "gender",
      "siblings",
      "birthOrder",
      "education",
      "maritial Status",
      "occupation",
      "religion",
      "informant",
      "hospital",
      "caseNo",
      "date",
      "previousDx",
      "presentDx",
      "address",
      "referralSource",
    ],


    "step3": [
      "when problrm started",
      "presentation",
      "modeOfOnset",
      "circumstances",
      "clientThoughts",
      "addictionHistory",
      "addictionDetails",
      "treatmentToggle",
      "treatmentTaken",
      "treatmentDuration",
      "improvementLevel",
      "treatmentReason",
      "physicalIllnessHistory",
      "treatmentEffect",
      "seizureToggle",
      "seizureAge",
      "seizureBehavior",
      "seizureTreatment",
      "seizureDuration",
      "seizurePresentStatus",
    ],

    "step4": [
      "fatherName",
      "fatherAge",
      "fatherEducation",
      "fatherOccupation",
      "fatherIncome",
      "fatherMarriages",
      "fatherHealthProblem",
      "fatherPsychologicalProblem",
      "fatherRelationClient",
      "fatherRelationChildren",
      "fatherClientOpinion",
      "fatherReactionAttitude",
      "fatherConsidersClientOpinion",
      "totalFamilyMembers",
      "familyStatus",
      "causeOfDeath",
      "reactionToFatherDeath",
    ], // handled separately

    "step5": [
      "pregnancyHealth",
      "deliveryType",
      "deliveryComplications",
      "neurotic",
      "childhoodOpinion",
      "peerAttitude",
      "behaviourType",
      "punishedBehaviours",
      "rewardAttitude",
      "rewardMethods",
      "stories",
      "sleepAge",
      "happyEvent",
      "sadEvent",
      "childhoodHobbies",
      "developmentCircumstances",
      "sexual",
      "pubertyAge",
      "childLabor",
      "schoolStartAge",
      "schoolEndAge",
      "schoolOpinion",
      "teacherRelation",
      "studyAttitude",
      "popularity",
      "educationAptitude",
      "academicActivities",
      "dislikedTeacher",
      "classPosition",
      "educationAdequacy",
      "parentStudyReaction",
      "regularity",
      "educationReasons",
      "work",
      "workStartAge",
      "presentOccupation",
      "previousJobs",
      "leaveReason",
      "colleagueAttitude",
      "workReaction",
      "bossBehaviour",
      "jobSatisfaction",
      "jobAptitude",
      "incomeAttitude",
      "premorbid",
      "friends",
      "friendActivities",
      "hobbies",
      "dislikes",
    ],
  };

  String getBilingualLabel(String key) {

    return key;
  }
  Future<dynamic> _processValue(String value) async {
    if (_containsUrdu(value)) {
      final bytes = await _captureTextAsImage(value);
      return pw.MemoryImage(bytes);
    } else {
      return value;
    }
  }
  Future<dynamic> _deepProcess(dynamic v) async {
    if (v == null) return null;

    // Map -> process each value
    if (v is Map) {
      final out = <String, dynamic>{};

      for (final e in v.entries) {
        final key = e.key.toString();

        /// 🔥 PROCESS VALUE
        out[key] = await _deepProcess(e.value);


      }

      return out;
    }

    // List -> process each item
    if (v is List) {
      return Future.wait(v.map((x) => _deepProcess(x)));
    }

    // Primitive -> toString then Urdu check
    final s = v.toString();

    // ignore "false"
    if (s == "false") return null;

    if (_containsUrdu(s)) {
      final bytes = await _captureTextAsImage(s);
      return pw.MemoryImage(bytes); // ✅ store as MemoryImage
    }

    return s;
  }

  bool _containsUrdu(String text) {
    final urduRegex = RegExp(r'[\u0600-\u06FF]');
    return urduRegex.hasMatch(text);
  }
  Future<Uint8List> _captureTextAsImage(String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textStyle = TextStyle(
      fontSize: 9,
      fontFamily: 'NotoSansArabic',
      color: AppColors.textDark,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: 400);
    textPainter.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      textPainter.width.ceil(),
      textPainter.height.ceil(),
    );

    final byteData =
    await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> generateHistoryPdf({
    required Map<String, dynamic> allStepsData,
    required String patientUid,
    required String psychologistUid,
    required String language,
  }) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/NotoSansArabic-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final isUrdu = language == "urdu";

    final stepKeys = allStepsData.keys
        .where((k) => k.toString().startsWith("step") && visiblePatientSteps.contains(k.toString()))
        .toList()
      ..sort((a, b) => int.parse(a.toString().replaceAll("step", ""))
          .compareTo(int.parse(b.toString().replaceAll("step", ""))));

    final Map<String, dynamic> processedSteps = {};
    for (final step in allStepsData.keys) {
      final raw = allStepsData[step];
      if (raw is Map) {
        final processed = await _deepProcess(raw);
        processedSteps[step.toString()] = processed;
      } else {
        processedSteps[step.toString()] = {};
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) {
          return [
            pw.Text(
              isUrdu ? "کیس ہسٹری رپورٹ" : "CASE HISTORY REPORT",
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            for (final step in stepKeys)
              _buildStep(
                stepKey: step,
                data: Map<String, dynamic>.from(processedSteps[step] ?? {}),
                font: ttf,
                isUrdu: isUrdu,
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildStep({
    required String stepKey,
    required Map<String, dynamic> data,
    required pw.Font font,
    required bool isUrdu,
  }) {
    final orderedKeys = stepOrder[stepKey] ?? [];
    List<pw.Widget> stepWidgets = [];
    if (stepKey == "step4") {
      List<pw.Widget> stepWidgets = [];

      final father = data["father"] ?? {};

      // Title
      stepWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey300,
          child: pw.Text(
            "Father's Section",
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 12));

      // ✅ Correct data mapping
      stepWidgets.add(_buildLabelValueRow("Father's Name:", father["name"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Age:", father["age"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Education:", father["education"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Occupation:", father["occupation"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Monthly Income:", father["income"], font));
      stepWidgets.add(_buildLabelValueRow("Father's No. of Marriages:", father["marriages"], font));

      stepWidgets.add(_buildLabelValueRow("Father's Health Problem:", father["healthProblem"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Psychological Problem:", father["psychProblem"], font));

      stepWidgets.add(_buildLabelValueRow("Father's Relationship with Client:", father["relationClient"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Relationship with Children:", father["relationChildren"], font));

      stepWidgets.add(_buildLabelValueRow("Father's Client Opinion:", father["clientOpinion"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Reaction to Attitude:", father["reactionAttitude"], font));
      stepWidgets.add(_buildLabelValueRow("Father's Consideration of Client's Opinion:", father["considersOpinion"], font));

      // Family
      stepWidgets.add(_buildLabelValueRow("Total Family Members:", father["familyMembers"], font));
      stepWidgets.add(_buildLabelValueRow("Family Status:", father["familyStatus"], font));

      // Death section (only if exists)
      if (father["dead"] == true) {
        stepWidgets.add(_buildLabelValueRow("Cause of Death:", father["causeOfDeath"], font));
        stepWidgets.add(_buildLabelValueRow("Client's Reaction to Father's Death:", father["reactionOnDeath"], font));
      }

      // Temperament
      stepWidgets.add(
        pw.Text(
          "Temperaments:",
          style: pw.TextStyle(font: font, fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 6));

      List<String> temperaments = [
        "Friendly", "Cooperative", "Quiet", "Introvert", "Extrovert",
        "Anger prone", "Careless", "Rigid", "Helpful", "Expressive"
      ];

      final selectedTemps = List<String>.from(father["temperament"] ?? []);

      if (selectedTemps.isNotEmpty) {
        stepWidgets.add(
          pw.Text(
            "Temperaments: ${selectedTemps.join(", ")}",
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        );
      }
      stepWidgets.add(pw.SizedBox(height: 10));
      final mother = data["mother"] ?? {};

      stepWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey300,
          child: pw.Text(
            "Mother's Section",
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 12));

// Basic fields
      stepWidgets.add(_buildLabelValueRow("Mother's Name:", mother["name"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Age:", mother["age"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Education:", mother["education"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Occupation:", mother["occupation"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Monthly Income:", mother["income"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's No. of Marriages:", mother["marriages"], font));

      stepWidgets.add(_buildLabelValueRow("Mother's Health Problem:", mother["healthProblem"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Psychological Problem:", mother["psychProblem"], font));

      stepWidgets.add(_buildLabelValueRow("Mother's Relationship with Client:", mother["relationClient"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Client Opinion:", mother["clientOpinion"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Reaction to Attitude:", mother["reactionAttitude"], font));
      stepWidgets.add(_buildLabelValueRow("Mother's Consideration of Client's Opinion:", mother["considersOpinion"], font));

// Death toggle
      if (mother["dead"] == true) {
        stepWidgets.add(_buildLabelValueRow("Cause of Death:", mother["causeOfDeath"], font));
        stepWidgets.add(_buildLabelValueRow("Client's Reaction to Mother's Death:", mother["reactionOnDeath"], font));
      }

// ✅ ONLY SELECTED TEMPERAMENTS
      final motherTemps = List<String>.from(mother["temperament"] ?? []);

      if (motherTemps.isNotEmpty) {
        stepWidgets.add(
          pw.Text(
            "Temperaments: ${motherTemps.join(", ")}",
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        );
      }

      stepWidgets.add(pw.SizedBox(height: 10));

      final siblings = List<Map<String, dynamic>>.from(data["siblings"] ?? []);
      final home = data["home"] ?? {};
      stepWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey300,
          child: pw.Text(
            "Siblings Section",
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 10));

// Total counts (from home map)
      stepWidgets.add(_buildLabelValueRow("Total Siblings:", home["totalSiblings"], font));
      stepWidgets.add(_buildLabelValueRow("Brothers:", home["brothers"], font));
      stepWidgets.add(_buildLabelValueRow("Sisters:", home["sisters"], font));

      stepWidgets.add(pw.SizedBox(height: 10));

// Each sibling
      for (int i = 0; i < siblings.length; i++) {
        final s = siblings[i];

        stepWidgets.add(
          pw.Text(
            "Sibling ${i + 1}",
            style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        );

        stepWidgets.add(_buildLabelValueRow("Name:", s["name"], font));
        stepWidgets.add(_buildLabelValueRow("Age:", s["age"], font));
        stepWidgets.add(_buildLabelValueRow("Gender:", s["gender"], font));
        stepWidgets.add(_buildLabelValueRow("Education:", s["education"], font));

        stepWidgets.add(_buildLabelValueRow("Physical Problem:", s["physicalProblem"], font));
        stepWidgets.add(_buildLabelValueRow("Emotional Problem:", s["emotionalProblem"], font));

        stepWidgets.add(_buildLabelValueRow("Relationship with Client:", s["relationClient"], font));
        stepWidgets.add(_buildLabelValueRow("Relationship with Siblings:", s["relationSiblings"], font));
        stepWidgets.add(_buildLabelValueRow("Relationship with Step-Siblings:", s["relationStep"], font));

        stepWidgets.add(pw.SizedBox(height: 10));
      }
      stepWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey300,
          child: pw.Text(
            "Home Atmosphere",
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 10));

// Basic fields
      stepWidgets.add(_buildLabelValueRow("Family System:", home["familySystem"], font));
      stepWidgets.add(_buildLabelValueRow("Joint Family Members:", home["jointMembers"], font));
      stepWidgets.add(_buildLabelValueRow("Dependents:", home["dependents"], font));
      stepWidgets.add(_buildLabelValueRow("Extended Relations:", home["extendedRelation"], font));

// Rating type fields (1–5)
      stepWidgets.add(_buildLabelValueRow("Communicative:", home["communicative"], font));
      stepWidgets.add(_buildLabelValueRow("Interactive:", home["interactive"], font));
      stepWidgets.add(_buildLabelValueRow("Rigid:", home["rigid"], font));
      stepWidgets.add(_buildLabelValueRow("Conservative:", home["conservative"], font));
      stepWidgets.add(_buildLabelValueRow("Permissive:", home["permissive"], font));

// Rules
      stepWidgets.add(_buildLabelValueRow("Rules in the Family:", home["rules"], font));

// Psychiatric illness toggle
      stepWidgets.add(_buildLabelValueRow("Psychiatric Illness in Family:", home["psychiatric"], font));

      stepWidgets.add(pw.SizedBox(height: 10));
      final marital = data["marital"] ?? {};
      stepWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey300,
          child: pw.Text(
            "Marital & Family Relations",
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );

      stepWidgets.add(pw.SizedBox(height: 10));

// Parents attitude (checkbox style → show selected only)
      List<String> attitudes = ["adequate", "congenial", "conflicting"];
      List<String> selectedAttitudes = [];

      for (var a in attitudes) {
        if (marital[a] == true) selectedAttitudes.add(a);
      }

      if (selectedAttitudes.isNotEmpty) {
        stepWidgets.add(
          pw.Text(
            "Parents' Attitude: ${selectedAttitudes.join(", ")}",
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        );
      }

// Basic fields
      stepWidgets.add(_buildLabelValueRow("Client's Reaction:", marital["clientReaction"], font));
      stepWidgets.add(_buildLabelValueRow("Salient Happenings:", marital["salient"], font));
      stepWidgets.add(_buildLabelValueRow("Home Environment Cause:", marital["environmentCause"], font));
      stepWidgets.add(_buildLabelValueRow("Client's Opinion About Home Environment:", marital["homeOpinion"], font));
      stepWidgets.add(_buildLabelValueRow("Client's Role in Family:", marital["clientRole"], font));

      stepWidgets.add(_buildLabelValueRow("Home Broken:", marital["homeBroken"], font));
      stepWidgets.add(_buildLabelValueRow("Age at Incident:", marital["ageAtIncident"], font));
      stepWidgets.add(_buildLabelValueRow("Reaction at Incident:", marital["reactionAtIncident"], font));

      stepWidgets.add(_buildLabelValueRow("Living with Father/Mother:", marital["livingWith"], font));
      stepWidgets.add(_buildLabelValueRow("Responsible for Home Breaking:", marital["responsibleForBreak"], font));
      stepWidgets.add(_buildLabelValueRow("Serious Interpersonal Conflict:", marital["interpersonalConflict"], font));

      stepWidgets.add(_buildLabelValueRow("Childhood Family System:", marital["childhoodSystem"], font));
      stepWidgets.add(_buildLabelValueRow("Childhood Place:", marital["childhoodPlace"], font));

      stepWidgets.add(_buildLabelValueRow("Marital Relationship:", marital["marital"], font));

// Conditional fields
      if (marital["marital"] == true) {
        stepWidgets.add(_buildLabelValueRow("Separation Duration:", marital["separation"], font));
        stepWidgets.add(_buildLabelValueRow("Divorce Duration:", marital["divorce"], font));
      }

      stepWidgets.add(_buildLabelValueRow("Cousin Marriage:", marital["cousinMarriage"], font));
      stepWidgets.add(_buildLabelValueRow("Relatives:", marital["relatives"], font));
      stepWidgets.add(_buildLabelValueRow("Number of Children:", marital["children"], font));
      stepWidgets.add(_buildLabelValueRow("Relationship with Children:", marital["relationChildren"], font));
      stepWidgets.add(_buildLabelValueRow("Other Details:", marital["detail"], font));

      stepWidgets.add(pw.SizedBox(height: 10));

      return pw.Column(children: stepWidgets);
    }
    // Add Step Title for Step
    stepWidgets.add(
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(4),
        color: PdfColors.grey300,
        child: pw.Text(
          getStepTitle(stepKey, isUrdu),
          style: pw.TextStyle(
            font: font,
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );

    stepWidgets.add(pw.SizedBox(height: 12)); // Space between title and labels

    // Add label-value rows for each field in the step
    for (final key in orderedKeys) {
      final value = data[key];
      stepWidgets.add(
        _buildLabelValueRow(key, value, font),
      );
    }

    // Return the built widgets for this step
    return pw.Column(children: stepWidgets);
  }

  pw.Widget _buildLabelValueRow(String label, dynamic value, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Label on the left
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
        pw.SizedBox(width: 6), // Space between label and value

        // Value in a box on the right
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
            ),
            child: () {
              if (value == null || value.toString().isEmpty) {
                return pw.Text("N/A", style: pw.TextStyle(font: font, fontSize: 9));
              }

              // ✅ IMPORTANT: Urdu image support
              if (value is pw.MemoryImage) {
                return pw.Image(value);
              }

              // ✅ Normal text
              return pw.Text(
                value.toString(),
                style: pw.TextStyle(font: font, fontSize: 9),
              );
            }(),
          ),
        ),
      ],
    );
  }


  pw.Widget _buildFamilyStep(
      Map<String, dynamic> data,
      pw.Font font,
      bool isUrdu,
      ) {
    return pw.Row(
      children: [
        // Left Column
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _familyMember("Father", data["father"], font, isUrdu),
              _familyMember("Mother", data["mother"], font, isUrdu),
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        // Right Column
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _familyMember("Home", data["home"], font, isUrdu),
              _familyMember("Income", data["income"], font, isUrdu),
            ],
          ),
        ),
      ],
    );
  }
  pw.Widget _familyMember(
      String title,
      dynamic member,
      pw.Font font,
      bool isUrdu,
      ) {
    if (member == null || member is! Map || member.isEmpty) return pw.SizedBox();

    // remove empty + false
    final entries = member.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty && e.value.toString() != "false")
        .toList();

    // ✅ remove duplicates like "Family status" and "familyStatus"
    final seen = <String>{};
    final cleaned = <MapEntry>[];
    for (final e in entries) {
      final k = e.key.toString().trim();
      final normalized = k.replaceAll(" ", "").toLowerCase();
      if (seen.contains(normalized)) continue;
      seen.add(normalized);
      cleaned.add(e);
    }

    pw.Widget valueWidget(dynamic v) {
      if (v == null) return pw.SizedBox();

      // ✅ Urdu image
      if (v is pw.MemoryImage) {
        return pw.Image(v); // no fit needed inside box
      }

      // ✅ List -> join
      if (v is List) {
        final text = v.map((x) => x.toString()).join(", ");
        return pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 9),
          textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        );
      }

      // ✅ normal text
      return pw.Text(
        v.toString(),
        style: pw.TextStyle(font: font, fontSize: 9),
        textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          pw.SizedBox(height: 6),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600)),
            child: pw.Column(
              children: cleaned.map((entry) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: (() {
                          final labelImage = member["__label__${_normalizeKey(entry.key.toString())}"];
                          return pw.Row(
                            children: [

                              pw.Text("${entry.key.toString()} "),

                              pw.SizedBox(width: 4),

                              if (labelImage is pw.MemoryImage)
                                pw.Image(labelImage),

                            ],
                          );
                        })(),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        flex: 5,
                        child: valueWidget(entry.value),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
