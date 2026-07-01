class AssessmentScoringService {
  static Map<String, dynamic> scoreAssessment({
    required String assessmentCode,
    required List<int> answers,
  }) {
    switch (assessmentCode) {
      case 'bdi':
        return _scoreBdi(answers);
      case 'stress':
        return _scoreStressChecklist(answers);
      case 'anxiety':
        return _scoreBai(answers);
      case 'wellbeing':
        return _scoreBbcWellbeing(answers);
      case 'ptsd':
        return _scorePclc(answers);
      case 'ocd':
        return _scoreOcd(answers);
      case 'adhd':
        return _scoreAdhd(answers);
      case 'suicide_intent':
        return _scoreSuicideIntent(answers);
      case 'self_esteem':
        return _scoreSelfEsteem(answers);
      case 'insomnia':
        return _scoreInsomnia(answers);
      default:
        throw Exception('Scoring not implemented for $assessmentCode');
    }
  }

  static Map<String, dynamic> _scoreBdi(List<int> answers) {
    final total = answers.fold<int>(0, (sum, item) => sum + item);

    String severity;

    if (total <= 10) {
      severity = 'Normal ups and downs';
    } else if (total <= 16) {
      severity = 'Mild mood disturbance';
    } else if (total <= 20) {
      severity = 'Borderline clinical depression';
    } else if (total <= 30) {
      severity = 'Moderate depression';
    } else if (total <= 40) {
      severity = 'Severe depression';
    } else {
      severity = 'Extreme depression';
    }

    final suicidalRiskFlag = answers.length >= 9 && answers[8] >= 1;

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": suicidalRiskFlag,
    };
  }

  static Map<String, dynamic> _scoreStressChecklist(List<int> answers) {
    // UI stores 0..4, but checklist scoring is 1..5
    final subtotal = answers.fold<int>(0, (sum, item) => sum + (item + 1));
    final total = subtotal - 20;

    String severity;

    if (total <= 5) {
      severity = 'Low vulnerability to stress';
    } else if (total <= 24) {
      severity = 'Vulnerable to stress';
    } else if (total <= 55) {
      severity = 'Seriously vulnerable to stress';
    } else {
      severity = 'Extremely vulnerable to stress';
    }

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": false,
    };
  }
  static Map<String, dynamic> _scoreBai(List<int> answers) {
    final total = answers.fold<int>(0, (sum, item) => sum + item);

    String severity;
    if (total <= 21) {
      severity = 'Low anxiety';
    } else if (total <= 35) {
      severity = 'Moderate anxiety';
    } else {
      severity = 'Potentially concerning levels of anxiety';
    }

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": false,
    };
  }
  static Map<String, dynamic> _scoreBbcWellbeing(List<int> answers) {
    int toNormalScore(int indexValue) => indexValue + 1;

    int toReverseScore(int indexValue) {
      const reverseMap = [5, 4, 3, 2, 1];
      return reverseMap[indexValue];
    }

    int totalScore = 0;
    int psychologicalScore = 0;
    int physicalScore = 0;
    int relationshipScore = 0;

    for (int i = 0; i < answers.length; i++) {
      final answerIndex = answers[i];

      int itemScore;
      if (i == 3) {
        // item 4 reversed
        itemScore = toReverseScore(answerIndex);
      } else {
        itemScore = toNormalScore(answerIndex);
      }

      totalScore += itemScore;

      // Physical: 1,2,3,21,22,23,24
      if ([0, 1, 2, 20, 21, 22, 23].contains(i)) {
        physicalScore += itemScore;
      }

      // Psychological: 4,5,6,7,8,9,10,11,12,13,14,15
      if ([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14].contains(i)) {
        psychologicalScore += itemScore;
      }

      // Relationships: 16,17,18,19,20
      if ([15, 16, 17, 18, 19].contains(i)) {
        relationshipScore += itemScore;
      }
    }
    String severity;

    if (totalScore <= 60) {
      severity = "Low wellbeing";
    } else if (totalScore <= 90) {
      severity = "Moderate wellbeing";
    } else {
      severity = "High wellbeing";
    }
    return {
      "score": totalScore,
      "severity": severity,
      "suicidalRiskFlag": false,
      "psychologicalScore": psychologicalScore,
      "physicalScore": physicalScore,
      "relationshipScore": relationshipScore,
    };
  }
  static Map<String, dynamic> _scorePclc(List<int> answers) {
    // UI stores answers as 0..4
    // PCL-C scoring uses 1..5
    final converted = answers.map((e) => e + 1).toList();

    final totalScore = converted.fold<int>(0, (sum, item) => sum + item);

    // Symptomatic = response 3–5 => UI index 2–4 => converted score >= 3
    bool isSymptomatic(int score) => score >= 3;

    // B items: 1–5 => indices 0..4
    final bCount = converted.sublist(0, 5).where(isSymptomatic).length;

    // C items: 6–12 => indices 5..11
    final cCount = converted.sublist(5, 12).where(isSymptomatic).length;

    // D items: 13–17 => indices 12..16
    final dCount = converted.sublist(12, 17).where(isSymptomatic).length;

    final probablePtsd = bCount >= 1 && cCount >= 3 && dCount >= 2;

    return {
      "score": totalScore,
      "severity": probablePtsd
          ? "Probable PTSD screen positive"
          : "PTSD screen negative by DSM-IV symptom rule",
      "suicidalRiskFlag": false,
      "probablePtsd": probablePtsd,
      "bClusterCount": bCount,
      "cClusterCount": cCount,
      "dClusterCount": dCount,
    };
  }
  static Map<String, dynamic> _scoreOcd(List<int> answers) {

    // UI saves answers 0..4
    final converted = answers.map((e) => e + 1).toList();

    final total = converted.fold<int>(0, (sum, item) => sum + item);

    String severity;

    if (total < 8) {
      severity = "Minimal OCD symptoms";
    } else if (total <= 15) {
      severity = "Mild OCD";
    } else if (total <= 23) {
      severity = "Moderate OCD";
    } else if (total <= 31) {
      severity = "Severe OCD";
    } else {
      severity = "Extreme OCD";
    }

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": false,
    };
  }
  static Map<String, dynamic> _scoreAdhd(List<int> answers) {

    int screenerCount = 0;

    for (int i = 0; i < 6; i++) {
      if (answers[i] >= 3) {
        screenerCount++;
      }
    }

    bool adhdLikely = screenerCount >= 4;

    return {
      "score": screenerCount,
      "severity": adhdLikely
          ? "Symptoms highly consistent with Adult ADHD"
          : "ADHD symptoms below screening threshold",
      "suicidalRiskFlag": false,
      "adhdLikely": adhdLikely,
    };
  }
  static Map<String, dynamic> _scoreSuicideIntent(List<int> answers) {

    final total = answers.fold<int>(0, (sum, item) => sum + item);

    String severity;
    String recommendation;

    if (total <= 10) {
      severity = "Low Suicide Risk";
      recommendation =
      "May be sent home with advice to follow up with GP or Community Mental Health Team.";
    }
    else if (total <= 20) {
      severity = "Medium Suicide Risk";
      recommendation =
      "Assessment by Community Mental Health Team or Psychiatrist recommended.";
    }
    else {
      severity = "High Suicide Risk";
      recommendation =
      "Immediate psychiatric evaluation recommended.";
    }

    return {
      "score": total,
      "severity": severity,
      "recommendation": recommendation,
      "suicidalRiskFlag": total >= 11,
    };
  }
  static Map<String, dynamic> _scoreSelfEsteem(List<int> answers) {

    int total = 0;

    for (int i = 0; i < answers.length; i++) {

      int score;

      if ([1,4,5,7,8].contains(i)) {
        score = 3 - answers[i];
      } else {
        score = answers[i];
      }

      total += score;
    }

    String severity;

    if (total >= 25) {
      severity = "High self esteem";
    } else if (total >= 15) {
      severity = "Normal self esteem";
    } else {
      severity = "Low self esteem";
    }

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": false,
    };
  }
  static Map<String, dynamic> _scoreInsomnia(List<int> answers) {

    final total = answers.fold<int>(0, (sum, item) => sum + item);

    String severity;

    if (total <= 7) {
      severity = "No clinically significant insomnia";
    }
    else if (total <= 14) {
      severity = "Subthreshold insomnia";
    }
    else if (total <= 21) {
      severity = "Clinical insomnia (moderate)";
    }
    else {
      severity = "Clinical insomnia (severe)";
    }

    return {
      "score": total,
      "severity": severity,
      "suicidalRiskFlag": false,
    };
  }





}