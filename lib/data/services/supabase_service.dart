import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<String> uploadHistoryPdf({
    required Uint8List pdfBytes,
    required String patientUid,
    required String psychologistUid,
    required String historyId,
  }) async {
    try {
      final path = '$patientUid/$psychologistUid/$historyId.pdf';

      await supabase.storage
          .from('history_reports')
          .uploadBinary(
        path,
        pdfBytes,
        fileOptions: const FileOptions(
          contentType: 'application/pdf',
          upsert: true,
        ),
      );

      return supabase.storage
          .from('history_reports')
          .getPublicUrl(path);
    } catch (e) {
      throw Exception("Supabase upload failed: $e");
    }
  }


}
