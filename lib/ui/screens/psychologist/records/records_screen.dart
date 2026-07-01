import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/psychologist_main_screen.dart';
import '../../../common/view_pdf_screen.dart';

class RecordsScreen extends StatefulWidget {
  final String connectionId;
  final String patientUid;
  final String patientName;
  final String patientCode;

  const RecordsScreen({
    super.key,
    required this.connectionId,
    required this.patientUid,
    required this.patientName,
    required this.patientCode,
  });

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {

  final Color mainColor = const Color(0xff4E7D7A);

  String selectedTab = "Reports";

  final tabs = [
    "Assessments",
    "Prescriptions",
    "Session Notes",
    "Reports"
  ];

  @override
  Widget build(BuildContext context) {
    return PsychologistMainScreen(
        selectedIndex: 3, // schedule related

        child: Scaffold(
      backgroundColor: const Color(0xffF4F7F6),

      appBar: AppBar(
        title: Text(widget.patientName),
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
      ),

      body: Column(
        children: [

          _header(),

          /// 🔘 TABS
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: tabs.map((tab) {

                final selected = tab == selectedTab;

                return GestureDetector(
                  onTap: () => setState(() => selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? mainColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mainColor),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: selected ? Colors.white : mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(child: _buildContent()),
        ],
      )
    ));
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xffE6F2F1),
            child: Icon(Icons.person, color: Colors.teal, size: 28),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Patient ID: ${widget.patientCode}"),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Records",
                style: TextStyle(color: Colors.teal)),
          )
        ],
      ),
    );
  }

  /// 🔥 MAIN SWITCH
  Widget _buildContent() {

    if (selectedTab == "Reports") return _reports();
    if (selectedTab == "Prescriptions") return _prescriptions();
    if (selectedTab == "Session Notes") return _notes();
    if (selectedTab == "Assessments") return _assessments();

    return const SizedBox();
  }

  /// 📄 REPORTS
  Widget _reports() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reports")
          .where("patientUid", isEqualTo: widget.patientUid)
          .snapshots(),
      builder: (context, snap) {

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No reports uploaded"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final data = docs[index].data() as Map<String, dynamic>;

            final fileUrl = data["fileUrl"];
            final reportName = data["reportName"] ?? "Report";
            final type = data["reportType"] ?? "Report";
            final uploadedBy = data["uploadedBy"] ?? "";

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffE6F2F1),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(reportName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(type,
                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Uploaded by: $uploadedBy",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  /// 🔘 ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      /// VIEW IN APP
                      _actionBtn(Icons.visibility, "View", () {

                        /// 🧠 HISTORY → OPEN IN APP
                        if (type == "History" || type == "Psychological Report") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(url: fileUrl),
                            ),
                          );
                          return;
                        }

                        /// 🧪 LAB → OPEN URL
                        if (type == "Lab Report") {
                          launchUrl(Uri.parse(fileUrl));
                          return;
                        }

                        /// 📄 PDF → OPEN IN APP
                        if (fileUrl.toString().endsWith(".pdf")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(url: fileUrl),
                            ),
                          );
                        }

                        /// 🖼 IMAGE → SHOW IN APP
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(title: Text(reportName)),
                                body: Center(
                                  child: Image.network(fileUrl),
                                ),
                              ),
                            ),
                          );
                        }

                      }),
                      /// DOWNLOAD
                      _actionBtn(Icons.download, "Download", () async {
                        await launchUrl(Uri.parse(fileUrl));
                      }),

                      /// SHARE
                      _actionBtn(Icons.share, "Share", () async {
                        final dir = await getTemporaryDirectory();
                        final path =
                            "${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf";

                        await Dio().download(fileUrl, path);

                        await Share.shareXFiles([XFile(path)]);
                      }),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }  Widget _prescriptionCard(List meds, String? url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffE6F2F1),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🧾 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Prescription",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Prescription",
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// 💊 MEDICINES LIST
          ...meds.map<Widget>((m) {

            final name = m["name"] ?? "";
            final dosage = m["dosage"] ?? "";
            final freq = m["frequency"] ?? "";

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffDCEEEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),

              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medication, color: Colors.red),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text("$dosage – $freq",
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  )
                ],
              ),
            );          }).toList(),

          const SizedBox(height: 10),

          /// 🔘 BUTTONS
          if (url != null && url != "")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                _actionBtn(Icons.visibility, "View", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(url: url),
                    ),
                  );
                }),                _actionBtn(Icons.download, "Download", () async {
                  try {
                    final dir = await getExternalStorageDirectory(); // ✅ visible
                    final path =
                        "${dir!.path}/Download_${DateTime.now().millisecondsSinceEpoch}.pdf";

                    await Dio().download(url, path);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Saved to Downloads folder")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Download failed")),
                    );
                  }
                }),
                _actionBtn(Icons.share, "Share", () {
                  Share.share(url);
                }),
              ],
            )
        ],
      ),
    );
  }
  /// 💊 PRESCRIPTIONS
  Widget _prescriptions() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("prescriptions")
          .where("patientUid", isEqualTo: widget.patientUid)
          .snapshots(),
      builder: (context, snap) {

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No prescriptions"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final data = docs[index].data() as Map<String, dynamic>;
            final meds = data["medications"] ?? [];
            final url = data["pdfUrl"];

            return _prescriptionCard(meds, url);
          },
        );      },
    );
  }
  /// 🧠 NOTES
  Widget _notes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("psychologist_notes")
          .where("connectionId", isEqualTo: widget.connectionId)
          .snapshots(),
      builder: (context, snap) {

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No notes available"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final note = docs[index]["noteText"];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffE6F2F1),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Session ${index + 1} Notes",
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 6),

                  Text(note),
                ],
              ),
            );
          },
        );
      },
    );
  }  /// 📊 ASSESSMENTS
  Widget _assessments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("patient_assessments")
          .where("patientUid", isEqualTo: widget.patientUid)
          .where("connectionId", isEqualTo: widget.connectionId)
          .snapshots(),
      builder: (context, snap) {

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No assessments found"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final data = docs[index].data() as Map<String, dynamic>;

            final name = data["assessmentName"] ?? "";
            final score = data["score"] ?? 0;
            final severity = data["severity"] ?? "";

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.teal),
                title: Text(name),
                subtitle: Text("Score: $score\nResult: $severity"),
              ),
            );
          },
        );
      },
    );
  }
  /// 🔘 FILE CARD
  Widget _fileCard(String url, String type, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffE6F2F1),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🧾 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(type,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// 📄 SUBTEXT
          Text(
            subtitle ?? "Tap below to view or manage document",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 12),

          /// 🔘 BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              _actionBtn(Icons.visibility, "View", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(url: url),
                  ),
                );
              }),

              _actionBtn(Icons.download, "Download", () async {
                await launchUrl(Uri.parse(url!)); // ✅ opens in Chrome
              }),
              _actionBtn(Icons.share, "Share", () async {
                final dir = await getTemporaryDirectory();
                final path = "${dir.path}/prescription.pdf";

                await Dio().download(url!, path);

                await Share.shareXFiles([XFile(path)]);
              }),
            ],
          ),
        ],
      ),
    );
  }
  Widget _actionBtn(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
  Widget _miniBtn(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.teal),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  /// 🔘 BUTTON
}