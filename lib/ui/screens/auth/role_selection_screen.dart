import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';
import '../../../app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});



  @override

  Widget build(BuildContext context) {

    final Object? args = ModalRoute.of(context)?.settings.arguments;

    bool fromGoogle = false;
    User? googleUser;

    if (args is Map) {
      fromGoogle = args["fromGoogle"] ?? false;
      googleUser = args["googleUser"];
    }
    print("fromGoogle: $fromGoogle");
    return Scaffold(
      backgroundColor: Color(0xFF595959).withOpacity(0.55),


      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 2),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TITLE
              Text(
                "Join as a Patient or a Doctor",
                style: AppTextStyles.body.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Choose how you want to register",
                style: AppTextStyles.small,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// PATIENT BUTTON
              GestureDetector(
                onTap: () async {
                  if (fromGoogle && googleUser != null) {

                    await FirebaseFirestore.instance
                        .collection("patients")
                        .doc(googleUser.uid)
                        .set({
                      "email": googleUser.email,
                      "name": googleUser.displayName,
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                    Navigator.pushReplacementNamed(
                        context, AppRoutes.patientDashboard);

                  } else {
                    Navigator.pushNamed(context, AppRoutes.patientSignup);
                  }                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 32, color: AppColors.primary),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("I am a Patient",
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                )),
                            Text("Connect with your psychologist and track your progress."),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// PSYCHOLOGIST BUTTON
              GestureDetector(
                onTap: () async{
                  if (fromGoogle && googleUser != null) {

                    await FirebaseFirestore.instance
                        .collection("psychologists")
                        .doc(googleUser.uid)
                        .set({
                      "email": googleUser.email,
                      "name": googleUser.displayName,
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                    Navigator.pushReplacementNamed(
                        context, AppRoutes.psychologistDashboard);

                  } else {
                    Navigator.pushNamed(context, AppRoutes.psychologistSignup);
                  }                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital, size: 32, color: AppColors.primary),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("I am a Psychologist",
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                )),
                            Text("Manage patients, assessments and track their well-being."),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


