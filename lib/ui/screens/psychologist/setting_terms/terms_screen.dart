import 'package:flutter/material.dart';
import '../../styles/colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  bool isUrdu(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final urdu = isUrdu(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6F6),

      appBar: AppBar(
        title: Text(urdu ? "شرائط و ضوابط" : "Terms & Conditions"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          urdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _sectionTitle(urdu
                ? "ایپ کے استعمال کی شرائط"
                : "Terms of App Usage"),

            _card(
              context,
              urdu
                  ? "یہ ایپ ذہنی صحت کی نگرانی، ماہرینِ نفسیات سے رابطے، اور صحت سے متعلق رہنمائی فراہم کرنے کے لیے تیار کی گئی ہے۔ اس ایپ کے ذریعے صارفین اپنی روزمرہ کی ذہنی کیفیت کو ریکارڈ کر سکتے ہیں، مشورہ حاصل کر سکتے ہیں، اور اپنے علاج کے عمل کو بہتر بنا سکتے ہیں۔ تاہم، یہ ایپ کسی بھی ہنگامی طبی صورتحال کے لیے استعمال نہیں کی جانی چاہیے۔ اگر آپ کو فوری مدد کی ضرورت ہو تو براہِ کرم قریبی ہسپتال یا ایمرجنسی سروس سے رابطہ کریں۔"
                  : "This application is designed to provide mental health support, including mood tracking, communication with licensed psychologists, and general wellness guidance. Users can monitor their emotional state, receive recommendations, and improve their therapy journey. However, this application must not be used in emergency situations. In case of urgent medical need, users are advised to contact local emergency services or healthcare providers immediately.",
            ),

            _heading(urdu ? "طبی مشورہ نہیں" : "Not Medical Advice"),
            _card(
              context,
              urdu
                  ? "یہ ایپ کسی بھی پیشہ ورانہ طبی تشخیص، علاج، یا مشورے کا متبادل نہیں ہے۔ ایپ کے ذریعے فراہم کردہ معلومات عمومی رہنمائی کے لیے ہیں اور انہیں کسی مستند ڈاکٹر کے مشورے کے بغیر استعمال نہیں کیا جانا چاہیے۔ ہمیشہ کسی مستند ہیلتھ کیئر پروفیشنل سے مشورہ کریں۔"
                  : "This application does not replace professional medical diagnosis, treatment, or advice. Any information provided through the app is for general guidance purposes only and should not be relied upon without consulting a qualified healthcare professional. Always seek advice from a licensed practitioner regarding medical conditions.",
            ),


            _heading(urdu ? "صارف کی ذمہ داریاں" : "User Responsibilities"),
            _card(
              context,
              urdu
                  ? "صارف اپنے اکاؤنٹ کی سیکیورٹی کا خود ذمہ دار ہے۔ پاس ورڈ یا لاگ ان معلومات کو محفوظ رکھنا ضروری ہے۔ کسی بھی غیر مجاز رسائی کی صورت میں فوراً اطلاع دیں۔"
                  : "Users are responsible for maintaining the confidentiality of their account credentials. Any unauthorized access or suspicious activity should be reported immediately.",
            ),

            _heading(urdu ? "ڈیٹا کا استعمال" : "Data Usage"),
            _card(
              context,
              urdu
                  ? "ہم کسی بھی طبی فیصلے، علاج کے نتائج، یا ایپ کے استعمال سے ہونے والے کسی نقصان کے ذمہ دار نہیں ہیں۔ ایپ کی سروس میں کسی بھی قسم کی رکاوٹ یا تکنیکی خرابی کی صورت میں بھی کمپنی ذمہ دار نہیں ہوگی۔"
                  : "We are not liable for any medical decisions, treatment outcomes, or damages resulting from the use of this application. We are also not responsible for service interruptions, technical failures, or system errors.",
            ),

            _heading(urdu ? "ذمہ داری کی حد" : "Limitation of Liability"),
            _card(
              context,
              urdu
                  ? "ہم کسی بھی وقت ان شرائط میں تبدیلی کرنے کا حق رکھتے ہیں۔ ایپ کا مسلسل استعمال اس بات کی نشاندہی کرتا ہے کہ آپ ان تبدیلیوں سے متفق ہیں۔"
                  : "We reserve the right to modify these terms at any time. Continued use of the application indicates acceptance of any updates or changes.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _card(BuildContext context, String text) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
  );
}