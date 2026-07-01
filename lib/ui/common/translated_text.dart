import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../app/translations.dart';
import '../../app/translator.dart';


class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    if (!Translations.isUrdu) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: TextTranslator.translate(text),
      builder: (context, snapshot) {
        final translated = snapshot.data ?? text;

        return Text(
          translated,
          style: style,
          textAlign: textAlign ?? TextAlign.right,
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}