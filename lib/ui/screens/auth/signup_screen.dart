import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/routes.dart';
import '../../../app/translations.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import 'package:fyp/data/services/patient_service.dart';

import '../widgets/background_wrapper.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  // ================= CONTROLLERS =================
  final patientId = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final city = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // ================= DROPDOWNS =================
  String selectedCountry = "Pakistan";
  String selectedState = "Punjab";
  String selectedGender = "Male";

  DateTime? selectedDOB;

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  final patientService = PatientService();

  bool fromPsychologist = false;
  String? psychologistId;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)?.settings.arguments as Map?;

    fromPsychologist = args?['fromPsychologist'] == true;
    psychologistId = args?['psychologistId'];


  }


  // ================= PATIENT ID =================


  // ================= DOB PICKER =================
  Future<void> pickDOB() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDOB = date);
  }

  // ================= REGISTER =================
  Future<void> registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDOB == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Date of Birth")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await patientService.registerPatient(
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      phone: "+92${phone.text.trim()}",
      email: email.text.trim(),
      country: selectedCountry,
      state: selectedState,
      city: city.text.trim(),
      gender: selectedGender,
      dob: selectedDOB!,
      password: password.text.trim(),
      psychologistUid: fromPsychologist ? psychologistId : null,
    );

    setState(() => isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed")),
      );
      return;
    }

    final createdPatientUid = result["patientUid"]!;
    final createdPatientCode = result["patientCode"]!;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (fromPsychologist) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.consent,
          arguments: {
            "patientUid": createdPatientUid,
            "patientCode": createdPatientCode,
            "psychologistUid": psychologistId,
          },
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
        );
      }
    });
  }


  // ================= INPUT STYLE =================
  InputDecoration inputField(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isUrdu = Translations.isUrdu;

  final countryItems = [
      {"value": "Pakistan", "label": isUrdu ? "پاکستان" : "Pakistan"},
      {"value": "India", "label": isUrdu ? "بھارت" : "India"},
      {"value": "USA", "label": isUrdu ? "امریکہ" : "USA"},
    ];

   final stateItems = [
      {"value": "Punjab", "label": isUrdu ? "پنجاب" : "Punjab"},
      {"value": "Sindh", "label": isUrdu ? "سندھ" : "Sindh"},
      {"value": "KPK", "label": isUrdu ? "خیبر پختونخوا" : "KPK"},
      {"value": "Balochistan", "label": isUrdu ? "بلوچستان" : "Balochistan"},
      {"value": "JK", "label": isUrdu ? "کشمیر" : "JK"},
    ];
   final genderItems = [
      {"value": "Male", "label": isUrdu ? "مرد" : "Male"},
      {"value": "Female", "label": isUrdu ? "عورت" : "Female"},
      {"value": "Other", "label": isUrdu ? "دیگر" : "Other"},
    ];
    return Scaffold(

      backgroundColor: Theme.of(context).cardColor,

      body: BackgroundWrapper(
      imagePath: "assets/background/icons.png",
      child:SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    languageToggle(),
                  ],
                ),                // HEADER
                Row(
                  children: [

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUrdu ? "مریض اکاؤنٹ بنائیں" : "Create Patient Account",
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // FIRST NAME
                TextFormField(
                  controller: firstName,
                  decoration:
                  inputField( isUrdu ? "پہلا نام" : "First Name", Icons.person),
                  validator: (v) =>
                  v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 15),

                // LAST NAME
                TextFormField(
                  controller: lastName,
                  decoration: inputField(
                      isUrdu ? "آخری نام" : "Last Name", Icons.person_outline),
                  validator: (v) =>
                  v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 15),

                // PHONE
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration:
                  inputField( isUrdu ? "فون نمبر" : "Phone Number", Icons.phone),
                  validator: (v) =>
                  v!.length < 10 ? "Invalid number" : null,
                ),

                const SizedBox(height: 15),

                // EMAIL
                TextFormField(
                  controller: email,
                  decoration:
                  inputField(isUrdu ? "ای میل" : "Email", Icons.email),
                  validator: (v) =>
                  !v!.contains("@") ? "Invalid email" : null,
                ),

                const SizedBox(height: 15),

                // DOB
                GestureDetector(
                  onTap: pickDOB,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: inputField(
                        selectedDOB == null
                            ? isUrdu ? "تاریخ پیدائش" : "Date of Birth"
                            : "${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}",
                        Icons.calendar_month,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // COUNTRY
                DropdownButtonFormField(
                  value: selectedCountry,
                  decoration: inputField(
                    isUrdu ? "ملک" : "Country",
                    Icons.flag,
                  ),
                  items: countryItems.map((item) {
                    return DropdownMenuItem(
                      value: item["value"], // 🔥 ENGLISH STORED
                      child: Text(item["label"]!), // 🔥 URDU/ENGLISH UI
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedCountry = v!),
                ),
                const SizedBox(height: 15),

                // STATE
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: inputField(
                    isUrdu ? "صوبہ" : "State",
                    Icons.map,
                  ),
                  items: stateItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item["value"], // ✅ ALWAYS ENGLISH STORED
                      child: Text(item["label"]!), // ✅ URDU/ENGLISH UI
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedState = v);
                    }
                  },
                ),

                const SizedBox(height: 15),

                // CITY
                TextFormField(
                  controller: city,
                  decoration:
                  inputField( isUrdu ? "شہر" : "City", Icons.location_city),
                  validator: (v) =>
                  v!.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 15),


          DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: inputField(
          isUrdu ? "جنس" : "Gender",
          Icons.person,
          ),
          items: genderItems.map((item) {
            return DropdownMenuItem<String>(
              value: item["value"],
              child: Text(item["label"]!),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => selectedGender = v);
            }
          },
        ),
                const SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: password,
                  obscureText: !showPassword,
                  decoration: inputField( isUrdu ? "پاس ورڈ" : "Password", Icons.lock)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                              () => showPassword = !showPassword),
                    ),
                  ),
                  validator: (v) =>
                  v!.length < 6 ? "Too short" : null,
                ),

                const SizedBox(height: 15),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: confirmPassword,
                  obscureText: !showConfirmPassword,
                  decoration:
                  inputField(isUrdu ? "پاس ورڈ کی تصدیق" : "Confirm Password", Icons.lock)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() =>
                      showConfirmPassword =
                      !showConfirmPassword),
                    ),
                  ),
                  validator: (v) =>
                  v != password.text
                      ? "Passwords do not match"
                      : null,
                ),

                const SizedBox(height: 25),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                    isLoading ? null : registerPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ?  CircularProgressIndicator(
                        color: Theme.of(context).cardColor)
                        : Text(
                      isUrdu ? "اکاؤنٹ بنائیں" : "Create Account",
                      style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
  Widget languageToggle() {
    final isUrdu = Translations.isUrdu;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// URDU
          GestureDetector(
            onTap: () {
              setState(() {
                Translations.isUrdu = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isUrdu ? const Color(0xff4E7D7A) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "اردو",
                style: TextStyle(
                  color: isUrdu ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          /// ENGLISH
          GestureDetector(
            onTap: () {
              setState(() {
                Translations.isUrdu = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: !isUrdu ? const Color(0xff4E7D7A) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Eng",
                style: TextStyle(
                  color: !isUrdu ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
