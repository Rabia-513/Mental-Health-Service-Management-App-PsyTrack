import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/services/psychologist_service.dart';
import '../../styles/colors.dart';

class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  State<ContactDetailsScreen> createState() =>
      _ContactDetailsScreenState();
}

class _ContactDetailsScreenState
    extends State<ContactDetailsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  bool isSaving = false;

  List<String> phoneNumbers = [];
  List<String> whatsappNumbers = [];

  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();

  bool showPhone = true;
  bool allowMessages = false;
  bool enableWhatsapp = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await PsychologistService.fetchContact(uid);

    if (data != null) {
      final rootPhone = data['phone'];
      final rootEmail = data['email'];

      final contact =
      Map<String, dynamic>.from(data['contactDetails'] ?? {});

      phoneNumbers =
      List<String>.from(contact['phoneNumbers'] ?? []);

      if (phoneNumbers.isEmpty && rootPhone != null) {
        phoneNumbers.add(rootPhone);
      }

      whatsappNumbers =
      List<String>.from(contact['whatsappNumbers'] ?? []);

      emailController.text =
          contact['email'] ?? rootEmail ?? "";

      showPhone = contact['showPhone'] ?? true;
      allowMessages = contact['allowInAppMessages'] ?? false;

      if (whatsappNumbers.isNotEmpty) enableWhatsapp = true;
    }

    setState(() => isLoading = false);
  }

  Future<void> saveData() async {
    setState(() => isSaving = true);

    await PsychologistService.updateContact(uid, {
      "phoneNumbers": phoneNumbers,
      "whatsappNumbers":
      enableWhatsapp ? whatsappNumbers : [],
      "email": emailController.text.trim(),
      "showPhone": showPhone,
      "allowInAppMessages": allowMessages,
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact updated")),
    );
  }

  InputDecoration field(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget numberField(String number, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: number),
              readOnly: true,
              decoration: field("Phone"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text("Contact Details"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PHONE =================
            const Text(
              "Phone Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),

            ...phoneNumbers.map((n) =>
                numberField(n, () {
                  setState(() => phoneNumbers.remove(n));
                })),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: field("Add Another Number"),
            ),
            ElevatedButton(
              onPressed: () {
                if (phoneController.text.isEmpty) return;
                setState(() {
                  phoneNumbers.add(phoneController.text.trim());
                  phoneController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child:  Text("Add",style: TextStyle(color: Theme.of(context).cardColor),),
            ),

            const SizedBox(height: 20),

            // ================= WHATSAPP =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("WhatsApp Number"),
                Switch(
                  value: enableWhatsapp,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => enableWhatsapp = v);
                  },
                )
              ],
            ),

            if (enableWhatsapp) ...[
              ...whatsappNumbers.map((n) =>
                  numberField(n, () {
                    setState(() => whatsappNumbers.remove(n));
                  })),

              TextField(
                controller: whatsappController,
                keyboardType: TextInputType.phone,
                decoration: field("Add WhatsApp Number"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (whatsappController.text.isEmpty) return;
                  setState(() {
                    whatsappNumbers
                        .add(whatsappController.text.trim());
                    whatsappController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child:  Text("Add",style: TextStyle(color: Theme.of(context).cardColor)),
              ),
            ],

            const SizedBox(height: 20),

            // ================= EMAIL =================
            const Text("Email"),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              decoration: field("Email"),
            ),

            const SizedBox(height: 20),

            // ================= VISIBILITY =================
            const Text(
              "Visibility Controls",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),

            SwitchListTile(
              value: showPhone,
              activeColor: AppColors.primary,
              title: const Text("Show phone number to patients"),
              onChanged: (v) {
                setState(() => showPhone = v);
              },
            ),

            SwitchListTile(
              value: allowMessages,
              activeColor: AppColors.primary,
              title: const Text("Allow in-app messages"),
              onChanged: (v) {
                setState(() => allowMessages = v);
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveData,
                icon:  Icon(Icons.save_alt,
                    color: Theme.of(context).cardColor),
                label: isSaving
                    ?  CircularProgressIndicator(
                  color: Theme.of(context).cardColor,
                  strokeWidth: 2,
                )
                    :  Text(
                  "Save Changes",
                  style:
                  TextStyle(color: Theme.of(context).cardColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
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