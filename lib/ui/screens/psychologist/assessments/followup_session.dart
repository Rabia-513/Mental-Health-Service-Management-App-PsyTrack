import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../data/services/connection_service.dart';
import '../../../../data/services/followup_session_service.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/onesignal_service.dart';
import '../../styles/colors.dart';
import '../../widgets/background_wrapper.dart';

class PrescriptionFollowupScreen extends StatefulWidget {
  const PrescriptionFollowupScreen({super.key});

  @override
  State<PrescriptionFollowupScreen> createState() =>
      _PrescriptionFollowupScreenState();
}

class _PrescriptionFollowupScreenState extends State<PrescriptionFollowupScreen> {
  String connectionId = '';
  String patientUid = '';
  String psychologistUid = '';
  String assessmentId = '';
  String severity = '';
  bool _argsLoaded = false;
  TimeOfDay selectedTime = TimeOfDay.now();
  String patientName = '';
  String patientCode = '';
  String patientAge = '';
  bool isScheduling = false;
  final notesController = TextEditingController();

  String selectedSessionType = "CBT-Cognitive Behavioral Therapy";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  bool reminderEnabled = true;

  final List<String> sessionTypes = [
    "CBT-Cognitive Behavioral Therapy",
    "Supportive Counseling",
    "Follow-up Review",
    "Trauma Focused Session",
  ];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argsLoaded) return;
    _argsLoaded = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    connectionId = (args["connectionId"] ?? "").toString();
    patientUid = (args["patientUid"] ?? "").toString();
    psychologistUid = (args["psychologistUid"] ?? "").toString();
    assessmentId = (args["assessmentId"] ?? "").toString();
    severity = (args["severity"] ?? "").toString();

    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(patientUid)
        .get();

    final data = doc.data() ?? {};

    String ageText = "";
    if (data["dob"] != null && data["dob"] is Timestamp) {
      final dob = (data["dob"] as Timestamp).toDate();
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      ageText = age.toString();
    }

    if (!mounted) return;
    setState(() {
      patientName =
          "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
      patientCode = data["patientCode"] ?? "";
      patientAge = ageText;
    });
  }

  Future<int> getNextSessionNumber() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("prescriptions")
        .where("connectionId", isEqualTo: connectionId)
        .get();

    if (snapshot.docs.isEmpty) return 2; // session 1 = history

    int maxSession = 1;

    for (var doc in snapshot.docs) {
      final num = doc.data()["sessionNumber"] ?? 1;
      if (num > maxSession) maxSession = num;
    }

    return maxSession + 1;
  }
  Future<void> _saveNotes() async {
    if (notesController.text.trim().isEmpty) return;

    final sessionNumber = await getNextSessionNumber();

    await ConnectionService().savePsychologistNote(
      connectionId: connectionId,
      patientUid: patientUid,
      noteText: notesController.text.trim(),
      stage: "post_assessment",

      // ✅ ADD THIS
      sessionNumber: sessionNumber,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notes saved")),
    );
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );


    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }
  Future<void> _scheduleSession() async {
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (reminderEnabled) {
      DateTime reminderTime =
      combinedDateTime.subtract(const Duration(minutes: 5));

      final users = await NotificationService.getAllUsersWithFamily(
        patientUid,
        psychologistUid,
      );

      await OneSignalService.sendScheduledNotification(
        externalIds: users,
        title: "⏰ Follow-up Reminder",
        body: " Session in 5 minutes\n📅 ${selectedDate.day}/${selectedDate.month}\n⏰ ${selectedTime.format(context)}",
        sendAt: reminderTime,
      );
    }
    await FollowupSessionService().createSession(
      connectionId: connectionId,
      patientUid: patientUid,
      psychologistUid: psychologistUid,
      assessmentId: assessmentId,
      sessionType: selectedSessionType,

    followUpDate: combinedDateTime,
      reminderEnabled: reminderEnabled,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session scheduled")),
    );



    setState(() {
      isScheduling = false;
    });


  }

  String get dayName {
    const names = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return names[selectedDate.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F7F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          "Assessment Follow-Up",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: BackgroundWrapper(
        imagePath: "assets/background/icons.png",
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _patientHeader(),
                const SizedBox(height: 16),
                _notesCard(),
                const SizedBox(height: 16),
                _prescriptionCard(),
                const SizedBox(height: 16),
                _followupCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _patientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffDDEAE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff8FB9B4), width: 3),
            ),
            child: const Icon(Icons.person, size: 52, color: Color(0xff8FB9B4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName.isEmpty ? "Patient" : patientName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Age: $patientAge",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Patient ID: $patientCode",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      severity.isEmpty ? "Assessment Completed" : severity,
                      style:  TextStyle(
                        color: AppColors.card(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.assignment_add,
            size: 70,
            color: Color(0xff6D67A9),
          ),
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary, size: 32),
              SizedBox(width: 10),
              Text(
                "Add Notes",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText:
              "Write notes about the patient's condition, symptoms and suggestions...",
              filled: true,
              fillColor: const Color(0xffE8F1EF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 220,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  "Save Notes",
                  style: TextStyle(
                    color: AppColors.card(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Prescriptions",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.createPrescriptionReport,
                    arguments: {
                      "connectionId": connectionId,
                      "patientUid": patientUid,
                      "psychologistUid": psychologistUid,
                      "assessmentId": assessmentId,
                      "patientName": patientName,
                      "patientCode": patientCode,
                      "patientAge": patientAge,
                      "sessionNumber": await getNextSessionNumber(),
                    },
                  );
                },
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffE8F1EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createPrescriptionReport,
                  arguments: {
                    "connectionId": connectionId,
                    "patientUid": patientUid,
                    "psychologistUid": psychologistUid,
                    "assessmentId": assessmentId,
                    "patientName": patientName,
                    "patientCode": patientCode,
                    "patientAge": patientAge,
                  },
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.blue, size: 34),
                  SizedBox(width: 14),
                  Text(
                    "Create Prescription",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _followupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffC8DDDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Follow-Up Session",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffE8F1EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSessionType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary),
                items: sessionTypes
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => selectedSessionType = v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Set Date",
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  "Choose day",
                  style: TextStyle(color: AppColors.primary, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F1EF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_month,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F1EF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Text(
            "Select Time",
            style: TextStyle(color: AppColors.primary, fontSize: 16),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _pickTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xffE8F1EF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTime.format(context),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.access_time, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Send Reminder Notification",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              Switch(
                value: reminderEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  setState(() => reminderEnabled = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child:
            SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton(
                onPressed: isScheduling
                    ? null
                    : () async {
                  setState(() {
                    isScheduling = true;
                  });

                  try {
                    await _scheduleSession();
                  } catch (e) {
                    setState(() {
                      isScheduling = false;
                    });
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isScheduling ? Colors.grey : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: isScheduling
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
                      "Scheduling...",
                      style: TextStyle(
                        color: AppColors.card(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "Schedule Session",
                  style: TextStyle(
                    color: AppColors.card(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),          ),
        ],
      ),
    );
  }
}