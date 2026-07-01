import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../app/routes.dart';
import '../../../app/translations.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  Future<void> saveFCMToken({
    required String collectionName,
    required String topic,
  }) async {
    String? token = await FirebaseMessaging.instance.getToken();
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(uid)
        .set({
      "fcmToken": token,
    }, SetOptions(merge: true));

    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }  // ===============================
  Future<void> loginWithEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showMsg( Translations.isUrdu
          ? "ای میل اور پاس ورڈ درج کریں"
          : "Email and password required",);
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential cred =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = cred.user!;

      await user.reload();
      user = FirebaseAuth.instance.currentUser!;

      if (!user.emailVerified) {
        await user.sendEmailVerification();

        showMsg(
          "Verification email sent kindly Check spam folder too. Please verify your email and login again.",
        );

        await FirebaseAuth.instance.signOut();
        setState(() => isLoading = false);
        return;
      }

      final uid = user.uid;
      // 🔥 CONNECT USER WITH ONESIGNAL
      OneSignal.login(uid);
      await OneSignal.Notifications.requestPermission(true);
      await OneSignal.User.pushSubscription.optIn();

      /// CHECK PATIENT FIRST
      final patientDoc = await FirebaseFirestore.instance
          .collection("patients")
          .doc(uid)
          .get();

      if (patientDoc.exists) {
        await saveFCMToken(
          collectionName: "patients",
          topic: "patient",
        );
        OneSignal.User.addTagWithKey("role", "patient");
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, "/patient-dashboard");
        return;
      }

      /// CHECK PSYCHOLOGIST
      final psychologistDoc = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .get();

      if (psychologistDoc.exists) {
        await saveFCMToken(
          collectionName: "psychologists",
          topic: "psychologist",
        );
        OneSignal.User.addTagWithKey("role", "psychologist");
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, "/psychologist-dashboard");
        return;
      }

      /// CHECK FAMILY
      final familyDoc = await FirebaseFirestore.instance
          .collection("family")
          .doc(uid)
          .get();

      if (familyDoc.exists) {
        await saveFCMToken(
          collectionName: "family",
          topic: "family",
        );
        OneSignal.User.addTagWithKey("role", "family");
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, "/family-dashboard");
        return;
      }

      setState(() => isLoading = false);
      showMsg("User role not found");
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      showMsg(e.message ?? "Login failed");
    } catch (e) {
      setState(() => isLoading = false);
      showMsg("Something went wrong");
    }
  }
// ===============================
// GOOGLE LOGIN
// ===============================
  Future<void> loginWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user!;
      final uid = user.uid;
      OneSignal.login(uid);
      await OneSignal.Notifications.requestPermission(true);
      await OneSignal.User.pushSubscription.optIn();
      final patientDoc = await FirebaseFirestore.instance
          .collection("patients")
          .doc(uid)
          .get();

// CHECK PATIENT
      if (patientDoc.exists) {
        await saveFCMToken(
          collectionName: "patients",
          topic: "patient",
        );

        Navigator.pushReplacementNamed(context, "/patient-dashboard");
        setState(() => isLoading = false);
        return;
      }

      final psychologistDoc = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .get();

      if (psychologistDoc.exists) {
        await saveFCMToken(
          collectionName: "psychologists",
          topic: "psychologist",
        );

        Navigator.pushReplacementNamed(context, "/psychologist-dashboard");
        setState(() => isLoading = false);
        return;
      }
      final familyDoc = await FirebaseFirestore.instance
          .collection("family")
          .doc(uid)
          .get();

      // CHECK FAMILY
      if (familyDoc.exists) {
        await saveFCMToken(
          collectionName: "family",
          topic: "family",
        );

        Navigator.pushReplacementNamed(context, "/family-dashboard");
        setState(() => isLoading = false);
        return;
      }

// ❌ NOT REGISTERED → BLOCK
      await FirebaseAuth.instance.signOut();

      setState(() => isLoading = false);

      showMsg("Account not found. Please sign up first.");
    } catch (e) {
      setState(() => isLoading = false);
      showMsg("Google Sign-In Failed");
    }
  }  // ===============================
  // RESET PASSWORD
  // ===============================
  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      showMsg("Enter your email to reset password");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      showMsg("Password reset email sent");
    } on FirebaseAuthException catch (e) {
      showMsg(e.message ?? "Failed to send reset email");
    }
  }

  // ===============================
  // HELPERS
  // ===============================
  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.card(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background/icons.png",
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.18),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      languageToggle(),
                    ],
                  ),
                  Image.asset(
                    "assets/images/logo.png",
                    height: 140,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    Translations.isUrdu
    ? "اپنے اکاؤنٹ میں لاگ ان کریں"
        : "Sign in to your account",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                    inputDecoration(  Translations.isUrdu? "ای میل" : "Email address",
                         Icons.email),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration:
                    inputDecoration(  Translations.isUrdu? "پاس ورڈ" : "Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: resetPassword,
                      child: Text(
                        Translations.isUrdu ? "پاس ورڈ بھول گئے؟" : "Forgot Password?",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : loginWithEmail,
                      icon: Icon(Icons.login, color: AppColors.card(context)),
                      label: isLoading
                          ?  CircularProgressIndicator(
                          color: AppColors.card(context))
                          : Text(
                        Translations.isUrdu ? "لاگ ان کریں" : "Sign In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.card(context),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : loginWithGoogle,
                      icon: Image.asset(
                        "assets/images/google.PNG", // optional if you have icon
                        height: 22,
                      ),
                      label:Text(
                        Translations.isUrdu
    ? "گوگل سے لاگ ان کریں"
        : "Sign in with Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text(Translations.isUrdu
                          ? "اکاؤنٹ نہیں ہے؟"
                          : "Don’t have an account?"

                          ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/role-selection");
                        },
                        child: Text(
                          Translations.isUrdu? "سائن اپ کریں" : "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
  Widget languageToggle() {
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
                color: Translations.isUrdu
                    ? const Color(0xff4E7D7A)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "اردو",
                style: TextStyle(
                  color: Translations.isUrdu
                      ? Colors.white
                      : Colors.black,
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
                color: !Translations.isUrdu
                    ? const Color(0xff4E7D7A)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Eng",
                style: TextStyle(
                  color: !Translations.isUrdu
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
