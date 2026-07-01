import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../../../../data/services/connection_service.dart';
import '../../../../view_model/history_viewmodel.dart';
import '../../../../app/routes.dart';
import '../../styles/colors.dart';
import 'history_report_widget.dart';

class HistoryPdfView extends StatefulWidget {
  const HistoryPdfView({super.key});

  @override
  State<HistoryPdfView> createState() => _HistoryPdfViewState();
}

class _HistoryPdfViewState extends State<HistoryPdfView> {
  late String patientUid;
  late String psychologistUid;
  late String historyId;
  late String connectionId;

  final GlobalKey _repaintKey = GlobalKey();

  File? pdfFile;
  bool loading = true;
  bool _started = false;
  bool submittingHistory = false;
  @override

  Future<void> _generateRealPdf() async {
    try {
      final vm = context.read<HistoryViewModel>();

      debugPrint("➡️ Loading full history for historyId = $historyId");
      await vm.loadFullHistory();

      debugPrint("➡️ allStepsData keys = ${vm.allStepsData.keys.toList()}");
      final isUrdu = Directionality.of(context) == TextDirection.rtl;
      vm.setLanguage(isUrdu); // ✅ FIX HERE

      final pdfBytes = await vm.generatePdfOnly(
        patientUid: patientUid,
        psychologistUid: psychologistUid,

        language: vm.selectedLanguage,
      );

      debugPrint("✅ PDF bytes generated: ${pdfBytes.lengthInBytes}");

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/history_preview.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      debugPrint("✅ PDF written at: ${file.path}");
      debugPrint("✅ File exists: ${await file.exists()}");
      debugPrint("✅ File size: ${await file.length()}");

      if (!mounted) return;

      setState(() {
        pdfFile = file;
        loading = false;
      });
    } catch (e, st) {
      debugPrint("❌ REAL PDF ERROR: $e");
      debugPrint("$st");

      if (!mounted) return;
      setState(() => loading = false);
    }
  }
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    patientUid = args["patientUid"];
    psychologistUid = args["psychologistUid"];
    historyId = args["historyId"];
    connectionId = args["connectionId"];

    final vm = context.read<HistoryViewModel>();
    vm.setHistoryId(historyId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _generateRealPdf();
    });
  }
  Future<ui.Image> _cropImage(
      ui.Image image,
      int top,
      int height,
      ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint();

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, top.toDouble(),
          image.width.toDouble(), height.toDouble()),
      Rect.fromLTWH(0, 0,
          image.width.toDouble(), height.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
        image.width, height);
  }
  Future<void> _completeHistory() async {
    if (pdfFile == null || submittingHistory) return;

    setState(() {
      submittingHistory = true;
    });

    try {
      final vm = context.read<HistoryViewModel>();
      final bytes = await pdfFile!.readAsBytes();

      final pdfUrl = await vm.uploadPdfAndComplete(
        pdfBytes: bytes,
        patientUid: patientUid,
        psychologistUid: psychologistUid,
      );

      await ConnectionService().markHistorySubmitted(
        connectionId: connectionId,
        historyId: historyId,
        historyPdfUrl: pdfUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("History submitted successfully")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.patientDashboard,
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit history: $e")),
      );

      setState(() {
        submittingHistory = false;
      });
    }
  }  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card(context),
        title: const Text("History Report"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (pdfFile == null)
          ? const Center(child: Text("PDF generation failed"))
          : Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: pdfFile!.path,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                debugPrint("✅ PDF rendered. Total pages: $pages");
              },
              onError: (error) {
                debugPrint("❌ PDFView onError: $error");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("PDF error: $error")),
                  );
                }
              },
              onPageError: (page, error) {
                debugPrint("❌ PDF page error. Page: $page Error: $error");
              },
            ),
          ),          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  submittingHistory ? Colors.grey : AppColors.primary,
                ),
                onPressed: submittingHistory ? null : _completeHistory,
                child: submittingHistory
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.card(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Submitting...",
                      style: TextStyle(color: AppColors.card(context)),
                    ),
                  ],
                )
                    : Text(
                  "Submit History",
                  style: TextStyle(color: AppColors.card(context)),
                ),
              ),
            ),
          ),
        ],
      ),);
  }
}