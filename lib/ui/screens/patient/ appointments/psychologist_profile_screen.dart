import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/routes.dart';
import '../../../../app/translations.dart';
import '../../../common/translated_text.dart';

class PsychologistDetailScreen extends StatelessWidget {
  const PsychologistDetailScreen({super.key});
  Future<void> makePhoneCall(String phoneNumber) async {

    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }

  }
  @override
  Widget build(BuildContext context) {

    final psychologistId =
    ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
      foregroundColor: Colors.white,
      title: Text(Translations.t("Profile")),
        centerTitle: true,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("psychologists")
            .doc(psychologistId)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name =
              "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}";

          final imageUrl = data["profileImageUrl"] ?? "";
          final license =
              data["licenseNumber"]?.toString() ?? "";

          /// EXPERIENCE
          Map<String, dynamic> experienceMap = {};

          if (data["experience"] is Map) {
            experienceMap =
            Map<String, dynamic>.from(data["experience"]);
          }

          final experience =
              experienceMap["totalYears"]?.toString() ?? "";

          /// SPECIALIZATIONS
          List specializations = [];

          if (data["specializations"] is List) {
            specializations =
                List.from(data["specializations"]);
          }

          /// CLINIC DETAILS
          Map<String, dynamic> clinic = {};

          if (data["clinicDetails"] is Map) {
            clinic =
            Map<String, dynamic>.from(data["clinicDetails"]);
          }

          final fee =
              clinic["inClinicFee"]?.toString() ?? "";

          final clinicName =
              clinic["clinicName"]?.toString() ?? "";

          final address =
              clinic["address"]?.toString() ?? "";

          /// CONTACT DETAILS
          Map<String, dynamic> contactDetails = {};

          if (data["contactDetails"] is Map) {
            contactDetails =
            Map<String, dynamic>.from(data["contactDetails"]);
          }

          final phonesData =
          contactDetails["phoneNumbers"];

          List<String> phones = [];

          if (phonesData is List) {
            phones = List<String>.from(phonesData);
          }
          else if (phonesData is String &&
              phonesData.isNotEmpty) {

            phones = [phonesData];
          }

          /// EDUCATION
          List education = [];

          if (data["education"] is List) {
            education = List.from(data["education"]);
          }

          return SingleChildScrollView(

            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// PROFILE HEADER
                Row(
                  children: [

                    Stack(
                      children: [

                        CircleAvatar(
                          radius: 55,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),

                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            height: 18,
                            width: 18,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          TranslatedText(
                            name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2A8CAD)),
                          ),

                          TranslatedText(
                            "PMDC License: $license",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              fee,
                              style:  TextStyle(
                                  color: Theme.of(context).cardColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// BUTTONS
                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff4E7D7A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                        onPressed: () {

                          if (phones.isNotEmpty) {
                            makePhoneCall(phones[0]);
                          }

                        },
                        child: Text(
                          Translations.t("callMe"),
                          style:  TextStyle(color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4E7D7A),
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                        onPressed: () {

                          Navigator.pushNamed(
                            context,
                            "/book-appointment",
                            arguments: {
                              "psychologistId": psychologistId,
                              "psychologistName": name,
                            },
                          );

                        },
                        child: Text(
                          Translations.t("Book Appointment"),
                          style: TextStyle(color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                /// EXPERIENCE
                _section(

                    icon: Icons.work,
                    title: Translations.t("experience"),
                  child: TranslatedText("$experience"),
                ),

                /// SPECIALITIES
                _section(
                  icon: Icons.psychology,
                  title: Translations.t("specialities"),
                  child: Wrap(
                    spacing: 8,
                    children: specializations
                        .map<Widget>((s) => Chip(label: TranslatedText(s)))
                        .toList(),
                  ),
                ),

                /// HOSPITAL
                _section(
                  icon: Icons.local_hospital,
                  title: Translations.t("hospital"),
                  child: TranslatedText(clinicName),
                ),

                /// QUALIFICATION
                _section(
                  icon: Icons.school,
                  title: Translations.t("qualification"),
                  child: Wrap(
                    spacing: 8,
                    children: education.map<Widget>((e) {

                      String degree = "";

                      if (e is Map) {
                        degree = e["degree"]?.toString() ?? "";
                      }
                      return Chip(label: TranslatedText(degree));
                    }).toList(),
                  ),
                ),

                /// ADDRESS
                _section(
                  icon: Icons.location_on,
                  title: Translations.t("address"),
                  child: TranslatedText(address),
                ),

                /// PHONE
                _section(
                  icon: Icons.phone,
                  title: Translations.t("phone"),
                  child: Text(
                    phones.isNotEmpty ? phones[0] : "",
                  ),
                ),

                const SizedBox(height: 20),

                /// CONFIDENTIAL
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Colors.grey.shade300),

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          Translations.t("safeInfo"),
                        ),
                      )],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, color: const Color(0xff4E7D7A)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Divider(),

          child,
        ],
      ),
    );
  }
}