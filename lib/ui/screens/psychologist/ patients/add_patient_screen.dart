import 'package:flutter/material.dart';
import 'package:fyp/ui/screens/psychologist/%20patients/patient_detail_screen.dart';
import 'package:fyp/ui/screens/psychologist/%20patients/scan_qr_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../data/services/connection_service.dart';
import '../../styles/colors.dart';


class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> connectPatient() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter patient code")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ConnectionService().connectPatientByCode(code);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient connected successfully")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(
            connectionId: result['connectionId'],
            patientUid: result['patientUid'],
            patientName: result['patientName'],
            patientCode: result['patientCode'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  void openScanner() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanPatientQrScreen()),
    );

    if (scannedCode != null && scannedCode is String) {
      codeController.text = scannedCode;
      connectPatient();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF4F7F6),
        iconTheme: const IconThemeData(color: Color(0xff3E6F6C)),
        title: const Text(
          "Add Patient",
          style: TextStyle(
            color: Color(0xff3E6F6C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Top Illustration Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xffE3ECEA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: Color(0xff4E7D7A),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Connect a Patient",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3E6F6C),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Enter patient code or scan QR to connect",
                    style: TextStyle(
                      color: Color(0xff5F7E7B),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// Input Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text(context).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Patient Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3E6F6C),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      hintText: "Enter code (example: CPQWQTY2)",
                      filled: true,
                      fillColor: const Color(0xffF6F9F8),
                      prefixIcon: const Icon(
                        Icons.qr_code_rounded,
                        color: Color(0xff4E7D7A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Connect Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : connectPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4E7D7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: AppColors.card(context))
                          : Text(
                        "Connect Patient",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.card(context),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// QR Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: openScanner,
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xff4E7D7A),
                      ),
                      label: const Text(
                        "Scan QR Code",
                        style: TextStyle(
                          color: Color(0xff4E7D7A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xff4E7D7A),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
    );
  }}