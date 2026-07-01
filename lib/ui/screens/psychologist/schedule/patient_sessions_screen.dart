import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../common/view_pdf_screen.dart';
import '../../styles/colors.dart';

//create new session

class PatientSessionsScreen extends StatelessWidget {
  const PatientSessionsScreen({super.key});

  int _calculateAge(Timestamp? dobTs) {
    if (dobTs == null) return 0;
    final dob = dobTs.toDate();
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _buildPatientName(Map<String, dynamic> patientData, String fallback) {
    final firstName = (patientData["firstName"] ?? "").toString().trim();
    final lastName = (patientData["lastName"] ?? "").toString().trim();
    final fullName = "$firstName $lastName".trim();

    if (fullName.isNotEmpty) return fullName;
    if ((patientData["name"] ?? "").toString().trim().isNotEmpty) {
      return patientData["name"].toString().trim();
    }
    if ((patientData["fullName"] ?? "").toString().trim().isNotEmpty) {
      return patientData["fullName"].toString().trim();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};

    final String patientId = (args["patientId"] ?? "").toString();
    final String patientNameArg = (args["patientName"] ?? "Patient").toString();
    final String connectionId = (args["connectionId"] ?? "").toString();

    const Color mainColor = Color(0xff4E7D7A);
    final bgColor = AppColors.background(context);

    if (connectionId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Connection ID missing"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData( color: AppColors.text(context)),
        title: Text(
          patientNameArg,
          style: const TextStyle(
            color: mainColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection("patient_psychologist_connections")
              .doc(connectionId)
              .get(),
          builder: (context, connectionSnapshot) {
            if (connectionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!connectionSnapshot.hasData || !connectionSnapshot.data!.exists) {
              return const Center(child: Text("Connection record not found"));
            }

            final connectionData = connectionSnapshot.data!.data() ?? {};

            final String historyPdfUrl =
            (connectionData["historyPdfUrl"] ?? "").toString();
            final String currentStage =
            (connectionData["currentStage"] ?? "").toString();
            final String latestAssessmentId =
            (connectionData["latestAssessmentId"] ?? "").toString();
            final String patientUid =
            (connectionData["patientUid"] ?? patientId).toString();

            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection("patients")
                  .where("firebaseUid", isEqualTo: patientUid)
                  .limit(1)
                  .get(),
              builder: (context, patientSnapshot) {
                Map<String, dynamic> patientData = {};
                if (patientSnapshot.hasData &&
                    patientSnapshot.data != null &&
                    patientSnapshot.data!.docs.isNotEmpty) {
                  patientData = patientSnapshot.data!.docs.first.data();
                }

                final String patientName =
                _buildPatientName(patientData, patientNameArg);
                final String gender =
                (patientData["gender"] ?? "--").toString();
                final int age = _calculateAge(
                  patientData["dob"] is Timestamp ? patientData["dob"] as Timestamp : null,
                );

                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection("patient_assessments")
                      .where("connectionId", isEqualTo: connectionId)
                      .orderBy("createdAt", descending: true)
                      .limit(1)
                      .get(),
                  builder: (context, assessmentSnapshot) {
                    Map<String, dynamic> assessmentData = {};
                    if (assessmentSnapshot.hasData &&
                        assessmentSnapshot.data != null &&
                        assessmentSnapshot.data!.docs.isNotEmpty) {
                      assessmentData = assessmentSnapshot.data!.docs.first.data();
                    }

                    final String assessmentName =
                    (assessmentData["assessmentName"] ?? "").toString();
                    final String assessmentSeverity =
                    (assessmentData["severity"] ?? "").toString();
                    final String assessmentScore =
                    (assessmentData["score"] ?? "").toString();

                    String assessmentResultText = "Assessment result not available";
                    if (assessmentSeverity.isNotEmpty && assessmentScore.isNotEmpty) {
                      assessmentResultText =
                      "$assessmentSeverity  •  Score: $assessmentScore";
                    } else if (assessmentSeverity.isNotEmpty) {
                      assessmentResultText = assessmentSeverity;
                    } else if (assessmentName.isNotEmpty) {
                      assessmentResultText = assessmentName;
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card(context),                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: mainColor.withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: mainColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patientName,
                                        style: const TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${age > 0 ? age : "--"} | $gender",
                                        style: TextStyle(
                                          color: mainColor.withOpacity(0.75),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Previous Sessions",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection("psychologist_notes")
                                .where("connectionId", isEqualTo: connectionId)
                                .orderBy("createdAt", descending: true)

                                .snapshots(),

                            builder: (context, notesSnapshot) {
                              if (notesSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final notesDocsRaw = notesSnapshot.data?.docs ?? [];

                              final notesDocs = [...notesDocsRaw]
                                ..sort((a, b) => (a["createdAt"] as Timestamp)
                                    .compareTo(b["createdAt"] as Timestamp));


                              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection("prescriptions")
                                    .where("connectionId", isEqualTo: connectionId)
                                    .orderBy("createdAt", descending: true)                                    .snapshots(),
                                builder: (context, prescriptionSnapshot) {
                                  if (prescriptionSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final prescriptionDocsRaw = prescriptionSnapshot.data?.docs ?? [];

                                  final prescriptionDocs = [...prescriptionDocsRaw]
                                    ..sort((a, b) => (a["createdAt"] as Timestamp)
                                        .compareTo(b["createdAt"] as Timestamp));
                                  final int followUpCount = math.min(
                                    math.max(notesDocs.length - 1, 0),
                                    math.max(prescriptionDocs.length - 1, 0),
                                  );

                                  return ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    children: [
                                      _SessionCard(
                                        sessionTitle: "Session 1",

                                        mainColor: mainColor,
                                        initiallyExpanded: true,
                                        children: [
                                          if (historyPdfUrl.isNotEmpty)

                                            _SessionItemTile(
                                              icon: Icons.history_edu_outlined,
                                              title: "Patient History",
                                              subtitle: "Open submitted history PDF",
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PdfViewerScreen(url: historyPdfUrl),
                                                  ),
                                                );
                                              },
                                            ),

                                          _buildAssessmentBox(assessmentData),
// ✅ FIRST SESSION NOTES
                                          // ✅ SESSION 1 NOTES
                                          if (notesDocs.isNotEmpty)
                                            _SessionItemTile(
                                              icon: Icons.note_alt_outlined,
                                              title: "Session Notes",
                                              subtitle: (notesDocs[0].data()["noteText"] ?? "No notes").toString(),
                                            ),

// ✅ SESSION 1 PRESCRIPTION
                                          if (prescriptionDocs.isNotEmpty)
                                            _SessionItemTile(
                                              icon: Icons.picture_as_pdf_outlined,
                                              title: "Prescription",
                                              subtitle: "Open prescription PDF",
                                              onTap: () {
                                                final url =
                                                (prescriptionDocs[0].data()["pdfUrl"] ??
                                                    prescriptionDocs[0].data()["reportUrl"] ??
                                                    "").toString();

                                                if (url.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => PdfViewerScreen(url: url),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          _SessionItemTile(
                                            icon: Icons.category_outlined,
                                            title: "Patient Category / Stage",
                                            subtitle: assessmentData["assessmentName"] ?? "Not available",
                                          ),
                                          if (latestAssessmentId.isNotEmpty)
                                            _SessionItemTile(
                                              icon: Icons.badge_outlined,
                                              title: "Assessment ID",
                                              subtitle: latestAssessmentId,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      ...List.generate(followUpCount, (index) {
                                        final noteData =
                                        (index + 1) < notesDocs.length
                                            ? notesDocs[index + 1].data()
                                            : null;

                                        final prescriptionData =
                                        (index + 1) < prescriptionDocs.length
                                            ? prescriptionDocs[index + 1].data()
                                            : null;
                                        final int sessionNum = index + 2;

                                        final String noteText =
                                        (noteData?["noteText"] ?? "").toString();

                                        final String stage =
                                        (noteData?["stage"] ?? "").toString();

                                        final String prescriptionPdfUrl =
                                        (prescriptionData?["pdfUrl"] ??
                                            prescriptionData?["prescriptionPdfUrl"] ??
                                            prescriptionData?["reportUrl"] ??
                                            "")
                                            .toString();

                                        final String prescriptionNote =
                                        (prescriptionData?["notes"] ?? "").toString();

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: _SessionCard(
                                            sessionTitle: "Session $sessionNum",
                                            mainColor: mainColor,
                                            initiallyExpanded: false,
                                            children: [
                                              _SessionItemTile(
                                                icon: Icons.note_alt_outlined,
                                                title: "Session Notes",
                                                subtitle: noteText.isEmpty
                                                    ? "No notes available"
                                                    : noteText,
                                              ),
                                              if (stage.isNotEmpty)
                                                _SessionItemTile(
                                                  icon: Icons.local_offer_outlined,
                                                  title: "Stage",
                                                  subtitle: stage,
                                                ),
                                              if (prescriptionNote.isNotEmpty)
                                                _SessionItemTile(
                                                  icon: Icons.medication_outlined,
                                                  title: "Prescription Advice",
                                                  subtitle: prescriptionNote,
                                                ),
                                              if (prescriptionPdfUrl.isNotEmpty)
                                                _SessionItemTile(
                                                  icon: Icons.picture_as_pdf_outlined,
                                                  title: "Prescription",
                                                  subtitle: "Open prescription PDF",
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => PdfViewerScreen(url: prescriptionPdfUrl),
                                                      ),
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        );
                                      }),

                                      if (followUpCount == 0)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.card(context),                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: mainColor.withOpacity(0.10),
                                            ),
                                          ),
                                          child: Text(
                                            "No follow-up sessions available yet.",
                                            style: TextStyle(
                                              color: mainColor.withOpacity(0.85),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 18),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.createSession,
                                  arguments: {
                                    "patientId": patientUid,
                                    "patientName": patientName,
                                    "connectionId": connectionId,
                                  },
                                );
                              },
                              child: const Text(
                                "Create New Session",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String sessionTitle;
  final Color mainColor;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _SessionCard({
    required this.sessionTitle,
    required this.mainColor,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mainColor.withOpacity(0.10)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          iconColor: mainColor,
          collapsedIconColor: mainColor,
          title: Text(
            sessionTitle,
            style: const TextStyle(
              color: Color(0xff264B49),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.folder_open_outlined,
              color: mainColor,
              size: 18,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _SessionItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SessionItemTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xff4E7D7A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffF7FAF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: mainColor.withOpacity(0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(icon, color: mainColor, size: 20),




            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: mainColor.withOpacity(0.78),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new_rounded,
                color: mainColor.withOpacity(0.75),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
Widget _buildAssessmentBox(Map<String, dynamic> data) {
  final String name = data["assessmentName"] ?? "Assessment";
  final int score = data["score"] ?? 0;
  final String severity = data["severity"] ?? "";

  Color color;

  if (severity.toLowerCase().contains("minimal") ||
      severity.toLowerCase().contains("normal")) {
    color = Colors.green;
  } else if (severity.toLowerCase().contains("mild")) {
    color = Colors.orange;
  } else if (severity.toLowerCase().contains("moderate")) {
    color = Colors.deepOrange;
  } else if (severity.toLowerCase().contains("severe") ||
      severity.toLowerCase().contains("extreme")) {
    color = Colors.red;
  } else {
    color = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Score: $score"),
        const SizedBox(height: 4),
        Text(
          severity,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}