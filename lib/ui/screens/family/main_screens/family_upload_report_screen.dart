import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/translations.dart';
import '../../../common/family_bottom_nav.dart';

class FamilyUploadReportScreen extends StatefulWidget {
  final String patientUid;

  const FamilyUploadReportScreen({
    super.key,
    required this.patientUid,
  });

  @override
  State<FamilyUploadReportScreen> createState() =>
      _FamilyUploadReportScreenState();
}

class _FamilyUploadReportScreenState extends State<FamilyUploadReportScreen> {
  File? selectedFile;
  String? fileName;
  bool isUploading = false;
  late String patientUid;
  final TextEditingController reportNameController = TextEditingController();
  final isUrdu = Translations.isUrdu;
  String selectedType = "Blood Test";

  final List<String> reportTypes = const [
    "Blood Test",
    "Lab Report",
    "X-Ray",
    "MRI",
    "Other",
  ];

  @override
  void dispose() {
    reportNameController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final picked = result.files.single;

      // 10 MB limit
      if (picked.size > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File size must be less than 10 MB")),
        );
        return;
      }

      setState(() {
        selectedFile = File(picked.path!);
        fileName = picked.name;
      });
    }
  }

  String _extensionFromFileName(String name) {
    final parts = name.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'pdf';
  }

  Future<String?> uploadToSupabase(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final ext = _extensionFromFileName(fileName ?? file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final storagePath =
          "reports/${widget.patientUid}/$timestamp.$ext";

      await supabase.storage.from('reports').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl =
      supabase.storage.from('reports').getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      return null;
    }
  }

  Future<void> saveReport({
    required String fileUrl,
    required Map<String, dynamic> patientData,
  }) async {
    final familyUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("reports").add({
      "patientUid": widget.patientUid,
      "familyUid": familyUid,
      "reportName": reportNameController.text.trim(),
      "reportType": selectedType,
      "fileUrl": fileUrl,
      "fileName": fileName ?? "",
      "uploadedBy": "family",
      "patientName":
      "${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}"
          .trim(),
      "patientCode": patientData['patientCode'] ?? "",
      "profileImageUrl": patientData['profileImageUrl'] ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadReport(Map<String, dynamic> patientData) async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(isUrdu ? "براہ کرم فائل منتخب کریں" : "Please select a file")),
      );
      return;
    }

    if (reportNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu ? "براہ کرم رپورٹ کا نام درج کریں" : "Please enter report name")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final url = await uploadToSupabase(selectedFile!);

      if (url == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isUrdu ? "فائل اپ لوڈ ناکام ہو گیا" : "File upload failed")),
        );
        setState(() => isUploading = false);
        return;
      }

      await saveReport(fileUrl: url, patientData: patientData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu ? "رپورٹ کامیابی سے اپ لوڈ ہو گئی" : "Report uploaded successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Upload report error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUrdu ? "کچھ غلط ہو گیا" : "Something went wrong")),
      );
      setState(() => isUploading = false);
    }
  }

  int _calculateAge(dynamic dob) {
    if (dob == null) return 0;

    DateTime birthDate;

    if (dob is Timestamp) {
      birthDate = dob.toDate();
    } else if (dob is DateTime) {
      birthDate = dob;
    } else {
      return 0;
    }

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Widget _searchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26),
      ),
      child:  TextField(
        decoration: InputDecoration(
          hintText: isUrdu ? "رپورٹ تلاش کریں..." : "Search Report...",
          hintStyle: TextStyle(fontSize: 12),
          prefixIcon: Icon(Icons.search, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _patientCard(Map<String, dynamic> p) {
    final String fullName =
    "${p['firstName'] ?? ''} ${p['lastName'] ?? ''}".trim();
    final String imageUrl = (p['profileImageUrl'] ?? "").toString();
    final String patientCode = (p['patientCode'] ?? "").toString();
    final int age = _calculateAge(p['dob']);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffDDF3F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xffCBE7E2),
                backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person,
                    size: 30, color: Color(0xff5E9E97))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? "Patient" : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff2B5D5A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${isUrdu ? "عمر" : "Age"}: $age",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff6B8E8A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${isUrdu ? "مریض آئی ڈی" : "Patient ID"}: $patientCode",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff6B8E8A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                "assets/images/freport.png",
                height: 46,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.assignment_add,
                  size: 40,
                  color: Color(0xff5E9E97),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffCFEAE5),
            borderRadius: BorderRadius.circular(12),
          ),
          child:Center(
            child: Text(
    isUrdu ? "ڈاکٹر کی دی گئی رپورٹس شامل کریں" : "Add Reports assigned by Doctor",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xff477A76),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xffF4FBFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffA8D9D3),
          width: 1.3,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/icons/docs.png",
            height: 58,
            width: 58,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
            const Icon(
              Icons.description_outlined,
              size: 52,
              color: Color(0xff4E7D7A),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
            isUrdu ? "رپورٹ اپ لوڈ کرنے کے لیے دبائیں" : "Tap to upload report",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xff356A66),
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  isUrdu ? "PDF / JPG / PNG (زیادہ سے زیادہ 10MB)" : "PDF / JPG / PNG (Max 10MB)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff7C9B98),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: pickFile,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xff5B8E89),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    icon: const Icon(Icons.upload_file,
                        size: 16, color: Colors.white),
                    label:  Text(
                        isUrdu ? "فائل اپ لوڈ کریں" : "Upload File",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
                if (fileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    fileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff356A66),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTypeChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: reportTypes.map((type) {
        final bool isSelected = selectedType == type;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              selectedType = type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xff4E7D7A)
                  : const Color(0xffEAF6F6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff8DBDB8),
              ),
            ),
            child: Text(
              isUrdu
                  ? {
                "Blood Test": "بلڈ ٹیسٹ",
                "Lab Report": "لیب رپورٹ",
                "X-Ray": "ایکس رے",
                "MRI": "ایم آر آئی",
                "Other": "دیگر",
              }[type] ?? type
                  : type,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xff4E7D7A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _reportTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        controller: reportNameController,
        decoration:  InputDecoration(
         hintText: isUrdu ? "رپورٹ کا نام لکھیں" : "Enter report name",
          hintStyle: TextStyle(fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _uploadButton(Map<String, dynamic> patientData) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: isUploading ? null : () => uploadReport(patientData),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xff4E7D7A),
          disabledBackgroundColor: const Color(0xff91B7B4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: isUploading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            :  Text(
          isUrdu ? "رپورٹ اپ لوڈ کریں" : "Upload Report",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _securityText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffDCEAEA)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              isUrdu
                  ? "آپ کی معلومات محفوظ اور خفیہ ہیں"
                  : "Your information is safe and confidential",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xff7A9090),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
      backgroundColor: const Color(0xffEEF8F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffEEF8F7),
        foregroundColor: const Color(0xff3E706D),
        titleSpacing: 0,
        title: Text(
            isUrdu ? "رپورٹ اپ لوڈ کریں" : "Upload Report",
          style: TextStyle(
            color: Color(0xff3E706D),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("patients")
            .doc(widget.patientUid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Patient not found"),
            );
          }

          final patient = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchBar(),
                const SizedBox(height: 14),
                _patientCard(patient),
                const SizedBox(height: 14),
                _uploadBox(),
                const SizedBox(height: 16),
                 Text(
                  isUrdu ? "رپورٹ کی قسم منتخب کریں" : "Select Report Type",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xff4A6B68),
                  ),
                ),
                const SizedBox(height: 8),
                _reportTypeChips(),
                const SizedBox(height: 16),
                Text(
                  isUrdu ? "رپورٹ کا عنوان" : "Report Title",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xff4A6B68),
                  ),
                ),
                const SizedBox(height: 8),
                _reportTitleField(),
                const SizedBox(height: 22),
                _uploadButton(patient),
                const SizedBox(height: 18),
                _securityText(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FamilyBottomNav(
        selectedIndex: 1,
      ),   ) );
  }
}