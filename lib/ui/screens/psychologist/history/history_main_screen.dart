import 'package:flutter/material.dart';
import '../../../../app/routes.dart';

class HistoryMainScreen extends StatefulWidget {
  const HistoryMainScreen({super.key});

  @override
  State<HistoryMainScreen> createState() => _HistoryMainScreenState();
}

class _HistoryMainScreenState extends State<HistoryMainScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final connectionId = (args["connectionId"] ?? "").toString();
    final patientUid = (args["patientUid"] ?? "").toString();
    final psychologistUid = (args["psychologistUid"] ?? "").toString();
    final historyId = (args["historyId"] ?? "").toString();
    final patientCode = (args["patientCode"] ?? "").toString();

    debugPrint("HistoryMainScreen connectionId = $connectionId");
    debugPrint("HistoryMainScreen patientUid = $patientUid");
    debugPrint("HistoryMainScreen psychologistUid = $psychologistUid");
    debugPrint("HistoryMainScreen historyId = $historyId");
    debugPrint("HistoryMainScreen patientCode = $patientCode");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (connectionId.isEmpty || patientUid.isEmpty || psychologistUid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Missing data in HistoryMainScreen")),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.historyStep1,
        arguments: {
          "connectionId": connectionId,
          "patientUid": patientUid,
          "psychologistUid": psychologistUid,
          "historyId": historyId,
          "patientCode": patientCode,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}