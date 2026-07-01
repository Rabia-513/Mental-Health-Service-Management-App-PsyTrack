import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/painting.dart' as painting;

class PrescriptionReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔥 Detect Urdu
  bool isUrdu(String text) {
    final urduRegex = RegExp(r'[\u0600-\u06FF]');
    return urduRegex.hasMatch(text);
  }

  // 🔥 Convert text → image
  Future<Uint8List> textToImage(String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final textPainter = painting.TextPainter(
      text: painting.TextSpan(
        text: text,
        style: const painting.TextStyle(
          fontSize: 18,
          color: ui.Color(0xFF000000),
        ),
      ),
      textDirection: painting.TextDirection.rtl,
    );

    textPainter.layout(maxWidth: 500);
    textPainter.paint(canvas, const ui.Offset(0, 0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      textPainter.width.toInt(),
      textPainter.height.toInt(),
    );

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Map<String, String>> createAndSavePrescriptionReport({
    required String connectionId,
    required String patientUid,
    required String psychologistUid,
    required String assessmentId,
    required String patientName,
    required String patientCode,
    required String patientAge,
    required String notes,
    required String notesUrdu,
    required List<Map<String, String>> medications,
    required String instructions,
    required String duration,
    required bool medicationReminder,
    required List<String> lifestyleRecommendations,
    required List<String> suggestions,
    required double sessionImprovement,
    int? sessionNumber,
  }) async {

    final pdfBytes = await _generatePdf(
      patientName: patientName,
      patientCode: patientCode,
      patientAge: patientAge,
      notes: notes,
      notesUrdu: notesUrdu,
      medications: medications,
      instructions: instructions,
      duration: duration,
      medicationReminder: medicationReminder,
      lifestyleRecommendations: lifestyleRecommendations,
      suggestions: suggestions,
    );

    final path =
        "$psychologistUid/$patientUid/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf";

    await _supabase.storage.from("prescription-reports").uploadBinary(
      path,
      pdfBytes,
      fileOptions: const FileOptions(
        contentType: "application/pdf",
        upsert: true,
      ),
    );

    final pdfUrl =
    _supabase.storage.from("prescription-reports").getPublicUrl(path);

    final prescriptionDoc = await _firestore.collection("prescriptions").add({
      "connectionId": connectionId,
      "patientUid": patientUid,
      "psychologistUid": psychologistUid,
      "assessmentId": assessmentId,
      "patientName": patientName,
      "patientCode": patientCode,
      "patientAge": patientAge,
      "medications": medications,
      "instructions": instructions,
      "duration": duration,
      "notes": notes,
      "notesUrdu": notesUrdu,
      "lifestyleRecommendations": lifestyleRecommendations,
      "suggestions": suggestions,
      "sessionImprovement": sessionImprovement,
      "medicationReminder": medicationReminder,
      "pdfUrl": pdfUrl,
      "createdAt": FieldValue.serverTimestamp(),
      if (sessionNumber != null) "sessionNumber": sessionNumber,
    });

    return {
      "prescriptionId": prescriptionDoc.id,
      "pdfUrl": pdfUrl,
    };
  }

  Future<Uint8List> _generatePdf({
    required String patientName,
    required String patientCode,
    required String patientAge,
    required String notes,
    required String notesUrdu,
    required List<Map<String, String>> medications,
    required String instructions,
    required String duration,
    required bool medicationReminder,
    required List<String> lifestyleRecommendations,
    required List<String> suggestions,
  }) async {

    // 🔥 Convert Urdu fields to images
    Uint8List? notesUrduImage;
    Uint8List? instructionsImage;

    if (notesUrdu.isNotEmpty) {
      notesUrduImage = await textToImage(notesUrdu);
    }

    if (isUrdu(instructions)) {
      instructionsImage = await textToImage(instructions);
    }

    final lifestyleImages = <Uint8List>[];
    for (var item in lifestyleRecommendations) {
      if (isUrdu(item)) {
        lifestyleImages.add(await textToImage(item));
      }
    }

    final suggestionImages = <Uint8List>[];
    for (var item in suggestions) {
      if (isUrdu(item)) {
        suggestionImages.add(await textToImage(item));
      }
    }

    final pdf = pw.Document();
    Uint8List? notesImage;

    if (isUrdu(notes)) {
      notesImage = await textToImage(notes);
    }
    Uint8List clinicalHeadingImg =
    await textToImage("Clinical Notes / ڈاکٹر کی ہدایات");

    Uint8List medicationHeadingImg =
    await textToImage("Medication Details / ادویات");

    Uint8List instructionHeadingImg =
    await textToImage("Instructions / ہدایات");

    Uint8List lifestyleHeadingImg =
    await textToImage("Lifestyle Recommendations / طرز زندگی");

    Uint8List suggestionHeadingImg =
    await textToImage("Suggestions / تجاویز");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Text(
            "Psychologist Advice / Prescription",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 16),

          pw.Text("Patient Name: $patientName"),
          pw.Text("Patient Age: $patientAge"),
          pw.Text("Patient ID: $patientCode"),

          pw.SizedBox(height: 18),

        pw.Image(pw.MemoryImage(clinicalHeadingImg)),

          /// ENGLISH NOTES
          if (!isUrdu(notes))
            pw.Text(notes.isEmpty ? "-" : notes),

          /// URDU NOTES → IMAGE
          if (isUrdu(notes) && notesImage != null) ...[
            pw.SizedBox(height: 6),
            pw.Image(pw.MemoryImage(notesImage)),
          ],

    /// 🔥 EXTRA URDU FIELD (already exists)

// Urdu → ALWAYS IMAGE
          if (notesUrdu.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Image(pw.MemoryImage(notesUrduImage!)),
          ],

          pw.SizedBox(height: 16),

          pw.Image(pw.MemoryImage(medicationHeadingImg)),
          if (medications.isEmpty)
            pw.Text("-")
          else
            ...medications.map(
                  (m) => pw.Text(
                "${m["name"] ?? ""} | Dosage: ${m["dosage"] ?? ""} | Frequency: ${m["frequency"] ?? ""}",
              ),
            ),

          pw.SizedBox(height: 16),

          pw.Image(pw.MemoryImage(instructionHeadingImg)),
          if (isUrdu(instructions))
            pw.Image(pw.MemoryImage(instructionsImage!))
          else
            pw.Text(instructions.isEmpty ? "-" : instructions),

          pw.SizedBox(height: 12),

          pw.Text("Duration: $duration"),
          pw.Text("Medication Reminder: ${medicationReminder ? "Enabled" : "Disabled"}"),

          pw.SizedBox(height: 16),

          pw.Image(pw.MemoryImage(lifestyleHeadingImg)),
          if (lifestyleRecommendations.isEmpty)
            pw.Text("-")
          else
            ...lifestyleRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;

              if (isUrdu(text)) {
                return pw.Image(pw.MemoryImage(lifestyleImages[index]));
              } else {
                return pw.Bullet(text: text);
              }
            }),

          pw.SizedBox(height: 16),

          pw.Image(pw.MemoryImage(suggestionHeadingImg)),
          if (suggestions.isEmpty)
            pw.Text("-")
          else
            ...suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;

              if (isUrdu(text)) {
                return pw.Image(pw.MemoryImage(suggestionImages[index]));
              } else {
                return pw.Bullet(text: text);
              }
            }),
        ],
      ),
    );

    return pdf.save();
  }
}