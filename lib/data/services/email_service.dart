import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {

  static Future sendAppointmentEmail({
    required String patientName,
    required String psychologistEmail,
    required String date,
    required String time,
  }) async {

    const serviceId = "service_w7lgnhn";
    const templateId = "template_lz6zhvd";
    const publicKey = "QEbCkuD_O_Vu-DMSU";

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "patient_name": patientName,
          "date": date,
          "time": time,
          "to_email": psychologistEmail
        }
      }),
    );

    print(response.body);
  }
}