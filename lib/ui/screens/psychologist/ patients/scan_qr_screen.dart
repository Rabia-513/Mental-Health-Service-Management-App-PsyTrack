import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../styles/colors.dart';

class ScanPatientQrScreen extends StatefulWidget {
  const ScanPatientQrScreen({super.key});

  @override
  State<ScanPatientQrScreen> createState() => _ScanPatientQrScreenState();
}

class _ScanPatientQrScreenState extends State<ScanPatientQrScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        isScanned = true;
        Navigator.pop(context, code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text(context),
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        title:  Text(
          "Scan Patient QR",
          style: TextStyle(color: AppColors.card(context)),
        ),
        iconTheme: IconThemeData(color: AppColors.card(context)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.card(context), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              "Place the QR code inside the box",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.card(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}