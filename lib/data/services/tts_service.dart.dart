import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;

  late FlutterTts _tts;

  TTSService._internal() {
    _tts = FlutterTts();
  }

  Future<void> speak(String text, bool isUrdu) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(isUrdu ? "ur-PK" : "en-US");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}