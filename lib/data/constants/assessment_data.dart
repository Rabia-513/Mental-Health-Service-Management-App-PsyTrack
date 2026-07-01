class AssessmentCategory {
  final String code;
  final String title;
  final String subtitle;
  final bool enabled;

  const AssessmentCategory({
    required this.code,
    required this.title,
    required this.subtitle,
    this.enabled = true,
  });
}

class AssessmentQuestion {
  final int number;
  final String title;
  final List<String> options;

  const AssessmentQuestion({
    required this.number,
    required this.title,
    required this.options,
  });
}

const List<AssessmentCategory> assessmentCategories = [
  AssessmentCategory(
    code: 'bdi',
    title: 'Depression',
    subtitle: 'Beck Depression Inventory',
  ),
  AssessmentCategory(
    code: 'stress',
    title: 'Stress',
    subtitle: 'Perceived Stress Scale',
  ),
  AssessmentCategory(
    code: 'anxiety',
    title: 'Anxiety',
    subtitle: 'Generalized Anxiety Assessment',
  ),
  AssessmentCategory(
    code: 'wellbeing',
    title: 'Wellbeing',
    subtitle: 'Wellbeing Assessment',

  ),
  AssessmentCategory(
    code: 'ptsd',
    title: 'PTSD',
    subtitle: 'Trauma / PTSD Screening',

  ),
  AssessmentCategory(
    code: 'ocd',
    title: 'OCD',
    subtitle: 'Obsessive Compulsive Screening',

  ),
  AssessmentCategory(
    code: 'adhd',
    title: 'ADHD',
    subtitle: 'Attention Deficit Screening',
  ),
  AssessmentCategory(
    code: 'suicide_intent',
    title: 'Suicidal Risk',
    subtitle: 'Suicide Risk Assessment',
  ),
  AssessmentCategory(
    code: 'self_esteem',
    title: 'Self Esteem',
    subtitle: 'Rosenberg Self-Esteem Scale',

  ),
  AssessmentCategory(
    code: 'insomnia',
    title: 'Insomnia',
    subtitle: 'Insomnia Severity Index',

  ),
];

const List<AssessmentQuestion> beckDepressionQuestions = [
  AssessmentQuestion(
    number: 1,
    title: 'Sadness',
    options: [
      'I do not feel sad.',
      'I feel sad much of the time.',
      'I am sad all the time.',
      'I am so sad or unhappy that I can\'t stand it.',
    ],
  ),
  AssessmentQuestion(
    number: 2,
    title: 'Pessimism',
    options: [
      'I am not discouraged about my future.',
      'I feel more discouraged about my future than I used to.',
      'I do not expect things to work out for me.',
      'I feel my future is hopeless and will only get worse.',
    ],
  ),
  AssessmentQuestion(
    number: 3,
    title: 'Past Failure',
    options: [
      'I do not feel like a failure.',
      'I have failed more than I should have.',
      'As I look back, I see a lot of failures.',
      'I feel I am a total failure as a person.',
    ],
  ),
  AssessmentQuestion(
    number: 4,
    title: 'Loss of Pleasure',
    options: [
      'I get as much pleasure as I ever did from the things I enjoy.',
      'I don\'t enjoy things as much as I used to.',
      'I get very little pleasure from the things I used to enjoy.',
      'I can\'t get any pleasure from the things I used to enjoy.',
    ],
  ),
  AssessmentQuestion(
    number: 5,
    title: 'Guilty Feelings',
    options: [
      'I don\'t feel particularly guilty.',
      'I feel guilty over many things I have done or should have done.',
      'I feel quite guilty most of the time.',
      'I feel guilty all of the time.',
    ],
  ),
  AssessmentQuestion(
    number: 6,
    title: 'Punishment Feelings',
    options: [
      'I don\'t feel I am being punished.',
      'I feel I may be punished.',
      'I expect to be punished.',
      'I feel I am being punished.',
    ],
  ),
  AssessmentQuestion(
    number: 7,
    title: 'Self-Dislike',
    options: [
      'I feel the same about myself as ever.',
      'I have lost confidence in myself.',
      'I am disappointed in myself.',
      'I dislike myself.',
    ],
  ),
  AssessmentQuestion(
    number: 8,
    title: 'Self-Criticalness',
    options: [
      'I don\'t criticize or blame myself more than usual.',
      'I am more critical of myself than I used to be.',
      'I criticize myself for all of my faults.',
      'I blame myself for everything bad that happens.',
    ],
  ),
  AssessmentQuestion(
    number: 9,
    title: 'Suicidal Thoughts or Wishes',
    options: [
      'I don\'t have any thoughts of killing myself.',
      'I have thoughts of killing myself, but I would not carry them out.',
      'I would like to kill myself.',
      'I would kill myself if I had the chance.',
    ],
  ),
  AssessmentQuestion(
    number: 10,
    title: 'Crying',
    options: [
      'I don\'t cry anymore than I used to.',
      'I cry more than I used to.',
      'I cry over every little thing.',
      'I feel like crying, but I can\'t.',
    ],
  ),
  AssessmentQuestion(
    number: 11,
    title: 'Agitation',
    options: [
      'I am no more restless or wound up than usual.',
      'I feel more restless or wound up than usual.',
      'I am so restless or agitated, it\'s hard to stay still.',
      'I am so restless or agitated that I have to keep moving or doing something.',
    ],
  ),
  AssessmentQuestion(
    number: 12,
    title: 'Loss of Interest',
    options: [
      'I have not lost interest in other people or activities.',
      'I am less interested in other people or things than before.',
      'I have lost most of my interest in other people or things.',
      'It\'s hard to get interested in anything.',
    ],
  ),
  AssessmentQuestion(
    number: 13,
    title: 'Indecisiveness',
    options: [
      'I make decisions about as well as ever.',
      'I find it more difficult to make decisions than usual.',
      'I have much greater difficulty in making decisions than I used to.',
      'I have trouble making any decisions.',
    ],
  ),
  AssessmentQuestion(
    number: 14,
    title: 'Worthlessness',
    options: [
      'I do not feel I am worthless.',
      'I don\'t consider myself as worthwhile and useful as I used to.',
      'I feel more worthless as compared to others.',
      'I feel utterly worthless.',
    ],
  ),
  AssessmentQuestion(
    number: 15,
    title: 'Loss of Energy',
    options: [
      'I have as much energy as ever.',
      'I have less energy than I used to have.',
      'I don\'t have enough energy to do very much.',
      'I don\'t have enough energy to do anything.',
    ],
  ),
  AssessmentQuestion(
    number: 16,
    title: 'Changes in Sleeping Pattern',
    options: [
      'I have not experienced any change in my sleeping.',
      'I sleep somewhat more or somewhat less than usual.',
      'I sleep a lot more or a lot less than usual.',
      'I sleep most of the day or wake up early and can\'t get back to sleep.',
    ],
  ),
  AssessmentQuestion(
    number: 17,
    title: 'Irritability',
    options: [
      'I am not more irritable than usual.',
      'I am more irritable than usual.',
      'I am much more irritable than usual.',
      'I am irritable all the time.',
    ],
  ),
  AssessmentQuestion(
    number: 18,
    title: 'Changes in Appetite',
    options: [
      'I have not experienced any change in my appetite.',
      'My appetite is somewhat less or greater than usual.',
      'My appetite is much less or much greater than before.',
      'I have no appetite at all or crave food all the time.',
    ],
  ),
  AssessmentQuestion(
    number: 19,
    title: 'Concentration Difficulty',
    options: [
      'I can concentrate as well as ever.',
      'I can\'t concentrate as well as usual.',
      'It\'s hard to keep my mind on anything for very long.',
      'I find I can\'t concentrate on anything.',
    ],
  ),
  AssessmentQuestion(
    number: 20,
    title: 'Tiredness or Fatigue',
    options: [
      'I am no more tired or fatigued than usual.',
      'I get more tired or fatigued more easily than usual.',
      'I am too tired or fatigued to do a lot of the things I used to do.',
      'I am too tired or fatigued to do most of the things I used to do.',
    ],
  ),
  AssessmentQuestion(
    number: 21,
    title: 'Loss of Interest in Sex',
    options: [
      'I have not noticed any recent change in my interest in sex.',
      'I am less interested in sex than I used to be.',
      'I am much less interested in sex now.',
      'I have lost interest in sex completely.',
    ],
  ),
];

const List<AssessmentQuestion> stressChecklistQuestions = [
  AssessmentQuestion(
    number: 1,
    title: 'I eat at least one hot, balanced meal a day.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 2,
    title: 'I get 7-8 hours of sleep at least 4 nights per week.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 3,
    title: 'I give and receive affection regularly.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 4,
    title: 'I have at least one family member within 50 miles on whom I can rely.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 5,
    title: 'I exercise to the point of breaking a sweat at least twice per week.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 6,
    title: 'I smoke less than a half a pack of cigarettes a day.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 7,
    title: 'I take fewer than 5 alcoholic drinks a week.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 8,
    title: 'My weight is appropriate for my height.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 9,
    title: 'I have an income that meets my basic expenses.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 10,
    title: 'I get strength from my spiritual beliefs.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 11,
    title: 'I regularly attend club or social activities.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 12,
    title: 'I have a network of good friends and acquaintances.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 13,
    title: 'I have one or more friends to confide in about personal matters.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 14,
    title: 'I am in good health.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 15,
    title: 'I am able to speak openly about my feelings when angry or worried.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 16,
    title: 'I do something fun at least one time per week.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 17,
    title: 'I am able to talk with the people I live with about domestic issues.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 18,
    title: 'I am able to organize my time effectively.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 19,
    title: 'I take quiet/relaxation time for myself during the day.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
  AssessmentQuestion(
    number: 20,
    title: 'I drink fewer than 3 cups of caffeinated drinks per day.',
    options: ['Almost always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
  ),
];


const List<String> anxietyOptions = [
  'Not at all',
  'Mildly, but it didn’t bother me much',
  'Moderately – it wasn’t pleasant at times',
  'Severely – it bothered me a lot',
];

const List<AssessmentQuestion> beckAnxietyQuestions = [
  AssessmentQuestion(number: 1, title: 'Numbness or tingling', options: anxietyOptions),
  AssessmentQuestion(number: 2, title: 'Feeling hot', options: anxietyOptions),
  AssessmentQuestion(number: 3, title: 'Wobbliness in legs', options: anxietyOptions),
  AssessmentQuestion(number: 4, title: 'Unable to relax', options: anxietyOptions),
  AssessmentQuestion(number: 5, title: 'Fear of worst happening', options: anxietyOptions),
  AssessmentQuestion(number: 6, title: 'Dizzy or lightheaded', options: anxietyOptions),
  AssessmentQuestion(number: 7, title: 'Heart pounding / racing', options: anxietyOptions),
  AssessmentQuestion(number: 8, title: 'Unsteady', options: anxietyOptions),
  AssessmentQuestion(number: 9, title: 'Terrified or afraid', options: anxietyOptions),
  AssessmentQuestion(number: 10, title: 'Nervous', options: anxietyOptions),
  AssessmentQuestion(number: 11, title: 'Feeling of choking', options: anxietyOptions),
  AssessmentQuestion(number: 12, title: 'Hands trembling', options: anxietyOptions),
  AssessmentQuestion(number: 13, title: 'Shaky / unsteady', options: anxietyOptions),
  AssessmentQuestion(number: 14, title: 'Fear of losing control', options: anxietyOptions),
  AssessmentQuestion(number: 15, title: 'Difficulty in breathing', options: anxietyOptions),
  AssessmentQuestion(number: 16, title: 'Fear of dying', options: anxietyOptions),
  AssessmentQuestion(number: 17, title: 'Scared', options: anxietyOptions),
  AssessmentQuestion(number: 18, title: 'Indigestion', options: anxietyOptions),
  AssessmentQuestion(number: 19, title: 'Faint / lightheaded', options: anxietyOptions),
  AssessmentQuestion(number: 20, title: 'Face flushed', options: anxietyOptions),
  AssessmentQuestion(number: 21, title: 'Hot / cold sweats', options: anxietyOptions),
];

const List<String> wellbeingOptions = [
  'Not at all',
  'A little',
  'Moderately',
  'Very much',
  'Extremely',
];

const List<AssessmentQuestion> bbcWellbeingQuestions = [
  AssessmentQuestion(
    number: 1,
    title: 'Are you happy with your physical health',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 2,
    title: 'Are you happy with the quality of your sleep',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 3,
    title: 'Are you happy with your ability to perform daily living activities',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 4,
    title: 'Do you feel depressed or anxious',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 5,
    title: 'Do you feel able to enjoy life',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 6,
    title: 'Do you feel you have a purpose in life',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 7,
    title: 'Do you feel optimistic about the future',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 8,
    title: 'Do you feel in control of your life',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 9,
    title: 'Do you feel happy with yourself as a person',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 10,
    title: 'Are you happy with your looks and appearance',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 11,
    title: 'Do you feel able to live your life the way you want',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 12,
    title: 'Are you confident in your own opinions and beliefs',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 13,
    title: 'Do you feel able to do the things you choose to do',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 14,
    title: 'Do you feel able to grow and develop as a person',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 15,
    title: 'Are you happy with yourself and your achievements',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 16,
    title: 'Are you happy with your personal and family life',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 17,
    title: 'Are you happy with your friendships and personal relationships',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 18,
    title: 'Are you comfortable about the way you relate/connect with others',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 19,
    title: 'Are you happy with your sex life',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 20,
    title: 'Are you able to ask someone for help with a problem',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 21,
    title: 'Are you happy that you have enough money to meet your needs',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 22,
    title: 'Are you happy with your opportunity for exercise/leisure',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 23,
    title: 'Are you happy with access to health services',
    options: wellbeingOptions,
  ),
  AssessmentQuestion(
    number: 24,
    title: 'Are you happy with your ability to work',
    options: wellbeingOptions,
  ),
];

const List<String> ptsdOptions = [
  'Not at all',
  'A little bit',
  'Moderately',
  'Quite a bit',
  'Extremely',
];

const List<AssessmentQuestion> pclcQuestions = [
  AssessmentQuestion(
    number: 1,
    title: 'Repeated, disturbing memories, thoughts, or images of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 2,
    title: 'Repeated, disturbing dreams of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 3,
    title: 'Suddenly acting or feeling as if a stressful experience were happening again (as if you were reliving it)?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 4,
    title: 'Feeling very upset when something reminded you of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 5,
    title: 'Having physical reactions (e.g., heart pounding, trouble breathing, or sweating) when something reminded you of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 6,
    title: 'Avoid thinking about or talking about a stressful experience from the past or avoid having feelings related to it?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 7,
    title: 'Avoid activities or situations because they remind you of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 8,
    title: 'Trouble remembering important parts of a stressful experience from the past?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 9,
    title: 'Loss of interest in things that you used to enjoy?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 10,
    title: 'Feeling distant or cut off from other people?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 11,
    title: 'Feeling emotionally numb or being unable to have loving feelings for those close to you?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 12,
    title: 'Feeling as if your future will somehow be cut short?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 13,
    title: 'Trouble falling or staying asleep?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 14,
    title: 'Feeling irritable or having angry outbursts?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 15,
    title: 'Having difficulty concentrating?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 16,
    title: 'Being “super alert” or watchful on guard?',
    options: ptsdOptions,
  ),
  AssessmentQuestion(
    number: 17,
    title: 'Feeling jumpy or easily startled?',
    options: ptsdOptions,
  ),
];
const List<String> ocdOptions = [
  'None',
  'Mild',
  'Moderate',
  'Severe',
  'Extreme',
];

const List<AssessmentQuestion> ocdQuestions = [
  AssessmentQuestion(
    number: 1,
    title: 'How much time do you spend on obsessive thoughts?',
    options: [
      'None',
      '0-1 hrs/day',
      '1-3 hrs/day',
      '3-8 hrs/day',
      'More than 8 hrs/day',
    ],
  ),
  AssessmentQuestion(
    number: 2,
    title: 'How much do your obsessive thoughts interfere with your personal, social, or work life?',
    options: [
      'None',
      'Mild',
      'Definite but manageable',
      'Substantial interference',
      'Severe',
    ],
  ),
  AssessmentQuestion(
    number: 3,
    title: 'How much do your obsessive thoughts distress you?',
    options: [
      'None',
      'Little',
      'Moderate but manageable',
      'Severe',
      'Nearly constant, disabling',
    ],
  ),
  AssessmentQuestion(
    number: 4,
    title: 'How hard do you try to resist your obsessions?',
    options: [
      'Always try',
      'Try much of the time',
      'Try some of the time',
      'Rarely try / often yield',
      'Never try / completely yield',
    ],
  ),
  AssessmentQuestion(
    number: 5,
    title: 'How much control do you have over your obsessive thoughts?',
    options: [
      'Complete control',
      'Much control',
      'Some control',
      'Little control',
      'No control',
    ],
  ),

  AssessmentQuestion(
    number: 6,
    title: 'How much time do you spend performing compulsive behaviors?',
    options: [
      'None',
      '0-1 hrs/day',
      '1-3 hrs/day',
      '3-8 hrs/day',
      'More than 8 hrs/day',
    ],
  ),
  AssessmentQuestion(
    number: 7,
    title: 'How much do your compulsive behaviors interfere with your personal, social, or work life?',
    options: [
      'None',
      'Mild',
      'Definite but manageable',
      'Substantial interference',
      'Severe',
    ],
  ),
  AssessmentQuestion(
    number: 8,
    title: 'How anxious would you feel if prevented from performing compulsive behaviors?',
    options: [
      'None',
      'Little',
      'Moderate but manageable',
      'Severe',
      'Nearly constant / disabling',
    ],
  ),
  AssessmentQuestion(
    number: 9,
    title: 'How hard do you try to resist compulsive behaviors?',
    options: [
      'Always try',
      'Try much of the time',
      'Try some of the time',
      'Rarely try / often yield',
      'Never try / completely yield',
    ],
  ),
  AssessmentQuestion(
    number: 10,
    title: 'How much control do you have over compulsive behaviors?',
    options: [
      'Complete control',
      'Much control',
      'Some control',
      'Little control',
      'No control',
    ],
  ),
];
const List<String> adhdOptions = [
  'Never',
  'Rarely',
  'Sometimes',
  'Often',
  'Very Often',
];
const List<AssessmentQuestion> adhdQuestions = [

  AssessmentQuestion(
    number: 1,
    title: 'How often do you have trouble wrapping up the final details of a project once the challenging parts are done?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 2,
    title: 'How often do you have difficulty getting things in order when doing a task that requires organization?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 3,
    title: 'How often do you have problems remembering appointments or obligations?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 4,
    title: 'When you have a task that requires a lot of thought, how often do you avoid or delay getting started?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 5,
    title: 'How often do you fidget or squirm with your hands or feet when sitting for a long time?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 6,
    title: 'How often do you feel overly active and compelled to do things like you were driven by a motor?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 7,
    title: 'How often do you make careless mistakes when working on a boring or difficult project?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 8,
    title: 'How often do you have difficulty keeping your attention when doing boring or repetitive work?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 9,
    title: 'How often do you have difficulty concentrating on what people say to you?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 10,
    title: 'How often do you misplace or have difficulty finding things at home or work?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 11,
    title: 'How often are you distracted by activity or noise around you?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 12,
    title: 'How often do you leave your seat in meetings or situations where you should remain seated?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 13,
    title: 'How often do you feel restless or fidgety?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 14,
    title: 'How often do you have difficulty unwinding and relaxing?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 15,
    title: 'How often do you find yourself talking too much in social situations?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 16,
    title: 'How often do you finish other people’s sentences before they can finish them?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 17,
    title: 'How often do you have difficulty waiting your turn?',
    options: adhdOptions,
  ),

  AssessmentQuestion(
    number: 18,
    title: 'How often do you interrupt others when they are busy?',
    options: adhdOptions,
  ),
];
const List<String> suicideOptions = [
  'Low / None',
  'Moderate',
  'High',
];

const List<AssessmentQuestion> suicideIntentQuestions = [

  AssessmentQuestion(
    number: 1,
    title: 'Isolation during attempt',
    options: [
      'Somebody present',
      'Somebody nearby / visual contact',
      'No-one nearby',
    ],
  ),

  AssessmentQuestion(
    number: 2,
    title: 'Likelihood of intervention',
    options: [
      'Intervention probable',
      'Intervention unlikely',
      'Intervention highly unlikely',
    ],
  ),

  AssessmentQuestion(
    number: 3,
    title: 'Precautions against discovery',
    options: [
      'No precautions',
      'Passive precautions',
      'Active precautions',
    ],
  ),

  AssessmentQuestion(
    number: 4,
    title: 'Acting to get help',
    options: [
      'Notified helper',
      'Contacted helper indirectly',
      'Did not notify anyone',
    ],
  ),

  AssessmentQuestion(
    number: 5,
    title: 'Final acts anticipating death',
    options: [
      'None',
      'Some arrangements',
      'Completed arrangements',
    ],
  ),

  AssessmentQuestion(
    number: 6,
    title: 'Preparation for attempt',
    options: [
      'None',
      'Minimal',
      'Extensive',
    ],
  ),

  AssessmentQuestion(
    number: 7,
    title: 'Suicide note',
    options: [
      'No note',
      'Thought about note',
      'Left a note',
    ],
  ),

  AssessmentQuestion(
    number: 8,
    title: 'Communication of intent',
    options: [
      'None',
      'Equivocal communication',
      'Clear communication',
    ],
  ),

  AssessmentQuestion(
    number: 9,
    title: 'Purpose of attempt',
    options: [
      'Manipulate environment',
      'Mixed purpose',
      'Escape / solve problems',
    ],
  ),

  AssessmentQuestion(
    number: 10,
    title: 'Expectation of fatality',
    options: [
      'Death unlikely',
      'Death possible',
      'Death probable',
    ],
  ),

  AssessmentQuestion(
    number: 11,
    title: 'Perceived lethality of method',
    options: [
      'Less than lethal',
      'Uncertain',
      'Equal or exceeded lethal',
    ],
  ),

  AssessmentQuestion(
    number: 12,
    title: 'Seriousness of attempt',
    options: [
      'Not serious',
      'Uncertain',
      'Serious attempt',
    ],
  ),

  AssessmentQuestion(
    number: 13,
    title: 'Attitude toward living/dying',
    options: [
      'Did not want to die',
      'Mixed feelings',
      'Wanted to die',
    ],
  ),

  AssessmentQuestion(
    number: 14,
    title: 'Belief in medical rescue',
    options: [
      'Death unlikely with treatment',
      'Uncertain',
      'Certain death even with treatment',
    ],
  ),

  AssessmentQuestion(
    number: 15,
    title: 'Premeditation before attempt',
    options: [
      'Impulsive',
      'Less than 3 hours',
      'More than 3 hours',
    ],
  ),
];
const List<String> selfEsteemOptions = [
  'Strongly Agree',
  'Agree',
  'Disagree',
  'Strongly Disagree',
];
const List<AssessmentQuestion> selfEsteemQuestions = [

  AssessmentQuestion(
    number: 1,
    title: 'On the whole, I am satisfied with myself.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 2,
    title: 'At times, I think I am no good at all.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 3,
    title: 'I feel that I have a number of good qualities.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 4,
    title: 'I am able to do things as well as most other people.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 5,
    title: 'I feel I do not have much to be proud of.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 6,
    title: 'I certainly feel useless at times.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 7,
    title: 'I feel that I’m a person of worth, at least on an equal plane with others.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 8,
    title: 'I wish I could have more respect for myself.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 9,
    title: 'All in all, I am inclined to feel that I am a failure.',
    options: selfEsteemOptions,
  ),

  AssessmentQuestion(
    number: 10,
    title: 'I take a positive attitude toward myself.',
    options: selfEsteemOptions,
  ),
];
const List<String> insomniaOptions = [
  'None',
  'Mild',
  'Moderate',
  'Severe',
  'Very Severe',
];
const List<AssessmentQuestion> insomniaQuestions = [

  AssessmentQuestion(
    number: 1,
    title: 'Difficulty falling asleep',
    options: insomniaOptions,
  ),

  AssessmentQuestion(
    number: 2,
    title: 'Difficulty staying asleep',
    options: insomniaOptions,
  ),

  AssessmentQuestion(
    number: 3,
    title: 'Problem waking up too early',
    options: insomniaOptions,
  ),

  AssessmentQuestion(
    number: 4,
    title: 'How satisfied are you with your current sleep pattern?',
    options: [
      'Very satisfied',
      'Satisfied',
      'Neutral',
      'Dissatisfied',
      'Very dissatisfied',
    ],
  ),

  AssessmentQuestion(
    number: 5,
    title: 'How much does your sleep problem interfere with daily functioning?',
    options: [
      'Not at all',
      'A little',
      'Somewhat',
      'Much',
      'Very much',
    ],
  ),

  AssessmentQuestion(
    number: 6,
    title: 'How noticeable is your sleep problem to others?',
    options: [
      'Not noticeable',
      'Barely noticeable',
      'Somewhat',
      'Much',
      'Very much',
    ],
  ),

  AssessmentQuestion(
    number: 7,
    title: 'How worried or distressed are you about your sleep problem?',
    options: [
      'Not at all',
      'A little',
      'Somewhat',
      'Much',
      'Very much',
    ],
  ),
];