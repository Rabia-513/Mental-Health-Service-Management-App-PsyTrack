import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../data/services/psychologist_service.dart';
import '../../styles/colors.dart';
import '../../../common/psychologist_bottom_nav.dart';

class ClinicDetailsScreen extends StatefulWidget {
  const ClinicDetailsScreen({super.key});

  @override
  State<ClinicDetailsScreen> createState() => _ClinicDetailsScreenState();
}

class _ClinicDetailsScreenState extends State<ClinicDetailsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  LatLng? clinicLocation;
  bool isLoading = true;
  bool isSaving = false;
  bool _geocodingInProgress = false;
  Timer? _debounce;

  bool inClinic = true;
  bool online = false;

  final clinicNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  String? inClinicFee;
  String? onlineFee;

  final inClinicCustomController = TextEditingController();
  final onlineCustomController = TextEditingController();

  final List<String> feeOptions = ["PKR 1000", "PKR 1500", "PKR 2000", "Custom"];

  final ImagePicker _picker = ImagePicker();
  List<String> clinicImageUrls = [];
  List<File> newImages = [];

  InputDecoration field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadClinic();
    addressController.addListener(_onAddressChanged);
    cityController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (addressController.text.length < 4 ||
          cityController.text.isEmpty) return;

      await getCoordinates();
    });
  }

  Future<void> getCoordinates() async {
    if (_geocodingInProgress) return;
    _geocodingInProgress = true;

    try {
      final query =
          "${addressController.text.trim()}, ${cityController.text.trim()}";
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          clinicLocation = LatLng(loc.latitude, loc.longitude);
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    } finally {
      _geocodingInProgress = false;
    }
  }

  Future<void> loadClinic() async {
    final data = await PsychologistService.fetchClinicDetails(uid);

    setState(() {
      clinicNameController.text = data?['clinicName'] ?? "";
      addressController.text = data?['address'] ?? "";
      cityController.text = data?['city'] ?? "";

      final types = List<String>.from(data?['consultationTypes'] ?? []);
      inClinic = types.contains("inClinic");
      online = types.contains("online");

      clinicImageUrls =
      List<String>.from(data?['clinicImages'] ?? []);

      isLoading = false;
    });

    await getCoordinates();
  }

  Future<void> openDirections() async {
    if (clinicLocation == null) return;

    final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=${clinicLocation!.latitude},${clinicLocation!.longitude}");

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> pickClinicImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    setState(() {
      newImages.addAll(picked.map((e) => File(e.path)));
    });
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);

    if (newImages.isNotEmpty) {
      final uploaded = await PsychologistService.uploadClinicImages(
        uid: uid,
        files: newImages,
      );
      clinicImageUrls.addAll(uploaded);
      newImages.clear();
    }

    final types = <String>[];
    if (inClinic) types.add("inClinic");
    if (online) types.add("online");

    await PsychologistService.updateClinicDetails(uid, {
      "consultationTypes": types,
      "clinicName": clinicNameController.text.trim(),
      "address": addressController.text.trim(),
      "city": cityController.text.trim(),
      "inClinicFee": inClinic
          ? (inClinicFee == "Custom"
          ? inClinicCustomController.text.trim()
          : inClinicFee ?? "")
          : "",
      "onlineFee": online
          ? (onlineFee == "Custom"
          ? onlineCustomController.text.trim()
          : onlineFee ?? "")
          : "",
      "clinicImages": clinicImageUrls,
      "location": clinicLocation == null
          ? null
          : {
        "lat": clinicLocation!.latitude,
        "lng": clinicLocation!.longitude,
      },
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Clinic details updated")),
    );
  }
  Widget _imageBox(Widget child) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.text(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
  @override
  void dispose() {
    _debounce?.cancel();
    addressController.dispose();
    cityController.dispose();
    clinicNameController.dispose();
    inClinicCustomController.dispose();
    onlineCustomController.dispose();
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
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text("Clinic Details"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      bottomNavigationBar: PsychologistBottomNav(
        selectedIndex: 4,
        onTap: (_) {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Consultation Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text("In-Clinic"),
              value: inClinic,
              onChanged: (v) => setState(() => inClinic = v ?? false),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text("Online"),
              value: online,
              onChanged: (v) => setState(() => online = v ?? false),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: clinicNameController,
              decoration: field("Clinic Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              decoration: field("Address"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: cityController,
              decoration: field("City"),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Google Map Preview",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: clinicLocation == null
                  ? const Center(child: Text("Enter address to locate"))
                  : FlutterMap(
                options: MapOptions(
                  initialCenter: clinicLocation!,
                  initialZoom: 15,
                  onTap: (tapPosition, point) {
                    setState(() {
                      clinicLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.fjwu.fyp',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: clinicLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: openDirections,
                  icon:  Icon(Icons.directions, color: Theme.of(context).cardColor),
                  label:  Text(
                    "Directions",
                    style: TextStyle(color: Theme.of(context).cardColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Consultation Fee",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (online) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Online Fee",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: onlineFee,
                decoration: field("Select Fee"),
                items: feeOptions
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => onlineFee = v),
              ),
              const SizedBox(height: 12),
            ],

            if (inClinic) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("In-Clinic Fee",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: inClinicFee,
                decoration: field("Select Fee"),
                items: feeOptions
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => inClinicFee = v),
              ),
            ],
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Clinic Images",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...clinicImageUrls.map((url) => _imageBox(Image.network(url, fit: BoxFit.cover))),
                  ...newImages.map((f) => _imageBox(Image.file(f, fit: BoxFit.cover))),
                ],
              ),
            ),

            const SizedBox(height: 10),


            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: pickClinicImages,
                icon:  Icon(Icons.upload, color: Theme.of(context).cardColor),
                label:  Text("Upload More",
                    style: TextStyle(color: Theme.of(context).cardColor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? CircularProgressIndicator(color: Theme.of(context).cardColor)
                    : const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}