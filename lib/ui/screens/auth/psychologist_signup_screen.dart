import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../styles/colors.dart';
import '../styles/text_styles.dart';

class PsychologistSignupScreen extends StatefulWidget {
  const PsychologistSignupScreen({super.key});

  @override
  State<PsychologistSignupScreen> createState() =>
      _PsychologistSignupScreenState();
}

class _PsychologistSignupScreenState extends State<PsychologistSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final qualification = TextEditingController();
  final license = TextEditingController();
  final experience = TextEditingController();

  final clinicName = TextEditingController();
  final clinicAddress = TextEditingController();
  final clinicPhone = TextEditingController();
  final clinicEmail = TextEditingController();

  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  // ================= PERSONAL INFO =================
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  DateTime? dateOfBirth;
  final dobController = TextEditingController();

  String selectedGender = "Male";
  final List<String> genders = ["Male", "Female", "Other"];


  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  // ================= WORKING SCHEDULE =================
  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  final List<String> timeSlots = [
    "9 AM – 1 PM",
    "1 PM – 5 PM",
    "5 PM – 9 PM",
    "9 AM – 5 PM",
    "9 AM – 9 PM",
  ];

  List<String> selectedDays = [];
  String? selectedTime;


  /// Supabase client
  final supabase = Supabase.instance.client;

  /// Certificate image file
  File? certificateImage;
  final ImagePicker picker = ImagePicker();

  /// Working Days & Hours
  String workingDays = "Monday • Thursday • Friday";
  String workingHours = "For Monday | 9 AM to 9 PM";

  /// PICK CERTIFICATE IMAGE
  Future<void> pickCertificateImage() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => certificateImage = File(picked.path));
    }
  }

  /// -------------------------------------------
  /// UPLOAD FILE TO SUPABASE STORAGE (FREE)
  /// -------------------------------------------
  Future<String> uploadToSupabase(File file, String path) async {
    final bytes = await file.readAsBytes();

    final response = await supabase.storage
        .from('psychologist-files')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

    if (response.isEmpty) {
      throw Exception("Upload failed");
    }

    /// Get public URL
    final url = supabase.storage
        .from('psychologist-files')
        .getPublicUrl(path);

    return url;
  }

  /// REGISTER PSYCHOLOGIST
  Future<void> registerPsychologist() async {
    if (!_formKey.currentState!.validate()) return;

    if (certificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload certificate image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      /// Firebase Auth
      UserCredential userCred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      String uid = userCred.user!.uid;

      /// Upload certificate to Supabase
      String certUrl = await uploadToSupabase(
        certificateImage!,
        "certificates/$uid-certificate.jpg",
      );

      /// Save everything to Firestore
      await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .set({
        "firstName": firstName.text.trim(),
        "lastName": lastName.text.trim(),
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "qualification": qualification.text.trim(),
        "licenseNumber": license.text.trim(),
        "experience": experience.text.trim(),

        "clinicName": clinicName.text.trim(),
        "clinicAddress": clinicAddress.text.trim(),
        "clinicPhone": clinicPhone.text.trim(),
        "clinicEmail": clinicEmail.text.trim(),

        "dob": Timestamp.fromDate(dateOfBirth!),
        "country": countryController.text.trim(),
        "state": stateController.text.trim(),
        "city": cityController.text.trim(),
        "gender": selectedGender,


        "certificateUrl": certUrl,
        "createdAt": DateTime.now(),
        "role": "psychologist",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully!")),
      );

      Navigator.pushReplacementNamed(context, "/login");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  /// INPUT FIELD UI
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
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          color: Theme.of(context).cardColor,
          image: DecorationImage(
            image: AssetImage("assets/background/icons.png"),
            fit: BoxFit.cover,
            opacity: 0.22,
            repeat: ImageRepeat.repeat,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back)),
                      Text(
                        "Creating Account",
                        style: AppTextStyles.body.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: firstName,
                    decoration: inputField("First Name", Icons.person),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: lastName,
                    decoration: inputField("Last Name", Icons.person_outline),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: phone,
                    decoration: inputField("Phone Number", Icons.phone),
                    validator: (v) => v!.length < 10 ? "Invalid Phone" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: email,
                    decoration: inputField("Email", Icons.email),
                    validator: (v) => !v!.contains("@") ? "Invalid Email" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: dobController,
                    readOnly: true, // ❗ keyboard disabled
                    decoration: inputField("Date of Birth", Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1995),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.accent, // ✅ accent color
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        dateOfBirth = picked;
                        dobController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                      }
                    },
                    validator: (_) =>
                    dateOfBirth == null ? "Select date of birth" : null,
                  ),



                  const SizedBox(height: 15),

                  TextFormField(
                    controller: countryController,
                    decoration: inputField("Country / Region", Icons.public),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: stateController,
                    decoration: inputField("State", Icons.location_city),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: cityController,
                    decoration: inputField("City", Icons.location_on),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: inputField("Gender", Icons.person),
                    items: genders.map((g) {
                      return DropdownMenuItem(value: g, child: Text(g));
                    }).toList(),
                    onChanged: (v) => setState(() => selectedGender = v!),
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: qualification,
                    decoration: inputField("Qualification", Icons.school),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: license,
                    decoration: inputField("License Number", Icons.badge),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: experience,
                    decoration: inputField("Years of Experience", Icons.timeline),
                  ),

                  const SizedBox(height: 20),
                  const SizedBox(height: 25),

// ================= CLINIC INFORMATION =================
                  Text(
                    "Clinic Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: clinicName,
                    decoration: inputField("Clinic Name", Icons.local_hospital),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: clinicAddress,
                    decoration: inputField("Clinic Address", Icons.location_on),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: clinicPhone,
                    decoration: inputField("Clinic Phone Number", Icons.call),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: clinicEmail,
                    decoration: inputField("Clinic Email (optional)", Icons.email_outlined),
                  ),

                  const SizedBox(height: 25),

// ================= WORKING SCHEDULE =================
                  Text(
                    "Working Schedule",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

// Working Days
                  GestureDetector(
                    onTap: () async {
                      final result = await showDialog<List<String>>(
                        context: context,
                        builder: (context) {
                          final tempSelected = [...selectedDays];

                          return AlertDialog(
                            title: const Text("Select Working Days"),
                            content: SingleChildScrollView(
                              child: Column(
                                children: weekDays.map((day) {
                                  return CheckboxListTile(
                                    title: Text(day),
                                    value: tempSelected.contains(day),
                                    activeColor: AppColors.primary, // ✅ THIS LINE
                                    checkColor: Theme.of(context).cardColor,       // optional but nice
                                    onChanged: (value) {
                                      value == true
                                          ? tempSelected.add(day)
                                          : tempSelected.remove(day);
                                      setState(() {});
                                    },
                                  );
                                  ;
                                }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, tempSelected),
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );

                      if (result != null) {
                        setState(() {
                          selectedDays = result;
                          workingDays = selectedDays.join(" • ");
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedDays.isEmpty
                                  ? "Select Working Days"
                                  : selectedDays.join(" • "),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),


                  const SizedBox(height: 15),

// Working Hours
                  DropdownButtonFormField<String>(
                    decoration: inputField("Working Hours", Icons.access_time),
                    value: selectedTime,
                    items: timeSlots.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTime = value;
                        workingHours = value!;
                      });
                    },
                    validator: (value) =>
                    value == null ? "Please select working hours" : null,
                  ),



                  Text(
                    "Professional Verification",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.picture_as_pdf, size: 28),
                          SizedBox(width: 8),
                          Text("License / Registration Certificate",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ]),

                        const SizedBox(height: 14),

                        Center(
                          child: ElevatedButton(
                            onPressed: pickCertificateImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).cardColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              side: BorderSide(
                                  color: AppColors.primary, width: 1.2),
                            ),
                            child: Text("Upload",
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          certificateImage == null
                              ? "No file selected"
                              : "Certificate selected ✔",
                          style: TextStyle(
                            color: certificateImage == null
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextFormField(
                    controller: password,
                    obscureText: !showPassword,
                    decoration: inputField("Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                    validator: (v) => v!.length < 6 ? "Password too short" : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: confirmPassword,
                    obscureText: !showConfirmPassword,
                    decoration:
                    inputField("Confirm Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                        showConfirmPassword = !showConfirmPassword),
                      ),
                    ),
                    validator: (v) =>
                    v != password.text ? "Passwords do not match" : null,
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : registerPsychologist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ?  CircularProgressIndicator(color: Theme.of(context).cardColor)
                          :  Text("Create Account",
                          style: TextStyle(
                              color: Theme.of(context).cardColor, fontSize: 18)),
                    ),
                  ),


                  const SizedBox(height: 15),

                  /// Already have account? Login
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/login"),
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}