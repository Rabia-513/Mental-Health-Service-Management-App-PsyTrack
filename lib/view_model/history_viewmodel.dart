import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/services/history_service.dart';
import '../data/services/pdf_service.dart';
import '../data/services/supabase_service.dart';
import 'dart:typed_data';


class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel();
  final _service = HistoryService();
  String selectedLanguage = "english"; // default
  Map<String, dynamic> allStepsData = {};
  void setLanguage(bool isUrdu) {
    selectedLanguage = isUrdu ? "urdu" : "english";
  }

  String? historyId;
  bool isLoading = false;
  final Map<int, Map<String, dynamic>> _drafts = {};

  Map<String, dynamic>? getStepData(int step) {
    return _drafts[step];
  }

  Future<void> startHistory({
    required String patientUid,
    required String psychologistUid,
  }) async {
    isLoading = true;
    notifyListeners();

    historyId = await _service.createHistory(
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      language: selectedLanguage, // ✅ ADD THIS
    );

    isLoading = false;
    notifyListeners();
  }

  void setHistoryId(String id) {
    historyId = id;
  }

  Future<void> saveStep({
    required int step,
    required Map<String, dynamic> data,
    bool moveNext = false,
  }) async {
    if (historyId == null) return;

    // keep local draft (for resume)
    _drafts[step] = data;

    await _service.saveStep(
      historyId: historyId!,
      step: step,
      data: data,
      moveNext: moveNext,
    );
  }
  Future<void> markHistoryCompleted() async {
    if (historyId == null) return;
    await _service.completeHistory(historyId!);
  }


  Future<bool> saveStep1({
    required Map<String, dynamic> data,
    bool moveNext = false,
  }) async {
    if (historyId == null) return false;

    await _service.saveStep(
      historyId: historyId!,
      step: 1,
      data: data,
      moveNext: moveNext,
    );

    return true;

  }


  final _pdfService = PdfService();
  final _supabaseService = SupabaseService();
  final _historyService = HistoryService();

  Future<void> loadFullHistory() async {
    if (historyId == null) return;

    allStepsData = await _historyService.getFullHistory(historyId!);
    notifyListeners();
  }
  Future<String> generateAndUploadPdf({
    required String patientUid,
    required String psychologistUid,
  }) async {
    if (historyId == null) throw Exception("No historyId");

    // 1️⃣ Get full history data
    allStepsData =
    await _historyService.getFullHistory(historyId!);

    notifyListeners();

    // 2️⃣ Generate PDF
    final pdfBytes = await _pdfService.generateHistoryPdf(
      allStepsData: allStepsData,
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      language: selectedLanguage,    );

    // 3️⃣ Upload to Supabase
    final pdfUrl = await _supabaseService.uploadHistoryPdf(
      pdfBytes: pdfBytes,
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      historyId: historyId!,
    );

    await _historyService.savePdfUrl(
        historyId: historyId!, pdfUrl: pdfUrl);

// 🔥 ADD THIS BLOCK (MOST IMPORTANT FIX)
    await FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc("$psychologistUid\_$patientUid") // ⚠️ your connectionId format
        .update({
      "historyPdfUrl": pdfUrl,
      "latestHistoryId": historyId,
      "historySubmitted": true,
    });

    return pdfUrl;
  }


  Future<Uint8List> generatePdfOnly({
    required String patientUid,
    required String psychologistUid,
    required String language,
  }) async {
    if (historyId == null) throw Exception("No historyId");

    allStepsData = await _historyService.getFullHistory(historyId!);
    notifyListeners();

    return await _pdfService.generateHistoryPdf(
      allStepsData: allStepsData,
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      language: language,    );
  }

  Future<String> uploadPdfAndComplete({
    required Uint8List pdfBytes,
    required String patientUid,
    required String psychologistUid,
  }) async {
    if (historyId == null) {
      throw Exception("No historyId");
    }

    final pdfUrl = await _supabaseService.uploadHistoryPdf(
      pdfBytes: pdfBytes,
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      historyId: historyId!,
    );

    await _historyService.savePdfUrl(
      historyId: historyId!,
      pdfUrl: pdfUrl,
    );

    await _historyService.completeHistory(historyId!);

    await FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc("$psychologistUid\_$patientUid")
        .update({
      "historyPdfUrl": pdfUrl,
      "latestHistoryId": historyId,
      "historySubmitted": true,
    });

    return pdfUrl;
  }



}
