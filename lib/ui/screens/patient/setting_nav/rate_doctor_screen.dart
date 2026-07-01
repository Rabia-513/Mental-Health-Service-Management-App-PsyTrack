import 'package:flutter/material.dart';
import '../../../../data/services/rating_service.dart';
import '../../../../app/translations.dart';

class RateDoctorScreen extends StatefulWidget {
  const RateDoctorScreen({super.key});

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  final RatingService service = RatingService();

  Map<String, dynamic>? doctor;
  bool loading = true;
  int selectedRating = 0;

  String tr(String key) => Translations.t(key);

  @override
  void initState() {
    super.initState();
    loadDoctor();
  }

  Future<void> loadDoctor() async {
    final data = await service.getPsychologist();

    setState(() {
      doctor = data;
      loading = false;
    });
  }

  /// ⭐ STAR UI
  Widget buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = index + 1;
            });
          },
          child: Icon(
            index < selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  /// 🔹 SAFE VALUE GETTER
  String safe(dynamic value) {
    if (value == null) return "----";
    if (value is String && value.isEmpty) return "----";
    return value.toString();
  }

  /// 🔹 CARD UI
  Widget infoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff4E7D7A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctor == null) {
      return const Scaffold(
        body: Center(child: Text("No psychologist connected")),
      );
    }

    /// 🔥 SAFE DATA EXTRACTION
    final experience = doctor!["experience"]?["totalYears"];
    final clinic = doctor!["clinicDetails"];
    final education = doctor!["education"];

    return Scaffold(
      backgroundColor: const Color(0xffF5F7F7),

      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(tr("rateDoctor")),
        backgroundColor: const Color(0xff4E7D7A),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: doctor!["profileImageUrl"] != null
                        ? NetworkImage(doctor!["profileImageUrl"])
                        : null,
                    child: doctor!["profileImageUrl"] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Dr ${safe(doctor!["firstName"])} ${safe(doctor!["lastName"])}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff4E7D7A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "PMDC License: ${safe(doctor!["licenseNumber"])}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      safe(clinic?["inClinicFee"]),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 DETAILS (FIXED SAFE)
            infoCard(tr("experience"),
                safe(experience),
                Icons.work),

            infoCard(tr("specialities"),
                safe((doctor!["specializations"] ?? []).join(", ")),
                Icons.psychology),



            infoCard(tr("hospital"),
                safe(clinic?["clinicName"]),
                Icons.local_hospital),

            infoCard(tr("qualification"),
                (education != null && education.isNotEmpty)
                    ? safe(education[0]["degree"])
                    : "----",
                Icons.school),


            infoCard(tr("address"),
                safe(clinic?["address"]),
                Icons.location_on),

            infoCard(tr("phone"),
                safe((doctor!["contactDetails"]?["phoneNumbers"] ?? []).join(", ")),
                Icons.phone),

            const SizedBox(height: 16),

            /// 🔹 QUESTION
            Text(
              tr("rateQuestion"),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// ⭐ STARS
            buildStars(),

            const SizedBox(height: 20),

            /// 🔹 SUBMIT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4E7D7A),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: selectedRating == 0
                  ? null
                  : () async {
                await service.submitRating(
                  psychUid: doctor!["uid"],
                  rating: selectedRating.toDouble(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr("ratingSubmitted"),)),
                );

                Navigator.pop(context);
              },
              child: Text(tr("submitReview"),style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),

            /// 🔹 SAFE TEXT
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tr("safeMessage")))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}