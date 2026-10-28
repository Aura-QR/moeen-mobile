import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';

int _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
int? _intOrNull(dynamic v) => v == null ? null : (v is int ? v : (v is num ? v.toInt() : int.tryParse('$v')));
double? _double(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];

List<String> _parseOptions(dynamic raw) {
  List<String> list = [];
  if (raw is List) {
    list = raw
        .map((e) => (e is Map ? (e['text'] ?? e['label'] ?? e['value'] ?? '') : e).toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else if (raw is Map) {
    list = raw.values.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList();
  }
  return list.map((o) {
    return o.replaceFirst(RegExp(r'^(?:الخيار\s*|الإجابة\s*|الاجابة\s*)?[أإابجدهـabcd1-9١-٩][\)\.\-\:\s]+'), '').trim();
  }).where((e) => e.isNotEmpty).toList();
}

String _normOptionText(String input) {
  var s = input.trim().toLowerCase();
  s = s.replaceFirst(RegExp(r'^(?:الخيار\s*|الإجابة\s*|الاجابة\s*)?[أإابجدهـabcd1-9١-٩][\)\.\-\:\s]+'), '');
  s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');
  s = s.replaceAll(RegExp(r'[أإآ]'), 'ا').replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  s = s.replaceAll(RegExp(r'[.،؛:!؟?]+$'), '');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

int? _letterOrNumberIndex(String raw) {
  final c = raw.trim().toLowerCase().replaceAll(RegExp(r'^[\(\[\s]+|[\)\]\.\-\:\s]+$'), '');
  return switch (c) {
    'أ' || 'ا' || 'إ' || 'a' || '1' || '١' => 0,
    'ب' || 'b' || '2' || '٢' => 1,
    'ج' || 'ت' || 'c' || '3' || '٣' => 2,
    'د' || 'ث' || 'd' || '4' || '٤' => 3,
    _ => null,
  };
}

(List<String>, String) _resolveMcq(List<String> initialOptions, String rawAnswer, dynamic rawIndex) {
  final opts = [...initialOptions];
  if (opts.isEmpty) return (opts, rawAnswer);

  if (rawAnswer.isNotEmpty && opts.contains(rawAnswer)) {
    return (opts, rawAnswer);
  }

  final parsedIndex = _intOrNull(rawIndex);
  if (rawAnswer.isEmpty && parsedIndex != null && parsedIndex >= 0 && parsedIndex < opts.length) {
    return (opts, opts[parsedIndex]);
  }

  if (rawAnswer.isNotEmpty) {
    final normAns = _normOptionText(rawAnswer);
    if (normAns.isNotEmpty) {
      for (final o in opts) {
        if (_normOptionText(o) == normAns) return (opts, o);
      }
    }

    final letterIdx = _letterOrNumberIndex(rawAnswer);
    if (letterIdx != null && letterIdx >= 0 && letterIdx < opts.length) {
      return (opts, opts[letterIdx]);
    }

    if (parsedIndex != null && parsedIndex >= 0 && parsedIndex < opts.length) {
      return (opts, opts[parsedIndex]);
    }

    if (normAns.length >= 2) {
      final contained = opts.where((o) {
        final no = _normOptionText(o);
        return no.isNotEmpty && (no.contains(normAns) || normAns.contains(no));
      }).toList();
      if (contained.length == 1) return (opts, contained.first);
    }

    final merged = [rawAnswer, ...opts];
    return (merged, rawAnswer);
  }

  if (opts.isNotEmpty) {
    return (opts, opts.first);
  }

  return (opts, rawAnswer);
}

/// One domain under a subject in `GET /nafs/options`.
class NafsDomainOption {
  final String id;
  final String name;
  final String outcome;

  const NafsDomainOption({
    required this.id,
    required this.name,
    required this.outcome,
  });

  factory NafsDomainOption.fromJson(Map<String, dynamic> json) => NafsDomainOption(
        id: (json['key'] ?? json['id'] ?? json['code'] ?? '').toString(),
        name: (json['name'] ?? json['label'] ?? json['title'] ?? '').toString().trim(),
        outcome: (json['outcome'] ?? json['learning_outcome'] ?? json['description'] ?? json['name'] ?? '').toString().trim(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'outcome': outcome,
      };
}

/// One subject under a grade in `GET /nafs/options`.
class NafsSubjectOption {
  final String id;
  final String name;
  final List<int> subjectIds;
  final int realExamQuestions;
  final List<NafsDomainOption> domains;

  const NafsSubjectOption({
    required this.id,
    required this.name,
    this.subjectIds = const [],
    this.realExamQuestions = 20,
    this.domains = const [],
  });

  bool get isReading =>
      id == 'reading' ||
      name.contains('قراءة') ||
      name.contains('لغتي') ||
      name.contains('العربية') ||
      name.toLowerCase().contains('reading');

  bool get isVisible => subjectIds.isNotEmpty;

  factory NafsSubjectOption.fromJson(Map<String, dynamic> json) {
    final rawSubjectIds = json['subject_ids'];
    final List<int> parsedSubjectIds;
    if (rawSubjectIds is List) {
      parsedSubjectIds = rawSubjectIds.map(_int).where((e) => e > 0).toList();
    } else if (json['subject_id'] != null) {
      final sId = _int(json['subject_id']);
      parsedSubjectIds = sId > 0 ? [sId] : const [];
    } else {
      parsedSubjectIds = const [];
    }

    final realTest = json['real_test'];
    final realQuestions = realTest is Map ? _int(realTest['questions']) : 0;

    return NafsSubjectOption(
      id: (json['key'] ?? json['id'] ?? json['code'] ?? '').toString(),
      name: (json['label'] ?? json['name'] ?? json['title'] ?? '').toString().trim(),
      subjectIds: parsedSubjectIds,
      realExamQuestions: realQuestions > 0
          ? realQuestions
          : _int(json['real_exam_questions'] ?? json['standard_questions'] ?? 20),
      domains: _maps(json['domains']).map(NafsDomainOption.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject_ids': subjectIds,
        'real_exam_questions': realExamQuestions,
        'domains': domains.map((d) => d.toJson()).toList(),
      };
}

/// One of the 3 tested grades in Nafs: Primary 3, Primary 6, Intermediate 3.
class NafsGradeOption {
  final String id;
  final String name;
  final List<NafsSubjectOption> subjects;

  const NafsGradeOption({
    required this.id,
    required this.name,
    this.subjects = const [],
  });

  /// Hides subjects with empty `subject_ids`.
  List<NafsSubjectOption> get visibleSubjects =>
      subjects.where((s) => s.isVisible).toList();

  factory NafsGradeOption.fromJson(Map<String, dynamic> json) => NafsGradeOption(
        id: (json['key'] ?? json['id'] ?? json['grade_id'] ?? '').toString(),
        name: (json['label'] ?? json['name'] ?? json['title'] ?? '').toString().trim(),
        subjects: _maps(json['subjects']).map(NafsSubjectOption.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };
}

/// A 4-option multiple-choice question in Nafs.
class NafsQuestion {
  final String text;
  final List<String> options;
  final String answer;
  final String difficulty;
  final double points;

  const NafsQuestion({
    required this.text,
    this.options = const [],
    this.answer = '',
    this.difficulty = 'medium',
    this.points = 1.0,
  });

  bool get isComplete {
    if (text.trim().isEmpty) return false;
    final trimmedOptions = options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
    final trimmedAnswer = answer.trim();
    return trimmedOptions.length >= 2 && trimmedOptions.contains(trimmedAnswer);
  }

  NafsQuestion copyWith({
    String? text,
    List<String>? options,
    String? answer,
    String? difficulty,
    double? points,
  }) =>
      NafsQuestion(
        text: text ?? this.text,
        options: options ?? this.options,
        answer: answer ?? this.answer,
        difficulty: difficulty ?? this.difficulty,
        points: points ?? this.points,
      );

  factory NafsQuestion.fromJson(Map<String, dynamic> json) {
    final text = (json['question_text'] ?? json['text'] ?? json['question'] ?? '').toString().trim();
    final rawOptions = _parseOptions(json['options'] ?? json['choices']);
    final rawAnswerVal = json['correct_answer'] ?? json['answer'] ?? json['right_answer'];
    final rawAnswer = (rawAnswerVal ?? '').toString().trim();
    final rawIndex = json['correct_answer_index'] ?? json['answer_index'];

    final resolved = _resolveMcq(rawOptions, rawAnswer, rawIndex);

    return NafsQuestion(
      text: text,
      options: resolved.$1,
      answer: resolved.$2,
      difficulty: json['difficulty']?.toString() ?? 'medium',
      points: _double(json['points']) ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': DiagnosticQuestionTypes.mcq,
        'question_text': text.trim(),
        'options': options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList(),
        'correct_answer': answer.trim(),
        'difficulty': difficulty,
        'points': points.roundToDouble() == points ? points.toInt() : points,
      };
}

/// A domain containing its Nafs questions.
class NafsDomain {
  final String name;
  final String? outcome;
  final List<int> lessonIds;
  final List<NafsQuestion> questions;

  const NafsDomain({
    required this.name,
    this.outcome,
    this.lessonIds = const [],
    this.questions = const [],
  });

  NafsDomain copyWith({
    String? name,
    String? outcome,
    List<int>? lessonIds,
    List<NafsQuestion>? questions,
  }) =>
      NafsDomain(
        name: name ?? this.name,
        outcome: outcome ?? this.outcome,
        lessonIds: lessonIds ?? this.lessonIds,
        questions: questions ?? this.questions,
      );

  factory NafsDomain.fromJson(Map<String, dynamic> json) => NafsDomain(
        name: (json['name'] ?? json['domain'] ?? json['skill'] ?? '').toString().trim(),
        outcome: json['outcome']?.toString(),
        lessonIds: json['lesson_ids'] is List ? (json['lesson_ids'] as List).map(_int).toList() : const [],
        questions: _maps(json['questions']).map(NafsQuestion.fromJson).where((q) => q.text.trim().isNotEmpty).toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        if (outcome != null) 'outcome': outcome,
        'lesson_ids': lessonIds,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

/// AI job for generating Nafs tests (`GET /ai-jobs/{id}`).
class NafsJob {
  final int id;
  final String status;
  final String? passage;
  final List<NafsDomain> domains;
  final String? error;

  const NafsJob({
    required this.id,
    required this.status,
    this.passage,
    this.domains = const [],
    this.error,
  });

  bool get isPending => status == 'pending';
  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';

  factory NafsJob.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map ? Map<String, dynamic>.from(json['result'] as Map) : const <String, dynamic>{};
    final rawDomains = result['domains'] ?? result['skills'] ?? result['outcomes'];
    final rawPassage = result['passage'] ?? result['reading_passage'] ?? result['text'];

    String? passageText;
    if (rawPassage is String) {
      passageText = rawPassage.trim();
    } else if (rawPassage is List) {
      passageText = rawPassage.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join('\n\n');
    }

    return NafsJob(
      id: _int(json['id']),
      status: json['status']?.toString() ?? 'pending',
      passage: passageText,
      domains: _maps(rawDomains).map(NafsDomain.fromJson).where((d) => d.name.isNotEmpty && d.questions.isNotEmpty).toList(),
      error: json['error']?.toString(),
    );
  }
}
