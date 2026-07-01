import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme_notifier.dart';
import '../../styles/colors.dart';
import '../../../common/psychologist_bottom_nav.dart';

class PsychologistSettingsScreen extends StatefulWidget {
  const PsychologistSettingsScreen({super.key});

  @override
  State<PsychologistSettingsScreen> createState() =>
      _PsychologistSettingsScreenState();
}

class _PsychologistSettingsScreenState extends State<PsychologistSettingsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  bool isSavingPrefs = false;

  // Account settings
  bool showPassword = false;
  bool showEmailPassword = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newEmailController = TextEditingController();
  final emailPasswordController = TextEditingController();

  // Notifications
  bool appointmentReminders = true;
  bool patientMessages = false;

  // App preferences
  final List<String> languages = ["English", "Urdu"];
  final List<String> timezones = ["GMT +5", "GMT +4", "GMT +3", "GMT +0"];
  final List<String> themes = ["Light", "Dark"];

  String selectedLanguage = "English";
  String selectedTimezone = "GMT +5";
  String selectedTheme = "Light";

  InputDecoration field(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffix,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:  BorderSide(color: AppColors.text(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<DocumentReference<Map<String, dynamic>>> _doc() async {
    return FirebaseFirestore.instance.collection("psychologists").doc(uid);
  }

  Future<void> _loadSettings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .get();

      final data = snap.data() ?? {};

      // Email shown in UI
      final authEmail = FirebaseAuth.instance.currentUser?.email ?? "";
      newEmailController.text = authEmail;

      final notif = (data["notifications"] as Map<String, dynamic>?) ?? {};
      appointmentReminders =
          (notif["appointmentReminders"] as bool?) ?? true;
      patientMessages = (notif["patientMessages"] as bool?) ?? false;

      final prefs = (data["preferences"] as Map<String, dynamic>?) ?? {};
      selectedLanguage = (prefs["language"] as String?) ?? "English";
      selectedTimezone = (prefs["timezone"] as String?) ?? "GMT +5";
      selectedTheme = (prefs["theme"] as String?) ?? "Light";

      // Apply theme instantly
      if (mounted) {
        context.read<ThemeNotifier>().setThemeString(selectedTheme);
      }
    } catch (_) {
      // ignore – keep defaults
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------- Firebase Auth Helpers -----------------

  Future<void> _changePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _toast("Please fill all password fields");
      return;
    }
    if (newPass.length < 6) {
      _toast("New password must be at least 6 characters");
      return;
    }
    if (newPass != confirm) {
      _toast("New password and confirm password do not match");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email;

      if (email == null || email.isEmpty) {
        _toast("No email found for this account");
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: email,
        password: current,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _toast("Password updated successfully ✅");
    } catch (e) {
      _toast("Password update failed: $e");
    }
  }

  Future<void> _changeEmail() async {
    final password = emailPasswordController.text.trim();
    final newEmail = newEmailController.text.trim();

    if (password.isEmpty || newEmail.isEmpty) {
      _toast("Enter password and new email");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final oldEmail = user.email!;

      final cred = EmailAuthProvider.credential(
        email: oldEmail,
        password: password,
      );

      // 🔐 Reauthenticate
      await user.reauthenticateWithCredential(cred);

      // 🔄 Send verification email
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection("psychologists")
          .doc(uid)
          .update({"email": newEmail});

      _toast("Verification email sent. Please verify and login again.");
    } catch (e) {
      _toast("Email update failed: $e");
    }
  }
  Future<void> saveFunction() async {
    setState(() => isSavingPrefs = true);
    try {
      await FirebaseFirestore.instance.collection("psychologists").doc(uid).set({
        "notifications": {
          "appointmentReminders": appointmentReminders,
          "patientMessages": patientMessages,
        },
        "preferences": {
          "language": selectedLanguage,
          "timezone": selectedTimezone,
          "theme": selectedTheme,
        },
      }, SetOptions(merge: true));

      // Apply theme instantly
      if (mounted) {
        context.read<ThemeNotifier>().setThemeString(selectedTheme);
      }

      _toast("Settings saved ✅");
    } catch (e) {
      _toast("Save failed: $e");
    } finally {
      if (mounted) setState(() => isSavingPrefs = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newEmailController.dispose();
    emailPasswordController.dispose();
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      bottomNavigationBar: PsychologistBottomNav(
        selectedIndex: 0, // if settings tab index is 0 in your app
        onTap: (index) {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- Account Settings ----------------
            sectionTitle("Account Settings"),
            const SizedBox(height: 14),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Change Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: currentPasswordController,
              obscureText: !showPassword,
              decoration: field(
                "Current Password",
                suffix: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.text(context),
                  ),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: field("New Password"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: field("Confirm New Password"),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _changePassword,
                icon:  Icon(Icons.lock, color: Theme.of(context).cardColor),
                label:  Text(
                  "Update Password",
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

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Update Email",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: field(
                "Email",
                suffix: const Icon(Icons.mail, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: emailPasswordController,
              obscureText: !showEmailPassword,
              decoration: field(
                "Password (for verification)",
                suffix: IconButton(
                  icon: Icon(
                    showEmailPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.text(context),
                  ),
                  onPressed: () => setState(
                          () => showEmailPassword = !showEmailPassword),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _changeEmail,
                icon:  Icon(Icons.email, color: Theme.of(context).cardColor),
                label:  Text(
                  "Update Email",
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

            const SizedBox(height: 26),

            // ---------------- Notifications ----------------
            sectionTitle("Notifications"),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Appointment reminders",
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  activeColor: AppColors.primary,
                  value: appointmentReminders,
                  onChanged: (v) => setState(() => appointmentReminders = v),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Patient messages",
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  activeColor: AppColors.primary,
                  value: patientMessages,
                  onChanged: (v) => setState(() => patientMessages = v),
                )
              ],
            ),

            const SizedBox(height: 26),

            // ---------------- App Preferences ----------------
            sectionTitle("App Preferences"),
            const SizedBox(height: 14),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              decoration: field("Language"),
              items: languages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedLanguage = v ?? "English"),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Time Zone",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTimezone,
              decoration: field("Time Zone"),
              items: timezones
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedTimezone = v ?? "GMT +5"),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Theme",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTheme,
              decoration: field("Theme"),
              items: themes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                final val = v ?? "Light";
                setState(() => selectedTheme = val);

                // apply instantly
                context.read<ThemeNotifier>().setThemeString(val);
              },
            ),

            const SizedBox(height: 22),

            // Save button (bottom-right like your UI)
            // Save button (match screenshot)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 52,
                  width: 180, // <-- control width here
                  child: ElevatedButton(
                    onPressed: isSavingPrefs ? null : saveFunction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 3, // small shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22), // more pill shape
                      ),
                    ),
                    child: isSavingPrefs
                        ?  SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).cardColor,
                      ),
                    )
                        :  Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}