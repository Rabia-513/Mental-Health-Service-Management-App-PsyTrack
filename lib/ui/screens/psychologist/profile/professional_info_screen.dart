import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/routes.dart';
import '../../../common/psychologist_bottom_nav.dart';

import '../../../../data/services/psychologist_service.dart';
import '../../styles/colors.dart';

class ProfessionalInfoScreen extends StatefulWidget {
  const ProfessionalInfoScreen({super.key});

  @override
  State<ProfessionalInfoScreen> createState() =>
      _ProfessionalInfoScreenState();
}

class _ProfessionalInfoScreenState extends State<ProfessionalInfoScreen> {

  final uid = FirebaseAuth.instance.currentUser!.uid;

  // ================= BASIC =================
  String professionalTitle = "Clinical Psychologist";
  final licenseController = TextEditingController();
  final authorityController = TextEditingController();
  DateTime? expiryDate;

  // ================= SPECIALIZATION =================
  final specializationController = TextEditingController();
  List<String> specializations = [];

  // ================= EDUCATION =================
  final degreeController = TextEditingController();
  final instituteController = TextEditingController();
  final yearController = TextEditingController();
  List<Map<String, String>> education = [];

  // ================= EXPERIENCE =================
  String totalYears = "1 Year";
  final orgController = TextEditingController();
  final roleController = TextEditingController();
  final durationController = TextEditingController();
  List<Map<String, String>> experienceList = [];
  List<Map<String, String>> experience = [];

  bool isLoading = true;
  bool isSaving = false;
  int selectedIndex = 4;
  bool showBasic = true;
  bool showSpec = false;
  bool showEdu = false;
  bool showExp = false;
  final licenseExpiryController = TextEditingController();


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await PsychologistService.fetchProfessionalInfo(uid);

    if (data == null) {
      setState(() => isLoading = false);
      return;
    }

    professionalTitle =
        data['professionalTitle'] ?? professionalTitle;

    licenseController.text =
        data['licenseNumber'] ?? "";

    authorityController.text =
        data['licenseAuthority'] ?? "";

    if (data['licenseExpiry'] is Timestamp) {
      expiryDate = (data['licenseExpiry'] as Timestamp).toDate();
    }

    // ✅ SAFE LIST CAST
    if (data['specializations'] is List) {
      specializations = List<String>.from(data['specializations']);
    }

    // ✅ SAFE EDUCATION
    if (data['education'] is List) {
      education = List<Map<String, String>>.from(
        (data['education'] as List)
            .map((e) => Map<String, String>.from(e)),
      );
    }

    // ✅ SAFE EXPERIENCE
    if (data['experienceDetails'] is Map &&
        data['experienceDetails']['workHistory'] is List) {
      experienceList = List<Map<String, String>>.from(
        (data['experienceDetails']['workHistory'] as List)
            .map((e) => Map<String, String>.from(e)),
      );

    }

    setState(() => isLoading = false);
  }



  Future<void> saveData() async {
    await PsychologistService.updateProfessionalInfo(uid, {
      "professionalTitle": professionalTitle,
      "licenseNumber": licenseController.text,
      "licenseAuthority": authorityController.text,
      "licenseExpiry": expiryDate,
      "specializations": specializations,
      "education": education,
      "experience": {
        "totalYears": totalYears,
        "workHistory": experienceList
      }
    });

    Future<void> saveData() async {
      setState(() => isSaving = true);

      try {
        await PsychologistService.updateProfessionalInfo(uid, {
          "professionalTitle": professionalTitle,
          "licenseNumber": licenseController.text,
          "licenseAuthority": authorityController.text,
          "licenseExpiry": expiryDate,
          "specializations": specializations,
          "education": education,
          "experience": {
            "totalYears": totalYears,
            "workHistory": experienceList,
          },
        });

        // ✅ Optional success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved successfully")),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: $e")),
        );
      }

      setState(() => isSaving = false);
    }

  }

  InputDecoration field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.text(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
        const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget section(String title, bool open, VoidCallback onTap, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            trailing: Icon(
                open ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text("Professional Information"),
        foregroundColor: AppColors.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // BASIC
            section(
              "Basic Credentials",
              showBasic,
                  () => setState(() => showBasic = !showBasic),
              Column(
                children: [
                  DropdownButtonFormField(
                    value: professionalTitle,
                    decoration: field("Professional Title"),
                    items: const [
                      DropdownMenuItem(
                          value: "Clinical Psychologist",
                          child: Text("Clinical Psychologist")),
                      DropdownMenuItem(
                          value: "Counseling Psychologist",
                          child: Text("Counseling Psychologist")),
                    ],
                    onChanged: (v) =>
                        setState(() => professionalTitle = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: licenseController,
                      decoration: field("PMDC / License Number")),
                  const SizedBox(height: 10),
                  TextField(
                      controller: authorityController,
                      decoration:
                      field("License Issuing Authority")),
                  const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expiryDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "License Expiry Date: "
                        "${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              TextField(
                controller: licenseExpiryController, // ✅ date goes inside field
                readOnly: true,
                decoration: field("License Expiry Date"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.accent, // ✅ accent calendar
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      expiryDate = picked;
                      licenseExpiryController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
              ),

            ],
          ),

                ],
              ),
            ),

            // SPECIALIZATION
            section(
              "Specialization",
              showSpec,
                  () => setState(() => showSpec = !showSpec),
              Column(
                children: [
                  TextField(
                    controller: specializationController,
                    decoration: field("Add specialization"),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 BIGGER ADD BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50, // ✅ increased size
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (specializationController.text.isNotEmpty) {
                          setState(() {
                            specializations.add(specializationController.text);
                            specializationController.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Specialization",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 SPECIALIZATION LIST (TEXTFIELD SIZE + ❌)
                  Column(
                    children: specializations.map((spec) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 50, // ✅ same as textfield
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.text(context)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              spec,
                              style: const TextStyle(fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => specializations.remove(spec));
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

            ),


            // EDUCATION
            section(
              "Education",
              showEdu,
                  () => setState(() => showEdu = !showEdu),
              Column(
                children: [
                  TextField(
                      controller: degreeController,
                      decoration: field("Degree")),
                  const SizedBox(height: 8),
                  TextField(
                      controller: instituteController,
                      decoration: field("Institute")),
                  const SizedBox(height: 8),
                  TextField(
                      controller: yearController,
                      decoration: field("Year")),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (degreeController.text.isEmpty) return;

                        setState(() {
                          education.add({
                            "degree": degreeController.text,
                            "institute": instituteController.text,
                            "year": yearController.text,
                          });
                          degreeController.clear();
                          instituteController.clear();
                          yearController.clear();
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Education",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: education.map((edu) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.text(context)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${edu['degree']} • ${edu['institute']} • ${edu['year']}",
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => education.remove(edu));
                              },
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),


                ],

              ),

            ),

            // EXPERIENCE
            section(
              "Experience",
              showExp,
                  () => setState(() => showExp = !showExp),
              Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: totalYears),
                    decoration: field("Total Years of Experience"),
                    onChanged: (v) => totalYears = v,
                  ),

                  const SizedBox(height: 8),
                  TextField(
                      controller: orgController,
                      decoration:
                      field("Hospital / Clinic Name")),
                  const SizedBox(height: 8),
                  TextField(
                      controller: roleController,
                      decoration: field("Role")),
                  const SizedBox(height: 8),
                  TextField(
                      controller: durationController,
                      decoration: field("Duration")),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (orgController.text.isEmpty) return;

                        setState(() {
                          experienceList.add({
                            "organization": orgController.text,
                            "role": roleController.text,
                            "duration": durationController.text,
                          });
                          orgController.clear();
                          roleController.clear();
                          durationController.clear();
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Experience",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),


                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: experienceList.map((exp) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.text(context)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${exp['organization']} • ${exp['role']} • ${exp['duration']}",
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => experienceList.remove(exp));
                              },
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),


                ],

              ),

            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveData, // 🔒 disabled while loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: PsychologistBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() => selectedIndex = index);

          switch (index) {
            case 2:
              Navigator.pushReplacementNamed(
                  context, AppRoutes.psychologistDashboard);
              break;
            case 4:
            // already on profile
              break;
          }
        },
      ),
    );
  }
}
