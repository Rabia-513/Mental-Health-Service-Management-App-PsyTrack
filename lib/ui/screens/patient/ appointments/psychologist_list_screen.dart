import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/translations.dart';
import '../../../../data/services/appointment_service.dart';
import '../../../common/patient_bottom_nav.dart';
import '../../../common/translated_text.dart';
import '../../styles/colors.dart';

class PsychologistListScreen extends StatefulWidget {
  const PsychologistListScreen({super.key});

  @override
  State<PsychologistListScreen> createState() => _PsychologistListScreenState();
}

class _PsychologistListScreenState extends State<PsychologistListScreen> {
  final AppointmentService appointmentService = AppointmentService();
  final searchController = TextEditingController();
  Set<String> favourites = {};
  String searchText = "";
  bool isUrdu = false;
  String selectedAll = "All";
  String selectedSpeciality = "Speciality";
  String selectedSymptoms = "Symptoms";
  String selectedFavourite = "Favourite";

  String t(String key) {
    const en = {
      "psychologist": "Psychologist",
      "search": "Search by name...",
      "consult": "Consult Me",
      "book": "Book Appointment",
      "experience": "years experience",
      "confidential": "Your information is safe and confidential",
    };

    const ur = {
      "psychologist": "ماہرِ نفسیات",
      "search": "نام سے تلاش کریں...",
      "consult": "مشورہ لیں",
      "book": "اپائنٹمنٹ بک کریں",
      "experience": "سال کا تجربہ",
      "confidential": "آپ کی معلومات محفوظ اور خفیہ ہیں",
    };

    return isUrdu ? ur[key]! : en[key]!;
  }
  int navIndex = 2;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xff4E7D7A),
        elevation: 0,
        title:  Text(
          "Psychologist",
          style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Theme.of(context).cardColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() => searchText = val.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: Translations.t("search"),
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// DROPDOWNS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _dropdownBox(

                    value: selectedAll,

                    items: const [
                      "All",

                    ],
                    onChanged: (v) => setState(() => selectedAll = v),
                  ),
                  const SizedBox(width: 8),
                  _dropdownBox(
                    value: selectedSpeciality,
                    items: const [
                      "Speciality",
                      "Clinical Psychologist",
                      "Child Psychologist",
                      "Counseling Psychologist"
                    ],
                    onChanged: (v) => setState(() => selectedSpeciality = v),
                  ),


                  const SizedBox(width: 8),
                  _dropdownBox(
                    value: selectedFavourite,
                    items: const [
                      "Favourite",
                      "All",
                      "Saved"
                    ],
                    onChanged: (v) => setState(() => selectedFavourite = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// LIST OF PSYCHOLOGISTS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("psychologists")
                  .where("profileVisibility", isEqualTo: "public")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filtered = docs.where((doc) {

                  final data = doc.data() as Map<String, dynamic>;

                  final firstName = (data["firstName"] ?? "").toString().toLowerCase();
                  final lastName = (data["lastName"] ?? "").toString().toLowerCase();
                  final fullName = "$firstName $lastName";

                  /// SEARCH FILTER
                  if (!fullName.contains(searchText)) return false;

                  /// SPECIALITY FILTER
                  final specs = data["specializations"] ?? [];
                  final speciality = specs.isNotEmpty ? specs[0] : "";

                  if (selectedSpeciality != "Speciality" &&
                      speciality != selectedSpeciality) {
                    return false;
                  }

                  /// FAVOURITE FILTER
                  if (selectedFavourite == "Saved") {
                    if (!favourites.contains(doc.id)) {
                      return false;
                    }
                  }

                  return true;

                }).toList();


                if (filtered.isEmpty) {
                  return const Center(child: Text("No psychologists found"));
                }

                return ListView.builder(

                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    /// NAME
                    final firstName = data["firstName"] ?? "";
                    final lastName = data["lastName"] ?? "";
                    final name = "$firstName $lastName".trim();

                    /// QUALIFICATION
                    final qualification = data["professionalTitle"] ?? "";

                    /// EXPERIENCE
                    String experience = "";
                    if (data["experience"] != null && data["experience"] is Map) {
                      experience = data["experience"]["totalYears"] ?? "";
                    }

                    /// SPECIALIZATION
                    String speciality = "";
                    if (data["specializations"] != null &&
                        data["specializations"] is List &&
                        data["specializations"].isNotEmpty) {
                      speciality = data["specializations"][0];
                    }

                    /// CLINIC DETAILS
                    String clinicFee = "";
                    String onlineFee = "";

                    if (data["clinicDetails"] != null && data["clinicDetails"] is Map) {
                      clinicFee = data["clinicDetails"]["inClinicFee"] ?? "";
                      onlineFee = data["clinicDetails"]["onlineFee"] ?? "";
                    }

                    /// IMAGE
                    final imageUrl = data["profileImageUrl"] ?? "";

                    return _psychologistCard(
                      uid: doc.id,
                      name: name,
                      qualification: qualification,
                      experience: experience,
                      clinicFee: clinicFee,
                      onlineFee: onlineFee,
                      speciality: speciality,
                      imageUrl: imageUrl,

                      onFavourite: () {
                        appointmentService.toggleFavourite(doc.id);
                      },

                      onShare: () async {
                        await Share.share(
                          Translations.isUrdu
                              ? "اس ماہر نفسیات $name سے مشورہ کریں۔\n\nایپ کے ذریعے آسانی سے اپائنٹمنٹ بک کریں۔"
                              : "Consult $name on our Mental Health Platform.\n\nBook appointment easily through the app.",
                        );                      },

                      onViewProfile: () {
                        Navigator.pushNamed(
                          context,
                          "/psychologist-profile-show",
                          arguments: doc.id,
                        );
                      },

                      onBookAppointment: () {
                        Navigator.pushNamed(
                          context,
                          "/book-appointment",
                          arguments: {
                            "psychologistId": doc.id,
                            "psychologistName": name,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          /// CONFIDENTIAL BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                    child:Text(Translations.t("safeInfo"))),
              ],
            ),
          ),
        ],
      ),

      /// BOTTOM NAV
      bottomNavigationBar: PatientBottomNav(
        selectedIndex: 0,
      ),    );
  }

  /// DROPDOWN UI
  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items
            .map((e) => DropdownMenuItem(value: e,
            child: Text(Translations.t(e)),))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  /// PSYCHOLOGIST CARD
  Widget _psychologistCard({
    required String uid,
    required String name,
    required String qualification,
    required String experience,
    required String clinicFee,
    required String onlineFee,
    required String speciality,
    required String imageUrl,
    required VoidCallback onFavourite,
    required VoidCallback onShare,
    required VoidCallback onViewProfile,
    required VoidCallback onBookAppointment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [

          /// -------- TOP ROW --------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// PROFILE IMAGE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),

                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(width: 12),

              /// DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    TranslatedText(
                      name,
                      style: const TextStyle(
                        color: Color(0xff2A8CAD),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    TranslatedText(
                      qualification,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    TranslatedText(
                      experience.isNotEmpty
                          ? "$experience years experience"
                          : "Experience not listed",
                      style:  TextStyle(color: AppColors.text(context), fontSize: 12),
                    ),
                  ],
                ),
              ),

              /// FEE BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  clinicFee.isNotEmpty
                      ? clinicFee
                      : (onlineFee.isNotEmpty ? onlineFee : "Fee not listed"),
                  style:  TextStyle(
                    color: Theme.of(context).cardColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// -------- SECOND ROW --------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// SPECIALITY CHIP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TranslatedText(
                  speciality.isNotEmpty ? speciality : "Psychologist",
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              Row(
                children: [

                  /// FAVOURITE
                  StreamBuilder<bool>(
                    stream: appointmentService.isFavourite(uid),
                    builder: (context, snapshot) {

                      final isFav = snapshot.data ?? false;

                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: const Color(0xff2A8CAD),
                        ),
                        onPressed: () {
                          appointmentService.toggleFavourite(uid);

                          setState(() {
                            if (favourites.contains(uid)) {
                              favourites.remove(uid);
                            } else {
                              favourites.add(uid);
                            }
                          });
                        },
                      );
                    },
                  ),

                  /// SHARE
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Color(0xff2A8CAD),
                    ),
                    onPressed: onShare,
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          /// -------- BUTTONS --------
          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: onViewProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4E7D7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  Text(
                    Translations.t("viewprofile"),
                    style: TextStyle(color: Theme.of(context).cardColor),
                  ),

                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4E7D7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  Text(
    Translations.t("Book Appointment"),
                    style: TextStyle(color: Theme.of(context).cardColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}