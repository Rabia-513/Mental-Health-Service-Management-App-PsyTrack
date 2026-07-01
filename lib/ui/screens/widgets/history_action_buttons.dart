import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';

class HistoryActionButtons extends StatelessWidget {

  final VoidCallback onSaveDraft;
  final VoidCallback onContinue;
  final bool disableContinue;
  final bool isUrdu;   // 👈 ADD THIS


  const HistoryActionButtons({
    super.key,
    required this.onSaveDraft,
    required this.onContinue,
    this.disableContinue = false,
    required this.isUrdu,  // 👈 REQUIRED

  });

  String tr(String en, String ur) {
    return isUrdu ? ur : en;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(   // 👈 IMPORTANT FOR RTL BUTTON ORDER
        textDirection:
        isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // SAVE DRAFT
          Expanded(
            child: OutlinedButton(
              onPressed: onSaveDraft,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                tr("Save Draft", "مسودہ محفوظ کریں"),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // CONTINUE
          Expanded(
            child: ElevatedButton(
              onPressed: disableContinue ? null : onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                tr("Continue", "آگے بڑھیں"),
                style:  TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
        )
    );
  }
}
