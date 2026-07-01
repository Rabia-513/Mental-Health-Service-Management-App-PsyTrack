import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';
import '../../../common/view_pdf_screen.dart';


class FamilyPrescriptionsScreen extends StatelessWidget {
  const FamilyPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final isUrdu = Translations.isUrdu;
    final String patientUid = args["patientUid"];
    final String patientName = args["patientName"];
    final String profileImage = args["profileImage"];

    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      backgroundColor: const Color(0xffEAF6F6),

      appBar: AppBar(
         title: Text(Translations.t("Prescription")),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff4E7D7A),
      ),

      body: Column(
        children: [

          /// 🔹 PATIENT INFO (TOP)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("patients")
                .doc(patientUid)
                .snapshots(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final name = data["firstName"] != null
                  ? "${data["firstName"]} ${data["lastName"]}"
                  : data["fullName"] ?? "";

              final image = data["profileImageUrl"] ?? "";

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: image.isNotEmpty
                          ? NetworkImage(image)
                          : const AssetImage("assets/images/profile.png")
                      as ImageProvider,
                    ),
                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),

                        const SizedBox(height: 4),

                        Text(
                          "${isUrdu ? "مریض آئی ڈی" : "Patient ID"}: ${data["patientCode"] ?? ""}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          /// 🔥 PRESCRIPTIONS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("prescriptions")
                  .where("patientUid", isEqualTo: patientUid)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(child: Text(isUrdu ? "کوئی نسخہ موجود نہیں" : "No prescriptions found",));
                }

                /// 🔥 SORT BY DATE
                docs.sort((a, b) {
                  final aTime = a["createdAt"] as Timestamp;
                  final bTime = b["createdAt"] as Timestamp;
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    final meds = data["medications"] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// 🔹 SESSION TITLE
                          Text(
                            "${isUrdu ? "سیشن" : "Session"} ${data["sessionNumber"] ?? index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff4E7D7A),
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// 🔥 MEDICATION TABLE
                          Table(
                            border: TableBorder.all(
                                color: Colors.grey.shade300),
                            children: [

                              /// HEADER
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xffEAF6F6),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(isUrdu ? "دوا" : "Medicine",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                 Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text( isUrdu ? "خوراک" : "Dosage",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                               Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(        isUrdu ? "تعدد" : "Frequency",

                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),

                              /// DATA ROWS
                              ...meds.map<TableRow>((m) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(m["name"] ?? ""),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text("${m["dosage"]} mg"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text("${m["frequency"]}x"),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// 🔹 INSTRUCTIONS
                          Text(
                            isUrdu ? "ہدایات:" : "Instructions:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                          Text(data["instructions"] ?? ""),

                          const SizedBox(height: 6),

                          Text("${isUrdu ? "مدت" : "Duration"}: ${data["duration"] ?? ""}"),
                          const SizedBox(height: 12),

                          /// 🔹 BUTTONS
                          Row(
                            children: [

                              /// VIEW BUTTON (EXPANDED)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(
                                          url: data["pdfUrl"],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4E7D7A),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:  Text(isUrdu ? "دیکھیں" : "View",style: TextStyle(color: Colors.white),),
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// SHARE BUTTON (EXPANDED)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Share.share(data["pdfUrl"]);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(isUrdu ? "شیئر" : "Share",style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          )                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      /// 🔻 YOUR CUSTOM NAV
    bottomNavigationBar: FamilyBottomNav(
    selectedIndex: 2,
// ✅ PASS HERE
    ),  ));}
}