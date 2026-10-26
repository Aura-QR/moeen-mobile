import 'package:equatable/equatable.dart';

class QuestionType {
  static const String mcq = 'mcq';
  static const String trueFalse = 'true_false';
  static const String fillBlank = 'fill_blank';
  static const String essay = 'essay';
  static const String matching = 'matching';

  static const List<String> all = [
    mcq,
    trueFalse,
    fillBlank,
    essay,
    matching,
  ];
}

class ExtractedQuestionModel extends Equatable {
  static const String answerTrue = 'صح';
  static const String answerFalse = 'خطأ';

  final String type;
  final String questionText;
  final List<String> options;
  final List<String> columnA;
  final List<String> columnB;
  final String correctAnswer;
  final String difficulty;
  final bool needsAnswer;
  final bool suggested;
  final double points;

  const ExtractedQuestionModel({
    required this.type,
    required this.questionText,
    this.options = const [],
    this.columnA = const [],
    this.columnB = const [],
    required this.correctAnswer,
    this.difficulty = 'medium',
    this.needsAnswer = false,
    this.suggested = false,
    this.points = 1.0,
  });

  factory ExtractedQuestionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? QuestionType.mcq;
    final rawOptions = json['options'];
    List<String> options = const [];
    List<String> columnA = const [];
    List<String> columnB = const [];

    if (rawOptions is Map) {
      final rawA = rawOptions['column_a'];
      final rawB = rawOptions['column_b'];
      if (rawA is List) {
        columnA = rawA.map((e) => e.toString()).toList();
      }
      if (rawB is List) {
        columnB = rawB.map((e) => e.toString()).toList();
      }
    } else if (rawOptions is List) {
      if (type == QuestionType.mcq) {
        options = rawOptions.map((e) => e.toString()).toList();
      }
    }

    return ExtractedQuestionModel(
      type: type,
      questionText: json['question_text']?.toString() ?? '',
      options: options,
      columnA: columnA,
      columnB: columnB,
      correctAnswer: json['correct_answer']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      needsAnswer: json['needs_answer'] == true,
      suggested: json['suggested'] == true,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toSaveJson() {
    dynamic optionsJson;
    if (type == QuestionType.matching) {
      optionsJson = {
        'column_a': columnA,
        'column_b': columnB,
      };
    } else if (type == QuestionType.mcq) {
      optionsJson = options;
    } else {
      optionsJson = <String>[];
    }

    return {
      'type': type,
      'question_text': questionText,
      'options': optionsJson,
      'correct_answer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
    };
  }

  ExtractedQuestionModel copyWith({
    String? type,
    String? questionText,
    List<String>? options,
    List<String>? columnA,
    List<String>? columnB,
    String? correctAnswer,
    String? difficulty,
    bool? needsAnswer,
    bool? suggested,
    double? points,
  }) {
    return ExtractedQuestionModel(
      type: type ?? this.type,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      columnA: columnA ?? this.columnA,
      columnB: columnB ?? this.columnB,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficulty: difficulty ?? this.difficulty,
      needsAnswer: needsAnswer ?? this.needsAnswer,
      suggested: suggested ?? this.suggested,
      points: points ?? this.points,
    );
  }

  bool get hasAnswer => correctAnswer.trim().isNotEmpty;

  bool get mcqAnswerMismatch =>
      type == QuestionType.mcq && hasAnswer && !options.contains(correctAnswer.trim());

  bool get isHighlighted =>
      (needsAnswer && !hasAnswer) || mcqAnswerMismatch || !hasAnswer;

  bool get isValid =>
      questionText.trim().isNotEmpty &&
      hasAnswer &&
      !mcqAnswerMismatch &&
      (type != QuestionType.mcq ||
          options.where((item) => item.trim().isNotEmpty).length >= 2);

  @override
  List<Object?> get props => [
        type,
        questionText,
        options,
        columnA,
        columnB,
        correctAnswer,
        difficulty,
        needsAnswer,
        suggested,
        points,
      ];
}
