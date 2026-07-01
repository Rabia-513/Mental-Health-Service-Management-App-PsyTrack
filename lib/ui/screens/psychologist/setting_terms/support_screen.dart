import 'package:flutter/material.dart';
import '../../styles/colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  bool isUrdu(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final urdu = isUrdu(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6F6),
      appBar: AppBar(
        title: Text(urdu ? "مدد اور سپورٹ" : "Help & Support"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          urdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _title(urdu ? "ہم آپ کی مدد کے لیے ہیں" : "We are here to help"),

            _card(
              urdu
                  ? "کسی بھی سوال یا مسئلے کے لیے ہم سے رابطہ کریں۔"
                  : "For any issue or feedback, contact us.",
            ),

            _heading(urdu ? "ای میل" : "Email"),
            _card("support@psytrackapp.com"),

            _heading(urdu ? "جواب کا وقت" : "Response Time"),
            _card(urdu ? "24–48 گھنٹے" : "24–48 hours"),

            _heading(urdu ? "اہم نوٹس" : "Important"),
            _card(
              urdu
                  ? "یہ ایپ ایمرجنسی کے لیے نہیں ہے"
                  : "This app is NOT for emergencies",
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primary),
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _card(String text) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Text(text),
  );
}