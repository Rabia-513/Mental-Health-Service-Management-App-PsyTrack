import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MoodModelService {
  MoodModelService._();
  static final MoodModelService instance = MoodModelService._();

  Interpreter? _interpreter;
  List<String> _moodClasses = [];
  List<String> _activityClasses = [];
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;

    _interpreter = await Interpreter.fromAsset('assets/models/mood_model.tflite');

    final moodJson =
    await rootBundle.loadString('assets/models/mood_classes.json');
    final activityJson =
    await rootBundle.loadString('assets/models/activity_classes.json');

    _moodClasses = List<String>.from(jsonDecode(moodJson));
    _activityClasses = List<String>.from(jsonDecode(activityJson));

    _isLoaded = true;
  }

  String _normalizeMoodKey(String moodKey) {
    switch (moodKey) {
      case 'very_happy':
        return 'very happy';
      default:
        return moodKey.toLowerCase().trim();
    }
  }

  List<List<double>> _buildInput(String moodKey) {
    final normalizedMood = _normalizeMoodKey(moodKey);

    final input = List<double>.filled(_moodClasses.length, 0.0);
    final moodIndex = _moodClasses.indexOf(normalizedMood);

    if (moodIndex == -1) {
      throw Exception(
        'Mood "$moodKey" not found in mood_classes.json. '
            'Available moods: $_moodClasses',
      );
    }

    input[moodIndex] = 1.0;
    return [input];
  }

  Future<List<String>> predictTop4Recommendations(String moodKey) async {
    await load();

    final interpreter = _interpreter;
    if (interpreter == null) {
      throw Exception('Mood model not loaded');
    }

    final input = _buildInput(moodKey);

    final output = [
      List<double>.filled(_activityClasses.length, 0.0),
    ];

    interpreter.run(input, output);

    final scores = output.first;

    final ranked = List.generate(
      scores.length,
          (index) => {
        'index': index,
        'label': _activityClasses[index],
        'score': scores[index],
      },
    );

    ranked.sort(
          (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    final top4 = <String>[];
    final seen = <String>{};

    for (final item in ranked) {
      final label = (item['label'] as String).trim();
      if (label.isEmpty) continue;

      if (!seen.contains(label)) {
        seen.add(label);
        top4.add(label);
      }

      if (top4.length == 4) break;
    }

    return top4;
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }

  List<String> get moodClasses => List.unmodifiable(_moodClasses);
  List<String> get activityClasses => List.unmodifiable(_activityClasses);
}