import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/ui/screens/styles/colors.dart';

import '../../../../data/services/notification_service.dart';
import '../../../../data/services/onesignal_service.dart';
import '../../../common/psychologist_main_screen.dart';
import '../../../common/view_pdf_screen.dart' show PdfViewerScreen;

class PatientDetailManageScreen extends StatefulWidget {
  const PatientDetailManageScreen({super.key});

  @override
  State<PatientDetailManageScreen> createState() =>
      _PatientDetailManageScreenState();
}

class _PatientDetailManageScreenState extends State<PatientDetailManageScreen> {

  final Color mainColor = const Color(0xff4E7D7A);
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {

    final connectionId =
    ModalRoute.of(context)!.settings.arguments as String;

    return PsychologistMainScreen(
        selectedIndex: 3,

        child: Scaffold(

      backgroundColor: Theme.of(context).cardColor,

      appBar: AppBar(
        elevation: 0,
        title: const Text("Manage Patient"),
        foregroundColor: Theme.of(context).cardColor,
        backgroundColor: AppColors.primary
      ),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance
            .collection("patient_psychologist_connections")
            .doc(connectionId)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final connectionData =
          snapshot.data!.data() as Map<String, dynamic>;

          final patientUid = connectionData["patientUid"];

          return FutureBuilder<DocumentSnapshot>(

            future: FirebaseFirestore.instance
                .collection("patients")
                .doc(patientUid)
                .get(),

            builder: (context, patientSnapshot) {

              if (!patientSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final patient =
              patientSnapshot.data!.data() as Map<String, dynamic>;

              final patientName =
                  "${patient["firstName"] ?? ""} ${patient["lastName"] ?? ""}";
              int age = 0;

              if (patient["dob"] != null) {
                final dob = (patient["dob"] as Timestamp).toDate();
                final today = DateTime.now();

                age = today.year - dob.year;

                if (today.month < dob.month ||
                    (today.month == dob.month && today.day < dob.day)) {
                  age--;
                }
              }

              return SingleChildScrollView(

                padding: const EdgeInsets.all(16),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    /// HEADER CARD
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color(0xffE6F1F0),
                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Row(
                        children: [

                           CircleAvatar(
                            radius: 34,
                            backgroundColor: Theme.of(context).cardColor,
                            child: Icon(Icons.person,
                                size:30,
                                color:Color(0xff4E7D7A)),
                          ),

                          const SizedBox(width:12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  patientName,
                                  style: const TextStyle(
                                      fontSize:18,
                                      fontWeight:FontWeight.bold),
                                ),

                                const SizedBox(height:4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      "Patient ID: ${connectionData["patientCode"]}",
                                      style: const TextStyle(fontSize:13),
                                    ),

                                    const SizedBox(height:4),


                                    Text(
                                      "Age: $age",
                                      style: const TextStyle(fontSize:13),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          /// ASSESSMENT SCORE
                          StreamBuilder<QuerySnapshot>(

                            stream: FirebaseFirestore.instance
                                .collection("patient_assessments")
                                .where("connectionId",
                                isEqualTo: connectionId)
                                .orderBy("createdAt",
                                descending: true)
                                .limit(1)
                                .snapshots(),

                            builder: (context, assessSnapshot) {

                              if (!assessSnapshot.hasData ||
                                  assessSnapshot.data!.docs.isEmpty) {
                                return const Text("No Score");
                              }

                              final assess =
                              assessSnapshot.data!.docs.first.data()
                              as Map<String,dynamic>;

                              return Column(
                                children: [

                                  const Text(
                                    "Total Score",
                                    style: TextStyle(fontSize:12),
                                  ),

                                  Text(
                                    "${assess["score"] ?? 0}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:16),
                                  ),


                                ],
                              );
                            },
                          ),


                          const SizedBox(height: 6),


                        ],
                      ),
                    ),

                    const SizedBox(height:16),

                    /// DIAGNOSIS BADGE
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("patient_assessments")
                          .where("connectionId", isEqualTo: connectionId)
                          .orderBy("createdAt", descending: true)
                          .limit(1)
                          .snapshots(),

                      builder: (context, snapshot) {

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }

                        final data =
                        snapshot.data!.docs.first.data() as Map<String, dynamic>;

                        final severity = data["severity"] ?? "No Result";

                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: getSeverityColor(severity),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              severity,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height:20),

                    /// TABS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Row(
                        children: [

                          tab("Overview",0),
                          tab("Assessments",1),
                          tab("Prescriptions",2),
                          tab("Follow-up",3),

                        ],
                      ),
                    ),

                    const SizedBox(height:20),

                    /// TAB CONTENT
                    if(selectedTab==0) overview(connectionId),
                    if(selectedTab==1) assessments(connectionId),
                    if(selectedTab==2) prescriptions(connectionId),
                    if(selectedTab==3) followUp(connectionId),

                    const SizedBox(height:80),

                  ],
                ),
              );
            },
          );
        },
      ),
        ));
  }

  /// TAB BUTTON
  Widget tab(String label,int index){

    bool active = selectedTab==index;

    return GestureDetector(

      onTap: (){
        setState(() {
          selectedTab=index;
        });
      },

      child: Container(

        margin: const EdgeInsets.only(right:10),

        padding: const EdgeInsets.symmetric(
            horizontal:14,
            vertical:8),

        decoration: BoxDecoration(
          color: active
              ? mainColor
              : const Color(0xffE6F1F0),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : AppColors.text(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// OVERVIEW TAB
  Widget overview(String connectionId){

    return Column(
      children: [

        latestPrescription(connectionId),

        const SizedBox(height:16),

        psychologistNotes(connectionId),   // ✅ NEW

        const SizedBox(height:16),

        followUp(connectionId)

      ],
    );  }

  /// PRESCRIPTION CARD
  Widget latestPrescription(String connectionId){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("prescriptions")
          .where("connectionId",
          isEqualTo: connectionId)
          .orderBy("createdAt",
          descending: true)
          .limit(1)
          .snapshots(),

      builder:(context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return const Text("No prescriptions yet");
        }
        if(snapshot.data == null || snapshot.data!.docs.isEmpty){
          return const SizedBox();
        }
        final pres =
        snapshot.data!.docs.first.data()
        as Map<String,dynamic>;
        final meds = pres["medications"] ?? [];
        final lifestyle = pres["lifestyleRecommendations"] ?? [];
        final suggestions = pres["suggestions"] ?? [];



        return Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xffF2F6F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.teal.shade100),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children:[

              const Text(
                "Latest Prescription",
                style: TextStyle(
                    fontSize:18,
                    fontWeight:FontWeight.bold),
              ),

              const SizedBox(height:10),

              if(meds.isNotEmpty)
                Column(
                  children: [

                    if (meds.isNotEmpty)
                      Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [

                          /// HEADER
                          TableRow(
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.1),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text("Medicine", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text("Dose", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text("Freq", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text("Days", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),

                          /// DATA ROWS
                          ...meds.map<TableRow>((med) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(med["name"] ?? ""),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(med["dosage"] ?? ""),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(med["frequency"] ?? ""),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(pres["duration"] ?? ""),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),                    const SizedBox(height:10),

                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        _medBox(meds[0]["dosage"] ?? ""),
                        _medBox(meds[0]["frequency"] ?? ""),
                        _medBox(pres["duration"] ?? ""),
                        _medBox("Morning"),

                      ],
                    ),

                  ],
                ),
              const SizedBox(height:10),

              Center(
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(url: pres["pdfUrl"])
                    ),
                  );},

                  child: Text("See latest Prescription",style: TextStyle(color:Colors.white),),
                ),
              ),


            ],

          ),
        );
      },
    );
  }

  /// FOLLOW UP
  Widget followUp(String connectionId){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("sessions")
          .where("connectionId",
          isEqualTo: connectionId)
          .where("status",
          isEqualTo: "scheduled")
          .limit(1)
          .snapshots(),

      builder:(context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const SizedBox();
        }

        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return const Text("No follow-up scheduled");
        }

        final session = snapshot.data!.docs.first;

        final data =
        session.data() as Map<String,dynamic>;

        final Timestamp? time = data["followUpDate"];
        DateTime? followDate =
        time!=null ? time.toDate():null;

        return Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xffF2F6F5),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children:[

              Row(
                children: const [

                  Icon(Icons.calendar_month,
                      color: Colors.red),

                  SizedBox(width:8),

                  Text(
                    "Next Follow-Up",
                    style: TextStyle(
                      color:AppColors.primary,
                        fontSize:18,
                        fontWeight:FontWeight.bold),
                  ),

                ],
              ),
              const SizedBox(height:6),

              Text(
                data["therapy"] ?? "",
                style: const TextStyle(
                    fontSize:16,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height:6),

              Text(
                followDate != null
                    ? "${followDate.day}/${followDate.month}/${followDate.year} - ${TimeOfDay.fromDateTime(followDate).format(context)}"
                    : "Date not scheduled",
              ),
              const SizedBox(height:12),

              Center(
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  ),

        onPressed: () async {

        DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        );

        if (pickedDate == null) return;

        TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        );

        if (pickedTime == null) return;

        // ✅ Combine date + time
        final combinedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        );

        // ✅ Save correctly
        await FirebaseFirestore.instance
            .collection("sessions")
            .doc(session.id)
            .update({
        "followUpDate": Timestamp.fromDate(combinedDateTime),
        });
        DateTime reminderTime =
        combinedDateTime.subtract(const Duration(minutes: 5));

        final users = await NotificationService.getAllUsersWithFamily(
          data["patientUid"],
          data["psychologistUid"],
        );

        await OneSignalService.sendScheduledNotification(
          externalIds: users,
          title: "⏰ Session Reminder",
          body: " Your rescheduled session is in 5 minutes",
          sendAt: reminderTime,
        );

        // ✅ SEND NOTIFICATION (IMPORTANT)
        await OneSignalService.sendNotification(
        externalId: data["patientUid"],
        title: "Session Rescheduled",
        body: "Your session is now on ${pickedDate.day}/${pickedDate.month} at ${pickedTime.format(context)}",
        );

        await OneSignalService.sendNotification(
        externalId: data["psychologistUid"],
        title: "Session Rescheduled",
        body: "Session rescheduled successfully",
        );

        },
                  child:  Text("Reschedule",style: TextStyle(color: Theme.of(context).cardColor)),
                ),
              )

            ],
          ),
        );
      },
    );
  }
  void editNote(BuildContext context, String docId, String oldText) async {

    TextEditingController controller =
    TextEditingController(text: oldText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Note"),
          content: TextField(
            controller: controller,
            maxLines: 4,
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                await FirebaseFirestore.instance
                    .collection("psychologist_notes")
                    .doc(docId)
                    .update({
                  "noteText": controller.text,
                  "createdAt": Timestamp.now(),
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            )

          ],
        );
      },
    );
  }
  Widget psychologistNotes(String connectionId){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("psychologist_notes")
          .where("connectionId", isEqualTo: connectionId)
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder:(context, snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const SizedBox();
        }

        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return const Text("No notes yet");
        }

        final notes = snapshot.data!.docs;
        return Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xffF2F6F5),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            children: notes.map((doc) {
              final note = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffF2F6F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(note["noteText"] ?? ""),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        /// EDIT
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            editNote(context, doc.id, note["noteText"]);
                          },
                        ),

                        /// DELETE
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("psychologist_notes")
                                .doc(doc.id)
                                .delete();
                          },
                        ),

                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  /// ASSESSMENTS TAB
  Widget assessments(String connectionId){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("patient_assessments")
          .where("connectionId", isEqualTo: connectionId)
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder:(context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
            width: double.infinity,
            child: Column(
          children: [

            /// 🔹 HISTORY PDF
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("patient_psychologist_connections")
                  .doc(connectionId)
                  .snapshots(),

              builder:(context, connSnap){

                if(!connSnap.hasData) return const SizedBox();

                final connData = connSnap.data!.data() as Map<String,dynamic>;

                if(connData["historyPdfUrl"] == null){
                  return const SizedBox();
                }

                return SizedBox(
                    height: 110, // 👈 THIS FIXES HEIGHT
                    width: double.infinity,
                    child: Container(
                    margin: const EdgeInsets.only(bottom:12),
                padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: const Color(0xffE6F1F0),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: [

                      const Icon(Icons.picture_as_pdf,color: Colors.red),

                      const SizedBox(width:8),

                      const Expanded(
                        child: Text("View Patient History Report"),
                      ),

                      TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                url: connData["historyPdfUrl"],
                              ),
                            ),
                          );
                        },
                        child: const Text("Open"),
                      )

                    ],
                  ),
                ));
              },
            ),

            /// 🔹 ASSESSMENT LIST
            if(!snapshot.hasData || snapshot.data!.docs.isEmpty)
              const Text("No assessments yet")
            else
              ...snapshot.data!.docs.map((doc){

                final data = doc.data() as Map<String,dynamic>;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom:12),
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text(context).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0,4),
                      )
                    ],
                    border: Border.all(color: const Color(0xffE6F1F0)),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // ✅ FIX

                    children: [

                      /// ICON
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: mainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.psychology, color: Color(0xff4E7D7A)),
                      ),

                      const SizedBox(width:10),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            /// NAME (NO OVERFLOW NOW)
                            Text(
                              data["assessmentName"] ?? "Assessment",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:15,
                              ),
                            ),

                            const SizedBox(height:4),

                            Text(
                              "Score: ${data["score"] ?? 0}",
                                style: TextStyle(color: AppColors.primary)                            ),

                            const SizedBox(height:6),

                            /// SEVERITY BADGE (WRAPS PROPERLY)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal:10, vertical:5),
                              decoration: BoxDecoration(
                                color: getSeverityColor(data["severity"] ?? "").withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data["severity"] ?? "",
                                style: TextStyle(
                                  color: getSeverityColor(data["severity"] ?? ""),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(width:6),


                    ],
                  ),
                );              }).toList()

          ],
        ));
      },
    );
  }

  /// PRESCRIPTION HISTORY TAB
  Widget prescriptions(String connectionId){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("prescriptions")
          .where("connectionId", isEqualTo: connectionId)
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder:(context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          return const Text("No prescriptions");
        }


        return Column(
          children: snapshot.data!.docs.map((doc){

            final data = doc.data() as Map<String,dynamic>;
            final meds = data["medications"] ?? [];
            final firstMed = meds.isNotEmpty ? meds[0] : null;
            final lifestyle = data["lifestyleRecommendations"] ?? [];
            final suggestions = data["suggestions"] ?? [];

            return SizedBox(
                width: double.infinity,
                child:  Container(

              margin: const EdgeInsets.only(bottom:14),
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xffF2F6F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.shade100),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// MEDICATION

              if (firstMed != null) ...[
                Text(
                firstMed["name"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height:6),

                Text("Dosage: ${firstMed["dosage"] ?? ""}"),
                Text("Frequency: ${firstMed["frequency"] ?? ""}"),
                ],
                  const SizedBox(height:8),

                  /// NOTES
                  Text("Advice: ${data["notes"] ?? ""}"),

                  const SizedBox(height:6),

                  /// RECOMMENDATION


            if (lifestyle.isNotEmpty)
            Text("Recommendation: ${lifestyle[0]}"),

            if (suggestions.isNotEmpty)
            Text("Suggestion: ${suggestions[0]}"),

                  const SizedBox(height:10),

                  /// PDF
                  TextButton.icon(
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
                    icon: const Icon(Icons.picture_as_pdf,color: Colors.red),
                    label: const Text("View Full Report"),
                  )

                ],
              ),
            ));

          }).toList(),
        );
      },
    );
  }}


Widget _medBox(String text){

  return Container(

    padding: const EdgeInsets.symmetric(
        horizontal:10,
        vertical:6),

    decoration: BoxDecoration(
      color: const Color(0xffE6F1F0),
      borderRadius: BorderRadius.circular(10),
    ),

    child: Text(
      text,
      style: const TextStyle(fontSize:12),
    ),
  );

}

Color getSeverityColor(String severity){
  final s = severity.toLowerCase();

  if(s.contains("minimal") || s.contains("normal")){
    return Colors.green;
  } else if(s.contains("mild")){
    return Colors.orange;
  } else if(s.contains("moderate")){
    return Colors.deepOrange;
  } else if(s.contains("severe")){
    return Colors.red;
  }

  return Colors.grey;
}