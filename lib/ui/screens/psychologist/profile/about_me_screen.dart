import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/services/psychologist_service.dart';
import '../../styles/colors.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isSaving = false;
  bool isLoading = true;

  final summaryController = TextEditingController();

  final List<String> approaches = [
    "Cognitive Behavioral Therapy (CBT)",
    "Mindfulness",
    "Talk Therapy",
    "Psychoanalysis",
  ];

  List<String> selectedApproaches = [];
  List<String> defaultApproaches = [
    "Cognitive Behavioral Therapy (CBT)",
    "Mindfulness",
    "Talk Therapy",
    "Psychoanalysis",
  ];
  List<String> customApproaches = [];

  final customController = TextEditingController();

  final List<String> ageOptions = [
    "Children",
    "Teens",
    "Adults",
    "Elderly",
    "ALL"
  ];

  List<String> selectedAges = [];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await PsychologistService.fetchAboutMe(uid);

    if (data != null) {
      summaryController.text = data['professionalSummary'] ?? "";
      selectedApproaches =
      List<String>.from(data['treatmentApproaches'] ?? []);
      selectedAges = List<String>.from(data['ageGroups'] ?? []);
    }

    setState(() => isLoading = false);
  }

  // ================= SAVE =================
  Future<void> saveData() async {
    setState(() => isSaving = true);

    await PsychologistService.updateAboutMe(uid, {
      "professionalSummary": summaryController.text.trim(),
      "treatmentApproaches": selectedApproaches,
      "ageGroups": selectedAges,
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("About Me updated successfully")),
    );
  }

  // ================= UI HELPERS =================
  InputDecoration field(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget ageButton(String label) {
    final isAllSelected = selectedAges.contains("ALL");
    final selected = isAllSelected || selectedAges.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == "ALL") {
            if (isAllSelected) {
              selectedAges.clear(); // unselect all
            } else {
              selectedAges = ["ALL"]; // visually selects all
            }
          } else {
            if (isAllSelected) {
              selectedAges.remove("ALL");
            }

            if (selectedAges.contains(label)) {
              selectedAges.remove(label);
            } else {
              selectedAges.add(label);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            if (selected)
               Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
            if (selected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    summaryController.dispose();
    customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text("About Me"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SUMMARY =================
            const Text(
              "Professional Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Write a short introduction about yourself, your experience, and how you help patients.",
            ),
            const SizedBox(height: 8),
            TextField(
              controller: summaryController,
              maxLines: 6,
              maxLength: 300,
              decoration: field("Enter summary"),
            ),

            const SizedBox(height: 20),

            // ================= TREATMENT =================
            const Text(
              "Treatment Approach",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),

            ...approaches.map((a) {
              return CheckboxListTile(
                value: selectedApproaches.contains(a),
                activeColor: AppColors.primary,
                title: Text(a),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      selectedApproaches.add(a);
                    } else {
                      selectedApproaches.remove(a);
                    }
                  });
                },
              );
            }),
// 🔥 CUSTOM APPROACH DISPLAY (EDIT + DELETE)
            ...selectedApproaches
                .where((a) => !defaultApproaches.contains(a))
                .map((custom) {
              return ListTile(
                title: Text(custom),
                leading: const Icon(Icons.star, color: AppColors.primary),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        customController.text = custom;

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Edit Approach"),
                            content: TextField(
                              controller: customController,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    final index =
                                    selectedApproaches.indexOf(custom);
                                    selectedApproaches[index] =
                                        customController.text.trim();
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          selectedApproaches.remove(custom);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),

            // Add Custom Approach
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    decoration: field("Add Custom Approach"),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (customController.text.isEmpty) return;
                    setState(() {
                      selectedApproaches
                          .add(customController.text.trim());
                      customController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child:  Icon(Icons.add, color: Theme.of(context).cardColor),
                )
              ],
            ),

            const SizedBox(height: 20),

            // ================= AGE GROUP =================
            const Text(
              "Patient Age Groups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ageOptions.map(ageButton).toList(),
            ),

            const SizedBox(height: 30),

            // ================= SAVE =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveData,
                icon:  Icon(Icons.save_alt, color: Theme.of(context).cardColor),
                label: isSaving
                    ?  CircularProgressIndicator(
                  color: Theme.of(context).cardColor,
                  strokeWidth: 2,
                )
                    :  Text(
                  "Save Changes",
                  style: TextStyle(color: Theme.of(context).cardColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}