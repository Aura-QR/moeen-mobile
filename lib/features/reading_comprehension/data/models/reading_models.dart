/// Models for `reading_comprehension` documents (L12 «الفهم القرائي»,
/// DOCUMENTS_API.md § 15): an original passage, a vocabulary box and questions
/// grouped by level.
library;

import 'package:equatable/equatable.dart';

abstract final class ReadingLimits {
  static const int maxTitleLength = 150;
  static const int maxParagraphs = 8;
  static const int maxParagraphLength = 1200;
  static const int maxVocabulary = 10;
  static const int maxWordLength = 60;
  static const int maxMeaningLength = 200;
  static const int maxQuestions = 20;

  /// The AI «✨» request allows 4–12 questions.
  static const int minGeneratedQuestions = 4;
  static const int maxGeneratedQuestions = 12;
  static const int defaultGeneratedQuestions = 8;
}

/// The difficulty of the generated passage (`level`).
enum ReadingLevel {
  easy('easy', 'reading_level_easy'),
  medium('medium', 'reading_level_medium'),
  hard('hard', 'reading_level_hard');

  final String jsonValue;
  final String labelKey;
  const ReadingLevel(this.jsonValue, this.labelKey);

  static ReadingLevel fromJson(dynamic raw) => ReadingLevel.values.firstWhere(
        (item) => item.jsonValue == raw?.toString(),
        orElse: () => ReadingLevel.medium,
      );
}

/// The length of the generated passage (`length`). [approxWordsKey] is the
/// rough word count shown under the option.
enum ReadingLength {
  short('short', 'reading_length_short', 'reading_length_short_words'),
  medium('medium', 'reading_length_medium', 'reading_length_medium_words'),
  long('long', 'reading_length_long', 'reading_length_long_words');

  final String jsonValue;
  final String labelKey;
  final String approxWordsKey;
  const ReadingLength(this.jsonValue, this.labelKey, this.approxWordsKey);

  static ReadingLength fromJson(dynamic raw) => ReadingLength.values.firstWhere(
        (item) => item.jsonValue == raw?.toString(),
        orElse: () => ReadingLength.medium,
      );
}

/// The passage language (`language`), shown only for an English subject.
enum ReadingLanguage {
  arabic('ar', 'reading_language_arabic'),
  english('en', 'reading_language_english');

  final String jsonValue;
  final String labelKey;
  const ReadingLanguage(this.jsonValue, this.labelKey);

  bool get isRtl => this == ReadingLanguage.arabic;

  static ReadingLanguage fromJson(dynamic raw) => ReadingLanguage.values.firstWhere(
        (item) => item.jsonValue == raw?.toString(),
        orElse: () => ReadingLanguage.arabic,
      );
}

/// The thinking level a question sits under (`level`): direct/literal
/// comprehension, inference, or critical thinking. [jsonValue] is the value
/// sent for a teacher-picked level; an AI-generated question keeps the exact
/// value the server returned (see [ReadingQuestion.levelRaw]).
enum ReadingQuestionLevel {
  direct('literal', 'reading_qlevel_direct'),
  inference('inferential', 'reading_qlevel_inference'),
  critical('critical', 'reading_qlevel_critical');

  final String jsonValue;
  final String labelKey;
  const ReadingQuestionLevel(this.jsonValue, this.labelKey);

  /// Loosely maps any server/AI value to a display group.
  static ReadingQuestionLevel fromJson(dynamic raw) {
    final value = raw?.toString().toLowerCase().trim() ?? '';
    if (value.contains('infer') || value.contains('استنتاج')) {
      return ReadingQuestionLevel.inference;
    }
    if (value.contains('critic') || value.contains('evaluat') || value.contains('ناقد')) {
      return ReadingQuestionLevel.critical;
    }
    return ReadingQuestionLevel.direct;
  }
}

/// The question types a reading worksheet allows.
enum ReadingQuestionType {
  mcq('mcq', 'reading_qtype_mcq'),
  trueFalse('true_false', 'reading_qtype_true_false'),
  fillBlank('fill_blank', 'reading_qtype_fill_blank'),
  essay('essay', 'reading_qtype_essay');

  final String jsonValue;
  final String labelKey;
  const ReadingQuestionType(this.jsonValue, this.labelKey);

  bool get needsOptions => this == ReadingQuestionType.mcq;
  bool get needsAnswer => this != ReadingQuestionType.essay;

  static ReadingQuestionType fromJson(dynamic raw) => ReadingQuestionType.values.firstWhere(
        (item) => item.jsonValue == raw?.toString(),
        orElse: () => ReadingQuestionType.mcq,
      );
}

/// «صح» / «خطأ», stored even for an English worksheet.
abstract final class ReadingTrueFalse {
  static const String isTrue = 'صح';
  static const String isFalse = 'خطأ';
}

class ReadingVocabularyItem extends Equatable {
  final String word;
  final String meaning;

  const ReadingVocabularyItem({this.word = '', this.meaning = ''});

  factory ReadingVocabularyItem.fromJson(Map<String, dynamic> json) => ReadingVocabularyItem(
        word: json['word']?.toString() ?? '',
        meaning: (json['meaning'] ?? json['definition'])?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'word': word.trim(), 'meaning': meaning.trim()};

  ReadingVocabularyItem copyWith({String? word, String? meaning}) =>
      ReadingVocabularyItem(word: word ?? this.word, meaning: meaning ?? this.meaning);

  @override
  List<Object?> get props => [word, meaning];
}

class ReadingQuestion extends Equatable {
  final ReadingQuestionType type;
  final ReadingQuestionLevel level;

  /// The exact `level` value the server/AI returned, sent back unchanged so an
  /// AI worksheet round-trips; empty for a teacher-picked level, which then
  /// sends [ReadingQuestionLevel.jsonValue].
  final String levelRaw;
  final String text;
  final List<String> options;
  final String correctAnswer;

  const ReadingQuestion({
    this.type = ReadingQuestionType.mcq,
    this.level = ReadingQuestionLevel.direct,
    this.levelRaw = '',
    this.text = '',
    this.options = const [],
    this.correctAnswer = '',
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final rawLevel = json['level']?.toString() ?? '';
    return ReadingQuestion(
      type: ReadingQuestionType.fromJson(json['type']),
      level: ReadingQuestionLevel.fromJson(rawLevel),
      levelRaw: rawLevel,
      text: (json['question_text'] ?? json['text'])?.toString() ?? '',
      options: rawOptions is List ? rawOptions.map((e) => e.toString()).toList() : const [],
      correctAnswer: (json['correct_answer'] ?? json['answer'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.jsonValue,
        'level': levelRaw.trim().isNotEmpty ? levelRaw.trim() : level.jsonValue,
        'question_text': text.trim(),
        if (type.needsOptions)
          'options': [for (final o in options) o.trim()].where((o) => o.isNotEmpty).toList(),
        'correct_answer': correctAnswer.trim(),
      };

  ReadingQuestion copyWith({
    ReadingQuestionType? type,
    ReadingQuestionLevel? level,
    String? levelRaw,
    String? text,
    List<String>? options,
    String? correctAnswer,
  }) =>
      ReadingQuestion(
        type: type ?? this.type,
        level: level ?? this.level,
        levelRaw: levelRaw ?? this.levelRaw,
        text: text ?? this.text,
        options: options ?? this.options,
        correctAnswer: correctAnswer ?? this.correctAnswer,
      );

  @override
  List<Object?> get props => [type, level, levelRaw, text, options, correctAnswer];
}

class ReadingComprehensionInput extends Equatable {
  final String title;
  final int? lessonId;
  final ReadingLevel level;
  final ReadingLanguage language;
  final List<String> passage;
  final List<ReadingVocabularyItem> vocabulary;
  final List<ReadingQuestion> questions;
  final bool studentFields;
  final bool showAnswers;
  final Map<String, dynamic> header;
  final Map<String, dynamic> extra;

  const ReadingComprehensionInput({
    this.title = '',
    this.lessonId,
    this.level = ReadingLevel.medium,
    this.language = ReadingLanguage.arabic,
    this.passage = const [''],
    this.vocabulary = const [],
    this.questions = const [],
    this.studentFields = true,
    this.showAnswers = true,
    this.header = const {},
    this.extra = const {},
  });

  static const _ownKeys = {
    'title',
    'lesson_id',
    'level',
    'language',
    'passage',
    'vocabulary',
    'questions',
    'student_fields',
    'show_answers',
    'header',
  };

  factory ReadingComprehensionInput.blank() =>
      const ReadingComprehensionInput(passage: ['']);

  factory ReadingComprehensionInput.fromAiResult(
    Map<String, dynamic> result, {
    required int lessonId,
    String fallbackTitle = '',
  }) {
    final merged = <String, dynamic>{...result, 'lesson_id': lessonId};
    final parsed = ReadingComprehensionInput.fromJson(merged).copyWith(showAnswers: true);
    if (parsed.title.trim().isNotEmpty || fallbackTitle.trim().isEmpty) return parsed;
    return parsed.copyWith(title: fallbackTitle.trim());
  }

  factory ReadingComprehensionInput.fromJson(Map<String, dynamic> json) {
    final rawPassage = json['passage'];
    final passage = <String>[];
    if (rawPassage is List) {
      passage.addAll(rawPassage.map((e) => e.toString()));
    } else if (rawPassage is String && rawPassage.trim().isNotEmpty) {
      passage.addAll(rawPassage.split(RegExp(r'\n[ \t]*\n')).map((e) => e.trim()));
    }
    final rawVocab = json['vocabulary'];
    final rawQuestions = json['questions'];
    final header = json['header'];
    return ReadingComprehensionInput(
      title: json['title']?.toString() ?? '',
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? ''),
      level: ReadingLevel.fromJson(json['level']),
      language: ReadingLanguage.fromJson(json['language']),
      passage: passage.isEmpty ? const [''] : passage,
      vocabulary: rawVocab is List
          ? rawVocab.whereType<Map>().map((e) => ReadingVocabularyItem.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      questions: rawQuestions is List
          ? rawQuestions.whereType<Map>().map((e) => ReadingQuestion.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      studentFields: json['student_fields'] != false,
      showAnswers: json['show_answers'] != false,
      header: header is Map ? Map<String, dynamic>.from(header) : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        'title': title.trim(),
        if (lessonId != null) 'lesson_id': lessonId,
        'level': level.jsonValue,
        'language': language.jsonValue,
        'passage': [for (final p in passage) p.trim()].where((p) => p.isNotEmpty).toList(),
        'vocabulary': [
          for (final item in vocabulary)
            if (item.word.trim().isNotEmpty) item.toJson(),
        ],
        'questions': [for (final q in questions) q.toJson()],
        'student_fields': studentFields,
        'show_answers': showAnswers,
        if (header.isNotEmpty) 'header': header,
      };

  int get wordCount {
    var count = 0;
    for (final paragraph in passage) {
      final words = paragraph.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      count += words.length;
    }
    return count;
  }

  List<ReadingQuestion> questionsOf(ReadingQuestionLevel level) =>
      questions.where((q) => q.level == level).toList();

  bool get canAddParagraph => passage.length < ReadingLimits.maxParagraphs;
  bool get canAddVocabulary => vocabulary.length < ReadingLimits.maxVocabulary;
  bool get canAddQuestion => questions.length < ReadingLimits.maxQuestions;

  ReadingComprehensionInput copyWith({
    String? title,
    int? lessonId,
    ReadingLevel? level,
    ReadingLanguage? language,
    List<String>? passage,
    List<ReadingVocabularyItem>? vocabulary,
    List<ReadingQuestion>? questions,
    bool? studentFields,
    bool? showAnswers,
    Map<String, dynamic>? header,
  }) =>
      ReadingComprehensionInput(
        title: title ?? this.title,
        lessonId: lessonId ?? this.lessonId,
        level: level ?? this.level,
        language: language ?? this.language,
        passage: passage ?? this.passage,
        vocabulary: vocabulary ?? this.vocabulary,
        questions: questions ?? this.questions,
        studentFields: studentFields ?? this.studentFields,
        showAnswers: showAnswers ?? this.showAnswers,
        header: header ?? this.header,
        extra: extra,
      );

  @override
  List<Object?> get props => [
        title,
        lessonId,
        level,
        language,
        passage,
        vocabulary,
        questions,
        studentFields,
        showAnswers,
        header,
        extra,
      ];
}
