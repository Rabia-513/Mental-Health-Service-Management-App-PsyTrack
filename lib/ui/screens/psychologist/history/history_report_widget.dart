import 'package:flutter/material.dart';

import '../../styles/colors.dart';

class HistoryReportWidget extends StatelessWidget {
  final Map<String, dynamic> allStepsData;
  final String language;

  const HistoryReportWidget({
    super.key,
    required this.allStepsData,
    required this.language,
  });

  bool get isUrdu => language == "urdu";

  String _prettyKey(String key) {
    // camelCase -> words
    final spaced = key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => "${m[1]} ${m[2]}");
    return spaced;
  }

  String translateKey(String key) {
    if (!isUrdu) return _prettyKey(key);

    const map = {
      "mother": "والدہ",
      "father": "والد",
      "marital": "ازدواجی حیثیت",
      "maritalStatus": "ازدواجی حیثیت",
      "siblings": "بہن بھائی",
      "income": "آمدنی",
      "education": "تعلیم",
      "occupation": "پیشہ",
      "relationship": "رشتہ",
      "temperament": "مزاج",
      "religion": "مذہب",
      "name": "نام",
      "age": "عمر",
      "gender": "جنس",
      "presentDx": "موجودہ مسئلہ",
      "previousDx": "سابقہ تشخیص",
      "address": "پتہ",
      "hospital": "ہسپتال",
      "informant": "معلومات فراہم کرنے والا",
      "referralSource": "ریفرل کا ذریعہ",
      "birthOrder": "پیدائشی ترتیب",
      "caseNo": "کیس نمبر",
      "date": "تاریخ",
    };

    return map[key] ?? _prettyKey(key);
  }

  Widget _answerWidget(dynamic value) {
    if (value == null) return const Text("");

    // If Map -> show key:value lines
    if (value is Map) {
      final entries = value.entries.map((e) => "${translateKey(e.key.toString())}: ${e.value}").toList();
      return Text(entries.join("\n"), softWrap: true);
    }

    // If List -> bullets
    if (value is List) {
      final items = value.map((e) => "• $e").join("\n");
      return Text(items, softWrap: true);
    }

    // default
    return Text(value.toString(), softWrap: true);
  }

  @override
  Widget build(BuildContext context) {
    final steps = allStepsData.entries
        .where((step) => step.key.toString().startsWith("step") && step.value is Map && (step.value as Map).isNotEmpty)
        .toList();

    steps.sort((a, b) {
      final aNum = int.tryParse(a.key.toString().replaceAll("step", "")) ?? 0;
      final bNum = int.tryParse(b.key.toString().replaceAll("step", "")) ?? 0;
      return aNum.compareTo(bNum);
    });

    return Directionality(
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: AppColors.card(context),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUrdu ? "کیس ہسٹری رپورٹ" : "CASE HISTORY REPORT",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            ...steps.map((step) {
              final fields = (step.value as Map<String, dynamic>).entries.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade300,
                    child: Text(
                      step.key.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              translateKey(field.key),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: AppColors.text(context)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 13, height: 1.25),
                                child: _answerWidget(field.value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 14),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}