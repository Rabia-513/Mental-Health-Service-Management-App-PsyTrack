import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes.dart';
import '../../../../data/services/connection_service.dart';
import '../../../common/view_pdf_screen.dart';
import '../../styles/colors.dart';

class PatientDetailScreen extends StatefulWidget {
  final String connectionId;
  final String patientUid;
  final String patientName;
  final String patientCode;

  const PatientDetailScreen({
    super.key,
    required this.connectionId,
    required this.patientUid,
    required this.patientName,
    required this.patientCode,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final TextEditingController notesController = TextEditingController();

  bool loadingAllow = false;
  bool savingNote = false;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> allowForms() async {
    setState(() => loadingAllow = true);

    try {
      await ConnectionService().allowHistoryAndConsent(widget.connectionId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("History and consent allowed")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => loadingAllow = false);
      }
    }
  }

  Future<void> saveNote() async {
    if (notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Write note first")),
      );
      return;
    }

    setState(() => savingNote = true);

    try {
      await ConnectionService().savePsychologistNote(
        connectionId: widget.connectionId,
        patientUid: widget.patientUid,
        noteText: notesController.text.trim(),
      );

      notesController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note saved")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save note: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => savingNote = false);
      }
    }
  }

  Future<void> openPdf(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open PDF")),
      );
    }
  }

  void goToAssessment() {
    Navigator.pushNamed(
      context,
      AppRoutes.startAssessment,
      arguments: {
        "connectionId": widget.connectionId,
        "patientUid": widget.patientUid,
        "psychologistUid": "",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionRef = FirebaseFirestore.instance
        .collection('patient_psychologist_connections')
        .doc(widget.connectionId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xffF4F6F5),
          iconTheme: const IconThemeData(color: Color(0xff3E6F6C)),
          title: const Text(
            "Patient Assessment",
            style: TextStyle(
              color: Color(0xff3E6F6C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: connectionRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.data!.exists) {
              return const Center(child: Text("Connection not found"));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final String latestHistoryId = data['latestHistoryId'] ?? '';
            final String psychologistUid = data['psychologistUid'] ?? '';
            final bool historyAllowed = data['historyAllowed'] ?? false;
            final bool consentAllowed = data['consentAllowed'] ?? false;
            final bool historySubmitted = data['historySubmitted'] ?? false;
            final bool consentSubmitted = data['consentSubmitted'] ?? false;
            final String historyPdfUrl = data['historyPdfUrl'] ?? '';
            final String currentStage = data['currentStage'] ?? 'connected';
            final bool assessmentCompleted = data['assessmentCompleted'] ?? false;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _patientHeaderCard(
                          name: widget.patientName,
                          code: widget.patientCode,
                          stage: currentStage,
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          "Assessment Setup",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3E6F6C),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _actionCard(
                          historyAllowed: historyAllowed,
                          consentAllowed: consentAllowed,
                          historySubmitted: historySubmitted,
                          consentSubmitted: consentSubmitted,
                          onStartAssessment: historySubmitted && latestHistoryId.isNotEmpty
                              ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.historyStep2,
                              arguments: {
                                "connectionId": widget.connectionId,
                                "patientUid": widget.patientUid,
                                "psychologistUid": psychologistUid,
                                "historyId": latestHistoryId,
                              },
                            );
                          }
                              : null,
                        ),

                        const SizedBox(height: 18),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffDDE7E4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color:  Color(0xff4E7D7A),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            labelColor: Theme.of(context).cardColor,
                            unselectedLabelColor: const Color(0xff4E7D7A),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: const [
                              Tab(text: "History"),
                              Tab(text: "Reports"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 460,
                          child: TabBarView(
                            children: [
                              _historyTab(
                                historyAllowed: historyAllowed,
                                consentAllowed: consentAllowed,
                                historySubmitted: historySubmitted,
                                consentSubmitted: consentSubmitted,
                                historyPdfUrl: historyPdfUrl,
                                latestHistoryId: latestHistoryId,        // ✅ ADD
                                psychologistUid: psychologistUid,        // ✅ ADD
                              ),
                              _reportsTab(
                                historySubmitted: historySubmitted,
                                historyPdfUrl: historyPdfUrl,
                                assessmentCompleted: assessmentCompleted,
                                latestHistoryId: latestHistoryId,        // ✅ ADD
                                psychologistUid: psychologistUid,
                              ),
                            ],
                          ),
                        ),

                        if (historySubmitted) ...[
                          const SizedBox(height: 18),
                          _notesSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _patientHeaderCard({
    required String name,
    required String code,
    required String stage,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffE7EFEC),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffD3E2DF),
            ),
            child: const Icon(
              Icons.person,
              size: 38,
              color: Color(0xff4E7D7A),
            ),
          ),

          const SizedBox(width: 16),

          /// Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2F5E5B),
                  ),
                ),

                const SizedBox(height: 6),

                /// Patient ID
                Text(
                  "Patient ID: $code",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5C7E7B),
                  ),
                ),

                const SizedBox(height: 10),

                /// Stage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff4E7D7A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stage.replaceAll("_", " "),
                    style:  TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Right icon
               Icon(
            Icons.health_and_safety,
            color: Color(0xff4E7D7A),
            size: 34,
          )
        ],
      ),
    );
  }

  Widget _actionCard({
    required bool historyAllowed,
    required bool consentAllowed,
    required bool historySubmitted,
    required bool consentSubmitted,
    required VoidCallback? onStartAssessment,
  }) {
    final allAllowed = historyAllowed && consentAllowed;

    return Container(
      width: double.infinity,
      padding:      EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.04),
            blurRadius: 10,
            offset:      Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            allAllowed
                ? "Patient can now submit History and Consent"
                : "Allow patient to submit History & Consent",
            textAlign: TextAlign.center,
            style:      TextStyle(
              fontSize: 15,
              color: Color(0xff3E6F6C),
              fontWeight: FontWeight.w600,
            ),
          ),
               SizedBox(height: 22),
          SizedBox(
            width: 250,
            height: 54,
            child: ElevatedButton(
              onPressed: allAllowed || loadingAllow ? null : allowForms,
              style: ElevatedButton.styleFrom(
                backgroundColor:      Color(0xff4E7D7A),
                disabledBackgroundColor:      Color(0xff8DAAA8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: loadingAllow
                  ?      CircularProgressIndicator(color: Theme.of(context).cardColor)
                  : Text(
                allAllowed ? "History Shared" : "Show History",
                style:      TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
               SizedBox(height: 14),
          SizedBox(
            width: 260,
            height: 54,
            child: ElevatedButton(
              onPressed: onStartAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor:      Color(0xff4E7D7A),
                disabledBackgroundColor:      Color(0xffB7C4C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child:      Text(
                "Start Assessment",
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
               SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _miniStatusChip(
                label: "Consent",
                done: consentSubmitted,
                waiting: consentAllowed && !consentSubmitted,
              ),
              _miniStatusChip(
                label: "History",
                done: historySubmitted,
                waiting: historyAllowed && !historySubmitted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyTab({
    required bool historyAllowed,
    required bool consentAllowed,
    required bool historySubmitted,
    required bool consentSubmitted,
    required String historyPdfUrl,
    required String latestHistoryId,   // ✅ ADD THIS
    required String psychologistUid,   // ✅ ADD THIS
  }){
    if (!historyAllowed && !consentAllowed) {
      return _emptyBox("History not allowed yet");
    }

    if (!historySubmitted) {
      return Container(
        width: double.infinity,
        padding:      EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color:      Color(0xff4E7D7A), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                 Text(
              "Waiting for patient submission",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff3E6F6C),
              ),
            ),
                 SizedBox(height: 14),
            _rowStatus("Consent Form", consentSubmitted),
                 SizedBox(height: 10),
            _rowStatus("History Form", historySubmitted),
                 SizedBox(height: 18),
                 Text(
              "Patient will complete the forms from their dashboard. Once submitted, the history report will appear here.",
              style: TextStyle(
                color: Color(0xff587A77),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:      EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color:      Color(0xff4E7D7A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
               Text(
            "History submitted successfully",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff3E6F6C),
            ),
          ),
               SizedBox(height: 14),
          _rowStatus("Consent Form", consentSubmitted),
               SizedBox(height: 10),
          _rowStatus("History Form", historySubmitted),
               SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
                onPressed: latestHistoryId.isEmpty
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(url: historyPdfUrl),
                    ),
                  );
                },

              style: ElevatedButton.styleFrom(
                backgroundColor:      Color(0xff4E7D7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon:      Icon(Icons.picture_as_pdf, color: Theme.of(context).cardColor),
              label:      Text(
                "View History PDF",
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (historyPdfUrl.isNotEmpty) ...[
                 SizedBox(height: 12),
            SelectableText(
              historyPdfUrl,
              style:      TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reportsTab({
    required bool historySubmitted,
    required String historyPdfUrl,
    required bool assessmentCompleted,
    required String latestHistoryId,   // ✅ ADD THIS
    required String psychologistUid,
  }) {
    if (!historySubmitted) {
      return _emptyBox("History report not found");
    }

    return Container(
      width: double.infinity,
      padding:      EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color:      Color(0xff4E7D7A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
               Text(
            "Reports",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff3E6F6C),
            ),
          ),
               SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:      Icon(Icons.description_outlined,
                color: Color(0xff4E7D7A)),
            title:      Text("History Report"),
            subtitle: Text(
              historyPdfUrl.isEmpty ? "No file link found" : "Tap button below to open",
            ),
          ),
               SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: historyPdfUrl.isNotEmpty
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(url: historyPdfUrl),
                  ),
                );
              }
                  : null,
              style: OutlinedButton.styleFrom(
                side:      BorderSide(color: Color(0xff4E7D7A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:      Text(
                "Open Report",
                style: TextStyle(color: Color(0xff4E7D7A)),
              ),
            ),
          ),
               SizedBox(height: 18),
          Container(
            padding:      EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:      Color(0xffEEF4F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  assessmentCompleted
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: assessmentCompleted ? Colors.green : Colors.orange,
                ),
                     SizedBox(width: 10),
                Text(
                  assessmentCompleted
                      ? "Assessment completed"
                      : "Assessment pending",
                  style:      TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3E6F6C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesSection() {
    return Container(
      width: double.infinity,
      padding:      EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.04),
            blurRadius: 10,
            offset:      Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
               Text(
            "Psychologist Notes",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xff3E6F6C),
            ),
          ),
               SizedBox(height: 14),
          TextField(
            controller: notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Write your observations and notes here...",
              filled: true,
              fillColor:      Color(0xffF7FAF9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:      BorderSide(color: Color(0xffC8D7D4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:      BorderSide(color: Color(0xffC8D7D4)),
              ),
            ),
          ),
               SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: savingNote ? null : saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor:      Color(0xff4E7D7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: savingNote
                  ?      CircularProgressIndicator(color: Theme.of(context).cardColor)
                  :      Text(
                "Save Note",
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assessmentButton(bool assessmentCompleted) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: assessmentCompleted ? null : goToAssessment,
        style: ElevatedButton.styleFrom(
          backgroundColor: assessmentCompleted
              ? Colors.grey
              :      Color(0xff5D4FC6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          assessmentCompleted ? "Assessment Completed" : "Start Assessment",
          style:      TextStyle(
            color: Theme.of(context).cardColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _miniStatusChip({
    required String label,
    required bool done,
    required bool waiting,
  }) {
    Color bg;
    Color fg;
    String text;

    if (done) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      text = "$label Done";
    } else if (waiting) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
      text = "$label Pending";
    } else {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade700;
      text = "$label Locked";
    }

    return Container(
      padding:      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _rowStatus(String title, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.schedule,
          color: completed ? Colors.green : Colors.orange,
        ),
             SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style:      TextStyle(
              fontSize: 15,
              color: Color(0xff3E6F6C),
            ),
          ),
        ),
        Text(
          completed ? "Completed" : "Pending",
          style: TextStyle(
            color: completed ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding:      EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color:      Color(0xff4E7D7A), width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style:      TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff3E6F6C),
          ),
        ),
      ),
    );
  }
}