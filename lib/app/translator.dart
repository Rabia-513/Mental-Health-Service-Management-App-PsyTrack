import 'package:translator/translator.dart';

class TextTranslator {

  static final translator = GoogleTranslator();

  static Future<String> translate(String text) async {

    final translated = await translator.translate(
      text,
      from: 'en',
      to: 'ur',
    );

    return translated.text;
  }
}