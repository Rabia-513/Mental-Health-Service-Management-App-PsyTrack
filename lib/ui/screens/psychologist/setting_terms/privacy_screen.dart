import 'package:flutter/material.dart';
import '../../styles/colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  bool isUrdu(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final urdu = isUrdu(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6F6),

      appBar: AppBar(
        title: Text(urdu ? "پرائیویسی پالیسی" : "Privacy Policy"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          urdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [

            _title(urdu ? "آپ کی رازداری اہم ہے" : "Your Privacy Matters"),

            _card(
              urdu
                  ? "ہم آپ کی ذاتی معلومات کو انتہائی سنجیدگی سے لیتے ہیں۔ یہ پرائیویسی پالیسی اس بات کی وضاحت کرتی ہے کہ ہم آپ کا ڈیٹا کیسے جمع کرتے ہیں، استعمال کرتے ہیں، اور محفوظ رکھتے ہیں۔"
                  : "We take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your personal information when you use our application.",
            ),

            /// 🔹 DATA COLLECTION
            _heading(urdu ? "ہم کیا معلومات جمع کرتے ہیں" : "Information We Collect"),
            _card(
              urdu
                  ? "ہم درج ذیل معلومات جمع کر سکتے ہیں:\n\n"
                  "- نام، ای میل، اور پروفائل معلومات\n"
                  "- موڈ چیک اِن اور ذاتی نوٹس\n"
                  "- سیشن اور اپائنٹمنٹ کی تفصیلات\n"
                  "- ماہرِ نفسیات کے ساتھ رابطہ کی معلومات\n\n"
                  "یہ معلومات آپ کے تجربے کو بہتر بنانے کے لیے استعمال کی جاتی ہیں۔"
                  : "We may collect the following information:\n\n"
                  "- Name, email, and profile details\n"
                  "- Mood check-ins and personal notes\n"
                  "- Session and appointment information\n"
                  "- Communication with psychologists\n\n"
                  "This data helps us improve your experience.",
            ),

            /// 🔹 DATA USAGE
            _heading(urdu ? "ہم آپ کا ڈیٹا کیسے استعمال کرتے ہیں" : "How We Use Your Data"),
            _card(
              urdu
                  ? "آپ کی معلومات درج ذیل مقاصد کے لیے استعمال کی جاتی ہیں:\n\n"
                  "- ذاتی نوعیت کی تجاویز فراہم کرنا\n"
                  "- ماہرینِ نفسیات سے رابطہ ممکن بنانا\n"
                  "- ایپ کی کارکردگی بہتر بنانا\n"
                  "- صارف کے تجربے کو بہتر بنانا"
                  : "Your data is used for:\n\n"
                  "- Providing personalized recommendations\n"
                  "- Enabling communication with psychologists\n"
                  "- Improving app functionality\n"
                  "- Enhancing user experience",
            ),

            /// 🔹 DATA PROTECTION
            _heading(urdu ? "ڈیٹا کا تحفظ" : "Data Protection"),
            _card(
              urdu
                  ? "ہم آپ کے ڈیٹا کو محفوظ رکھنے کے لیے جدید سیکیورٹی سسٹمز استعمال کرتے ہیں۔ تمام معلومات محفوظ سرورز پر محفوظ کی جاتی ہیں اور غیر مجاز رسائی سے بچائی جاتی ہیں۔"
                  : "We use secure technologies to protect your data. All information is stored on secure servers and protected from unauthorized access.",
            ),

            /// 🔹 DATA SHARING
            _heading(urdu ? "ڈیٹا شیئرنگ" : "Data Sharing"),
            _card(
              urdu
                  ? "ہم آپ کا ذاتی ڈیٹا فروخت نہیں کرتے۔ آپ کی معلومات صرف درج ذیل صورتوں میں شیئر کی جا سکتی ہیں:\n\n"
                  "- آپ کے مقرر کردہ ماہرِ نفسیات کے ساتھ\n"
                  "- قانونی تقاضوں کے تحت"
                  : "We do not sell your personal data. Your information may only be shared:\n\n"
                  "- With your assigned psychologist\n"
                  "- When required by law",
            ),

            /// 🔹 USER RIGHTS
            _heading(urdu ? "صارف کے حقوق" : "User Rights"),
            _card(
              urdu
                  ? "آپ کو درج ذیل حقوق حاصل ہیں:\n\n"
                  "- اپنی معلومات اپڈیٹ کرنا\n"
                  "- ڈیٹا حذف کروانا (اگر دستیاب ہو)\n"
                  "- اپنی معلومات کے استعمال کو کنٹرول کرنا"
                  : "You have the right to:\n\n"
                  "- Update your information\n"
                  "- Request data deletion (if available)\n"
                  "- Control how your data is used",
            ),

            /// 🔹 THIRD PARTY
            _heading(urdu ? "تیسرے فریق کی خدمات" : "Third-Party Services"),
            _card(
              urdu
                  ? "ہم Firebase جیسے محفوظ پلیٹ فارمز استعمال کرتے ہیں۔ یہ سروسز ڈیٹا کو محفوظ رکھنے کے لیے عالمی معیار پر عمل کرتی ہیں۔"
                  : "We may use trusted services like Firebase. These platforms follow strict security standards to protect your data.",
            ),

            /// 🔹 POLICY UPDATE
            _heading(urdu ? "پالیسی میں تبدیلی" : "Policy Updates"),
            _card(
              urdu
                  ? "ہم اس پالیسی کو وقتاً فوقتاً اپڈیٹ کر سکتے ہیں۔ ایپ کا استعمال جاری رکھنے کا مطلب ہے کہ آپ ان تبدیلیوں سے متفق ہیں۔"
                  : "We may update this policy from time to time. Continued use of the app indicates your acceptance of these changes.",
            ),

          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary),
    ),
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _card(String text) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.5),
    ),
  );
}