// L2 «الاختبار التشخيصي». Backend doc: DIAGNOSTIC_TEST_API.md.

int _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
double? _double(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];

abstract final class DiagnosticQuestionTypes {
  static const String mcq = 'mcq';
  static const String trueFalse = 'true_false';
  static const String fillBlank = 'fill_blank';
  static const List<String> all = [mcq, trueFalse, fillBlank];
}

class DiagnosticSource {
  /// `previous_grade` or `readiness` (the first grade of a stage).
  final String mode;
  final String subject;
  final String? grade;
  final String? sourceGrade;
  final int lessonsCount;

  const DiagnosticSource({required this.mode, required this.subject, this.grade, this.sourceGrade, this.lessonsCount = 0});

  bool get isReadiness => mode == 'readiness';

  factory DiagnosticSource.fromJson(Map<String, dynamic> json) => DiagnosticSource(
        mode: json['mode']?.toString() ?? 'previous_grade',
        subject: json['subject']?.toString() ?? '',
        grade: json['grade']?.toString(),
        sourceGrade: json['source_grade']?.toString(),
        lessonsCount: _int(json['lessons_count']),
      );
}

class DiagnosticQuestion {
  final String type;
  final String text;
  final List<String> options;
  final String answer;
  final String difficulty;
  final double points;

  const DiagnosticQuestion({
    required this.type,
    required this.text,
    this.options = const [],
    this.answer = '',
    this.difficulty = 'easy',
    this.points = 1,
  });

  /// Ready to save: has text and an answer (for mcq, one of its options).
  bool get isComplete =>
      text.trim().isNotEmpty && answer.trim().isNotEmpty && (type != DiagnosticQuestionTypes.mcq || (options.length >= 2 && options.contains(answer)));

  DiagnosticQuestion copyWith({String? type, String? text, List<String>? options, String? answer, double? points}) => DiagnosticQuestion(
        type: type ?? this.type,
        text: text ?? this.text,
        options: options ?? this.options,
        answer: answer ?? this.answer,
        difficulty: difficulty,
        points: points ?? this.points,
      );

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) => DiagnosticQuestion(
        type: json['type']?.toString() ?? DiagnosticQuestionTypes.mcq,
        text: json['question_text']?.toString() ?? '',
        options: json['options'] is List ? (json['options'] as List).map((e) => '$e').toList() : const [],
        answer: json['correct_answer']?.toString() ?? '',
        difficulty: json['difficulty']?.toString() ?? 'easy',
        points: _double(json['points']) ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'question_text': text.trim(),
        'options': type == DiagnosticQuestionTypes.mcq ? options : <String>[],
        'correct_answer': answer.trim(),
        'difficulty': difficulty,
        'points': points,
      };
}

class DiagnosticSkill {
  final String name;
  final List<int> lessonIds;
  final List<DiagnosticQuestion> questions;

  const DiagnosticSkill({required this.name, this.lessonIds = const [], this.questions = const []});

  DiagnosticSkill copyWith({String? name, List<DiagnosticQuestion>? questions}) =>
      DiagnosticSkill(name: name ?? this.name, lessonIds: lessonIds, questions: questions ?? this.questions);

  factory DiagnosticSkill.fromJson(Map<String, dynamic> json) => DiagnosticSkill(
        name: json['name']?.toString() ?? '',
        lessonIds: json['lesson_ids'] is List ? (json['lesson_ids'] as List).map(_int).toList() : const [],
        questions: _maps(json['questions']).map(DiagnosticQuestion.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'lesson_ids': lessonIds,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

class DiagnosticJob {
  final int id;
  final String status;
  final List<DiagnosticSkill> skills;
  final String? error;

  const DiagnosticJob({required this.id, required this.status, this.skills = const [], this.error});

  bool get isPending => status == 'pending';
  bool get isDone => status == 'done';

  factory DiagnosticJob.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map ? Map<String, dynamic>.from(json['result'] as Map) : const <String, dynamic>{};
    return DiagnosticJob(
      id: _int(json['id']),
      status: json['status']?.toString() ?? 'pending',
      skills: _maps(result['skills']).map(DiagnosticSkill.fromJson).toList(),
      error: json['error']?.toString(),
    );
  }
}

// ── Diagnosis of an online test ─────────────────────────────────

class SkillGroupMastery {
  final int id;
  final String name;
  final double? mastery;

  const SkillGroupMastery({required this.id, required this.name, this.mastery});
}

class WeakStudent {
  final int submissionId;
  final String name;
  final double? mastery;

  const WeakStudent({required this.submissionId, required this.name, this.mastery});
}

class SkillDiagnosis {
  final String name;
  final double? mastery;
  final List<SkillGroupMastery> groups;
  final List<WeakStudent> weakStudents;

  const SkillDiagnosis({required this.name, this.mastery, this.groups = const [], this.weakStudents = const []});

  factory SkillDiagnosis.fromJson(Map<String, dynamic> json) => SkillDiagnosis(
        name: json['name']?.toString() ?? '',
        mastery: _double(json['mastery']),
        groups: _maps(json['groups']).map((g) => SkillGroupMastery(id: _int(g['id']), name: g['name']?.toString() ?? '', mastery: _double(g['mastery']))).toList(),
        weakStudents: _maps(json['weak_students'])
            .map((s) => WeakStudent(submissionId: _int(s['submission_id']), name: s['name']?.toString() ?? '', mastery: _double(s['mastery'])))
            .toList(),
      );
}

class StudentDiagnosis {
  final int submissionId;
  final String name;
  final int groupId;
  final String group;
  final Map<String, double?> skills;
  final List<String> weakSkills;

  const StudentDiagnosis({required this.submissionId, required this.name, required this.groupId, this.group = '', this.skills = const {}, this.weakSkills = const []});

  factory StudentDiagnosis.fromJson(Map<String, dynamic> json) => StudentDiagnosis(
        submissionId: _int(json['submission_id']),
        name: json['name']?.toString() ?? '',
        groupId: _int(json['group_id']),
        group: json['group']?.toString() ?? '',
        skills: json['skills'] is Map ? (json['skills'] as Map).map((k, v) => MapEntry('$k', _double(v))) : const {},
        weakSkills: json['weak_skills'] is List ? (json['weak_skills'] as List).map((e) => '$e').toList() : const [],
      );
}

class Diagnosis {
  final double weakBelow;
  final double strongFrom;
  final List<SkillDiagnosis> skills;
  final List<StudentDiagnosis> students;
  final int toReview;

  /// Ready inputs for POST /documents (remedial_plan / enrichment_plan).
  final Map<String, dynamic> remedial;
  final Map<String, dynamic> enrichment;

  const Diagnosis({
    this.weakBelow = 60,
    this.strongFrom = 90,
    this.skills = const [],
    this.students = const [],
    this.toReview = 0,
    this.remedial = const {},
    this.enrichment = const {},
  });

  int get remedialCount => (remedial['students'] as List?)?.length ?? 0;
  int get enrichmentCount => (enrichment['students'] as List?)?.length ?? 0;

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    final t = json['thresholds'] is Map ? Map<String, dynamic>.from(json['thresholds'] as Map) : const <String, dynamic>{};
    return Diagnosis(
      weakBelow: _double(t['weak_below']) ?? 60,
      strongFrom: _double(t['strong_from']) ?? 90,
      skills: _maps(json['skills']).map(SkillDiagnosis.fromJson).toList(),
      students: _maps(json['students']).map(StudentDiagnosis.fromJson).toList(),
      toReview: _int(json['to_review']),
      remedial: json['remedial'] is Map ? Map<String, dynamic>.from(json['remedial'] as Map) : const {},
      enrichment: json['enrichment'] is Map ? Map<String, dynamic>.from(json['enrichment'] as Map) : const {},
    );
  }
}
