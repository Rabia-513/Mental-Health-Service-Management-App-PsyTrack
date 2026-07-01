import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';


import '../../../../app/routes.dart';
import '../../../../data/services/psychologist_service.dart';
import '../../../common/psychologist_bottom_nav.dart';
import '../../styles/colors.dart';
import '../../styles/text_styles.dart';



class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  bool showEmailInfo = false;
  int selectedIndex = 4;

  // Controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final country = TextEditingController();
  final dobController = TextEditingController();
  DateTime? dateOfBirth;

  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  File? selectedImage;
  String? profileImageUrl;

  final ImagePicker picker = ImagePicker();
  bool notificationsEnabled = true;
  String selectedLanguage = "English";


  DateTime? dob;
  String language = "English";


  File? pickedImage;

  bool isLoading = true;

  String get uid => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= FETCH PROFILE =================
  Future<void> loadProfile() async {
    final doc = await _firestore
        .collection('psychologists')
        .doc(uid)
        .get();

    final data = doc.data()!;

    setState(() {
      firstName.text = data['firstName'] ?? "";
      lastName.text = data['lastName'] ?? "";
      email.text = data['email'] ?? "";
      country.text = data['country'] ?? "";

      if (data['dob'] != null) {
        dob = (data['dob'] as Timestamp).toDate();
        dobController.text =
        "${dob!.day}/${dob!.month}/${dob!.year}";
      }

      language = data['language'] ?? "English";
      notificationsEnabled = data['notificationsEnabled'] ?? true;
      profileImageUrl = data['profileImageUrl'];

      isLoading = false;
    });
  }

  // ================= PICK IMAGE =================
  Future<void> pickProfileImage() async {
    final XFile? picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }


  // ================= UPLOAD IMAGE =================
  Future<String> uploadProfileImage(File file) async {
    final bytes = await file.readAsBytes();

    await _supabase.storage
        .from('psychologist-profiles')
        .uploadBinary(
      'profiles/$uid.jpg',
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage
        .from('psychologist-profiles')
        .getPublicUrl('profiles/$uid.jpg');
  }



  // ================= SAVE CHANGES =================
  Future<void> saveChanges() async {
    try {
      setState(() => isLoading = true);

      String? imageUrl = profileImageUrl;

      if (selectedImage != null) {
        imageUrl = await PsychologistService.uploadProfileImage(
          selectedImage!,
          uid,
        );
      }

      await PsychologistService.updateProfile(uid, {
        "firstName": firstName.text.trim(),
        "lastName": lastName.text.trim(),
        "country": country.text.trim(),
        "dob": dob != null ? Timestamp.fromDate(dob!) : null,
        "language": language,
        "notificationsEnabled": notificationsEnabled,
        "profileImageUrl": imageUrl,
      });

      Navigator.pop(context, true); // 🔥 tells profile screen to refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  // ================= INPUT DECORATION =================
  InputDecoration inputField(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
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
        backgroundColor: Theme.of(context).cardColor,

        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= PROFILE IMAGE =================


            const SizedBox(height: 24),

            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : (profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null) as ImageProvider?,
                child: selectedImage == null && profileImageUrl == null
                    ? const Icon(Icons.camera_alt,
                    size: 40, color: AppColors.primary)
                    : null,
              ),
            ),

            const SizedBox(height: 14),
            TextFormField(
              controller: firstName,
              decoration: inputField("First Name", Icons.person),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: lastName,
              decoration: inputField("Last Name", Icons.person_outline),
            ),

            const SizedBox(height: 14),
            if (showEmailInfo)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Email cannot be changed. If you want to change then go to the settings.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            GestureDetector(
              onTap: () {
                setState(() {
                  showEmailInfo = true;
                });
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: email,
                  readOnly: true,
                  decoration: inputField("Email", Icons.email),
                ),
              ),
            ),


            const SizedBox(height: 14),

            // ================= DOB =================
            TextFormField(
              controller: dobController,
              readOnly: true,
              decoration:
              inputField("Date of Birth", Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dob ?? DateTime(1995),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.accent,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    dob = picked;
                    dobController.text =
                    "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: country,
              decoration:
              inputField("Country / Region", Icons.public),
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: language,
              decoration:
              inputField("Language Preference", Icons.language),
              items: const [
                DropdownMenuItem(
                    value: "English", child: Text("English")),
                DropdownMenuItem(
                    value: "Urdu", child: Text("Urdu")),
              ],
              onChanged: (v) => setState(() => language = v!),
            ),

            const SizedBox(height: 14),

            SwitchListTile(
              title: const Text("Notification alerts"),
              value: notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  setState(() => notificationsEnabled = v),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon:  Icon(Icons.save,color: Theme.of(context).cardColor,),
                label:  Text("Save Changes",style: TextStyle(color: Theme.of(context).cardColor),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
