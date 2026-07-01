import 'package:flutter/material.dart';
import 'record_model.dart';

class RecordCard extends StatelessWidget {
  final PatientRecord record;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const RecordCard({
    super.key,
    required this.record,
    required this.onView,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE7F0EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Patient row
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xffB7D3CF),
                child: Icon(Icons.person, color: Color(0xff3E6F6C)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff3E6F6C),
                      ),
                    ),
                    Text(
                      record.sessionType,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),

              Text(
                record.date,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),

          const SizedBox(height: 12),

          /// Diagnosis
          Text(
            "Diagnosis: ${record.diagnosis}",
            style: const TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 6),

          /// Prescription
          Text(
            "Prescription: ${record.prescription}",
            style: const TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 12),

          /// Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _btn("View", onView),
              _btn("Download", onDownload),
              _btn("Share", onShare),
            ],
          )
        ],
      ),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff4E7D7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(text),
    );
  }
}