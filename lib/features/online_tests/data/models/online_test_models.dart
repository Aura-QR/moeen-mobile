// L4 «الاختبارات الإلكترونية», teacher side. Backend doc: ONLINE_TESTS_API.md.

int _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
double? _double(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];

/// A number without a trailing «.0».
String formatPoints(double? value) {
  if (value == null) return '—';
  final rounded = (value * 100).round() / 100;
  return rounded == rounded.roundToDouble() ? rounded.toInt().toString() : rounded.toString();
}

abstract final class OnlineTestState {
  static const String open = 'open';
  static const String closed = 'closed';
  static const String notStarted = 'not_started';
  static const String ended = 'ended';
}

class OnlineTestGroup {
  final int id;
  final String name;
  final int? classId;
  final String url;
  final int submissions;

  /// A `data:image/png;base64,…` URI, only on the test's own screen.
  final String? qr;

  const OnlineTestGroup({required this.id, required this.name, this.classId, required this.url, this.submissions = 0, this.qr});

  factory OnlineTestGroup.fromJson(Map<String, dynamic> json) => OnlineTestGroup(
        id: _int(json['id']),
        name: json['name']?.toString() ?? '',
        classId: json['class_id'] == null ? null : _int(json['class_id']),
        url: json['url']?.toString() ?? '',
        submissions: _int(json['submissions']),
        qr: json['qr']?.toString(),
      );
}

class OnlineTest {
  final int id;
  final String title;
  final String? subject;
  final int questionsCount;
  final double totalPoints;
  final bool isOpen;
  final String state;
  final int submissions;
  final int? timeLimitMinutes;

  /// Made from a diagnostic exam: its results can be read per skill.
  final bool isDiagnostic;

  /// L12 «الفهم القرائي»: the reading passage students answer about, or null
  /// for an ordinary test. Paragraphs are split on blank lines.
  final String? passage;
  final List<OnlineTestGroup> groups;
  final DateTime? createdAt;

  const OnlineTest({
    required this.id,
    required this.title,
    this.subject,
    this.questionsCount = 0,
    this.totalPoints = 0,
    this.isOpen = true,
    this.state = OnlineTestState.open,
    this.submissions = 0,
    this.timeLimitMinutes,
    this.isDiagnostic = false,
    this.passage,
    this.groups = const [],
    this.createdAt,
  });

  /// The passage split into numbered paragraphs on blank lines.
  List<String> get passageParagraphs {
    final raw = passage?.trim() ?? '';
    if (raw.isEmpty) return const [];
    return raw
        .split(RegExp(r'\n[ \t]*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  factory OnlineTest.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] is Map ? Map<String, dynamic>.from(json['settings'] as Map) : const <String, dynamic>{};
    return OnlineTest(
      id: _int(json['id']),
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString(),
      questionsCount: _int(json['questions_count']),
      totalPoints: _double(json['total_points']) ?? 0,
      isOpen: json['is_open'] != false,
      state: json['state']?.toString() ?? OnlineTestState.open,
      submissions: _int(json['submissions']),
      timeLimitMinutes: settings['time_limit_minutes'] == null ? null : _int(settings['time_limit_minutes']),
      isDiagnostic: json['is_diagnostic'] == true,
      passage: json['passage']?.toString(),
      groups: _maps(json['groups']).map(OnlineTestGroup.fromJson).toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class SubmissionRow {
  final int id;
  final int groupId;
  final String studentName;
  final List<String> fieldValues;
  final double? score;
  final bool needsReview;
  final bool late;
  final int aiSuggested;

  const SubmissionRow({
    required this.id,
    required this.groupId,
    required this.studentName,
    this.fieldValues = const [],
    this.score,
    this.needsReview = false,
    this.late = false,
    this.aiSuggested = 0,
  });

  factory SubmissionRow.fromJson(Map<String, dynamic> json) => SubmissionRow(
        id: _int(json['id']),
        groupId: _int(json['group_id']),
        studentName: json['student_name']?.toString() ?? '',
        fieldValues: _maps(json['fields']).map((f) => f['value']?.toString() ?? '').where((v) => v.isNotEmpty).toList(),
        score: _double(json['score']),
        needsReview: json['needs_review'] == true,
        late: json['late'] == true,
        aiSuggested: _int(json['ai_suggested']),
      );
}

class ResultsGroup {
  final int id;
  final String name;
  final double? average;
  final List<SubmissionRow> submissions;

  const ResultsGroup({required this.id, required this.name, this.average, this.submissions = const []});

  factory ResultsGroup.fromJson(Map<String, dynamic> json) => ResultsGroup(
        id: _int(json['id']),
        name: json['name']?.toString() ?? '',
        average: _double(json['average']),
        submissions: _maps(json['submissions']).map(SubmissionRow.fromJson).toList(),
      );
}

class QuestionStat {
  final int id;
  final String type;
  final String text;
  final double? correctRate;
  final int toReview;

  const QuestionStat({required this.id, required this.type, required this.text, this.correctRate, this.toReview = 0});

  factory QuestionStat.fromJson(Map<String, dynamic> json) => QuestionStat(
        id: _int(json['id']),
        type: json['type']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        correctRate: _double(json['correct_rate']),
        toReview: _int(json['to_review']),
      );
}

class OnlineTestResults {
  final List<ResultsGroup> groups;
  final List<QuestionStat> questions;
  final int toReview;

  /// Answers waiting for the teacher without / with an AI suggestion.
  final int aiWaiting;
  final int aiSuggested;

  const OnlineTestResults({this.groups = const [], this.questions = const [], this.toReview = 0, this.aiWaiting = 0, this.aiSuggested = 0});

  factory OnlineTestResults.fromJson(Map<String, dynamic> json) {
    final ai = json['ai'] is Map ? Map<String, dynamic>.from(json['ai'] as Map) : const <String, dynamic>{};
    return OnlineTestResults(
      groups: _maps(json['groups']).map(ResultsGroup.fromJson).toList(),
      questions: _maps(json['questions']).map(QuestionStat.fromJson).toList(),
      toReview: _int(json['to_review']),
      aiWaiting: _int(ai['waiting']),
      aiSuggested: _int(ai['suggested']),
    );
  }
}

class SubmissionAnswer {
  final int questionId;
  final String type;
  final String text;
  final dynamic options;
  final String correctAnswer;
  final double points;
  final dynamic answer;
  final double? mark;
  final double? aiMark;
  final String aiReason;

  const SubmissionAnswer({
    required this.questionId,
    required this.type,
    required this.text,
    this.options,
    this.correctAnswer = '',
    this.points = 1,
    this.answer,
    this.mark,
    this.aiMark,
    this.aiReason = '',
  });

  factory SubmissionAnswer.fromJson(Map<String, dynamic> json) {
    final ai = json['ai_mark'] is Map ? Map<String, dynamic>.from(json['ai_mark'] as Map) : null;
    return SubmissionAnswer(
      questionId: _int(json['question_id']),
      type: json['type']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      options: json['options'],
      correctAnswer: json['correct_answer']?.toString() ?? '',
      points: _double(json['points']) ?? 1,
      answer: json['answer'],
      mark: _double(json['mark']),
      aiMark: ai == null ? null : _double(ai['mark']),
      aiReason: ai?['reason']?.toString() ?? '',
    );
  }

  /// The student's answer as text; matching lists «item ← choice» per row.
  String get answerText {
    final a = answer;
    if (a == null || (a is String && a.trim().isEmpty)) return '';
    if (type == 'matching' && a is Map && options is Map) {
      final colA = (options['column_a'] as List?) ?? const [];
      final colB = (options['column_b'] as List?) ?? const [];
      return a.entries.map((e) {
        final i = int.tryParse('${e.key}') ?? -1;
        final j = int.tryParse('${e.value}') ?? -1;
        final left = i >= 0 && i < colA.length ? '${colA[i]}' : '${e.key}';
        final right = j >= 0 && j < colB.length ? '${colB[j]}' : '—';
        return '$left ← $right';
      }).join('\n');
    }
    if (a is List) return a.join('، ');
    return '$a';
  }
}

class SubmissionDetail {
  final SubmissionRow row;
  final List<SubmissionAnswer> answers;

  const SubmissionDetail({required this.row, this.answers = const []});

  factory SubmissionDetail.fromJson(Map<String, dynamic> json) => SubmissionDetail(
        row: SubmissionRow.fromJson(json),
        answers: _maps(json['answers']).map(SubmissionAnswer.fromJson).toList(),
      );
}

class AiGradingJob {
  final int id;
  final String status;
  final String? error;
  final int queued;

  /// Answers left for another request; null when an already running job was returned.
  final int? remaining;

  const AiGradingJob({required this.id, required this.status, this.error, this.queued = 0, this.remaining});

  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  factory AiGradingJob.fromJson(Map<String, dynamic> json) => AiGradingJob(
        id: _int(json['id']),
        status: json['status']?.toString() ?? 'pending',
        error: json['error']?.toString(),
        queued: _int(json['queued']),
        remaining: json['remaining'] == null ? null : _int(json['remaining']),
      );
}

/// What the teacher fills in to share an exam.
class NewOnlineTest {
  final int examId;
  final String title;
  final List<({String name, int? classId})> groups;
  final bool showScore;
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final int? timeLimitMinutes;
  final List<String> studentFields;

  const NewOnlineTest({
    required this.examId,
    required this.title,
    required this.groups,
    this.showScore = true,
    this.shuffleQuestions = false,
    this.shuffleOptions = false,
    this.timeLimitMinutes,
    this.studentFields = const [],
  });

  Map<String, dynamic> toJson() => {
        'exam_id': examId,
        if (title.trim().isNotEmpty) 'title': title.trim(),
        'groups': [for (final g in groups) {'name': g.name, if (g.classId != null) 'class_id': g.classId}],
        'settings': {
          'show_score': showScore,
          'shuffle_questions': shuffleQuestions,
          'shuffle_options': shuffleOptions,
          'time_limit_minutes': timeLimitMinutes,
          'student_fields': [for (final f in studentFields) if (f.trim().isNotEmpty) {'label': f.trim()}],
        },
      };
}
