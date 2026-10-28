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

/// Limits configured for questions count in `GET /tahsili/options`.
class TahsiliLimits {
  final int min;
  final int max;
  final int defaultCount;

  const TahsiliLimits({
    this.min = 5,
    this.max = 25,
    this.defaultCount = 10,
  });

  factory TahsiliLimits.fromJson(dynamic json) {
    if (json is Map) {
      final minVal = _intOrNull(json['min']) ?? 5;
      final maxVal = _intOrNull(json['max']) ?? 25;
      final defVal = _intOrNull(json['default'] ?? json['standard'] ?? json['questions']) ?? 10;
      return TahsiliLimits(min: minVal, max: maxVal, defaultCount: defVal);
    }
    if (json is List && json.isNotEmpty) {
      final ints = json.map(_int).where((n) => n > 0).toList()..sort();
      if (ints.isNotEmpty) {
        return TahsiliLimits(
          min: ints.first,
          max: ints.last,
          defaultCount: ints.contains(10) ? 10 : ints.first,
        );
      }
    }
    return const TahsiliLimits();
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'default': defaultCount,
      };
}

/// One domain under a subject in `GET /tahsili/options`.
class TahsiliDomainOption {
  final String id;
  final String name;
  final String outcome;

  const TahsiliDomainOption({
    required this.id,
    required this.name,
    required this.outcome,
  });

  factory TahsiliDomainOption.fromJson(Map<String, dynamic> json) {
    final key = (json['key'] ?? json['id'] ?? json['code'] ?? '').toString();
    final name = (json['name'] ?? json['label'] ?? json['title'] ?? '').toString().trim();
    return TahsiliDomainOption(
      id: key,
      name: name.isNotEmpty ? name : key,
      outcome: (json['outcome'] ?? json['learning_outcome'] ?? json['description'] ?? name).toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'outcome': outcome,
      };
}

/// One subject in `GET /tahsili/options`.
class TahsiliSubjectOption {
  final String id;
  final String name;
  final bool available;
  final List<int> subjectIds;
  final List<TahsiliDomainOption> domains;
  final TahsiliLimits? limits;

  const TahsiliSubjectOption({
    required this.id,
    required this.name,
    this.available = true,
    this.subjectIds = const [],
    this.domains = const [],
    this.limits,
  });

  bool get isVisible => available;

  factory TahsiliSubjectOption.fromJson(Map<String, dynamic> json) {
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

    final key = (json['key'] ?? json['id'] ?? json['code'] ?? '').toString();
    final label = (json['label'] ?? json['name'] ?? json['title'] ?? '').toString().trim();

    return TahsiliSubjectOption(
      id: key,
      name: label.isNotEmpty ? label : key,
      available: json['available'] == null
          ? true
          : (json['available'] == true || json['available'] == 1 || json['available'] == '1'),
      subjectIds: parsedSubjectIds,
      domains: _maps(json['domains']).map(TahsiliDomainOption.fromJson).toList(),
      limits: json['limits'] != null ? TahsiliLimits.fromJson(json['limits']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'available': available,
        'subject_ids': subjectIds,
        'domains': domains.map((d) => d.toJson()).toList(),
      };
}

/// Options payload from `GET /tahsili/options`.
class TahsiliOptions {
  final String notice;
  final TahsiliLimits limits;
  final List<TahsiliSubjectOption> subjects;

  const TahsiliOptions({
    this.notice = 'أسئلة تدريبية جديدة بأسلوب التحصيلي، وليست من أسئلة الهيئة',
    this.limits = const TahsiliLimits(),
    this.subjects = const [],
  });

  List<TahsiliSubjectOption> get visibleSubjects => subjects.where((s) => s.isVisible).toList();

  factory TahsiliOptions.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      if (rawJson is List) {
        return TahsiliOptions(
          subjects: rawJson
              .whereType<Map>()
              .map((e) => TahsiliSubjectOption.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
      return const TahsiliOptions();
    }

    final Map<String, dynamic> json;
    if (rawJson.containsKey('data') && rawJson['data'] is Map) {
      json = Map<String, dynamic>.from(rawJson['data'] as Map);
    } else {
      json = Map<String, dynamic>.from(rawJson);
    }

    final notice = json['notice']?.toString().trim();
    final limits = json['limits'] != null ? TahsiliLimits.fromJson(json['limits']) : const TahsiliLimits();
    final rawSubjects = json['subjects'] ?? (json['data'] is List ? json['data'] : null);
    final List<TahsiliSubjectOption> subs;

    if (rawSubjects is List) {
      subs = rawSubjects
          .whereType<Map>()
          .map((e) => TahsiliSubjectOption.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (rawSubjects is Map) {
      subs = rawSubjects.entries.where((e) => e.value is Map).map((e) {
        final m = Map<String, dynamic>.from(e.value as Map);
        m['key'] = m['key'] ?? e.key;
        return TahsiliSubjectOption.fromJson(m);
      }).toList();
    } else {
      subs = const [];
    }

    return TahsiliOptions(
      notice: (notice != null && notice.isNotEmpty)
          ? notice
          : 'أسئلة تدريبية جديدة بأسلوب التحصيلي، وليست من أسئلة الهيئة',
      limits: limits,
      subjects: subs,
    );
  }

  Map<String, dynamic> toJson() => {
        'notice': notice,
        'limits': limits.toJson(),
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };
}

/// A 4-option multiple-choice question in Tahsili with solution method `check`.
class TahsiliQuestion {
  final String text;
  final List<String> options;
  final String answer;
  final String? check;
  final String difficulty;
  final double points;

  const TahsiliQuestion({
    required this.text,
    this.options = const [],
    this.answer = '',
    this.check,
    this.difficulty = 'medium',
    this.points = 1.0,
  });

  bool get isComplete {
    if (text.trim().isEmpty) return false;
    final trimmedOptions = options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
    final trimmedAnswer = answer.trim();
    return trimmedOptions.length >= 2 && trimmedOptions.contains(trimmedAnswer);
  }

  TahsiliQuestion copyWith({
    String? text,
    List<String>? options,
    String? answer,
    String? check,
    bool clearCheck = false,
    String? difficulty,
    double? points,
  }) =>
      TahsiliQuestion(
        text: text ?? this.text,
        options: options ?? this.options,
        answer: answer ?? this.answer,
        check: clearCheck ? null : (check ?? this.check),
        difficulty: difficulty ?? this.difficulty,
        points: points ?? this.points,
      );

  factory TahsiliQuestion.fromJson(Map<String, dynamic> json) {
    final text = (json['question_text'] ?? json['text'] ?? json['question'] ?? '').toString().trim();
    final rawOptions = _parseOptions(json['options'] ?? json['choices']);
    final rawAnswerVal = json['correct_answer'] ?? json['answer'] ?? json['right_answer'];
    final rawAnswer = (rawAnswerVal ?? '').toString().trim();
    final rawIndex = json['correct_answer_index'] ?? json['answer_index'];
    final resolved = _resolveMcq(rawOptions, rawAnswer, rawIndex);
    final checkText = (json['check'] ?? json['solution'] ?? json['explanation'] ?? json['solution_method'])?.toString().trim();

    return TahsiliQuestion(
      text: text,
      options: resolved.$1,
      answer: resolved.$2,
      check: (checkText != null && checkText.isNotEmpty) ? checkText : null,
      difficulty: json['difficulty']?.toString() ?? 'medium',
      points: _double(json['points']) ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': 'mcq',
        'question_text': text.trim(),
        'options': options.map((o) => o.trim()).where((o) => o.isNotEmpty).toList(),
        'correct_answer': answer.trim(),
        if (check != null && check!.trim().isNotEmpty) 'check': check!.trim(),
        'difficulty': difficulty,
        'points': points.roundToDouble() == points ? points.toInt() : points,
      };
}

/// A domain containing Tahsili questions.
class TahsiliDomain {
  final String name;
  final String? outcome;
  final List<TahsiliQuestion> questions;

  const TahsiliDomain({
    required this.name,
    this.outcome,
    this.questions = const [],
  });

  TahsiliDomain copyWith({
    String? name,
    String? outcome,
    List<TahsiliQuestion>? questions,
  }) =>
      TahsiliDomain(
        name: name ?? this.name,
        outcome: outcome ?? this.outcome,
        questions: questions ?? this.questions,
      );

  factory TahsiliDomain.fromJson(Map<String, dynamic> json) => TahsiliDomain(
        name: (json['name'] ?? json['domain'] ?? json['skill'] ?? '').toString().trim(),
        outcome: json['outcome']?.toString(),
        questions: _maps(json['questions']).map(TahsiliQuestion.fromJson).where((q) => q.text.trim().isNotEmpty).toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        if (outcome != null) 'outcome': outcome,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

/// AI job for generating Tahsili tests (`GET /ai-jobs/{id}`).
class TahsiliJob {
  final int id;
  final String status;
  final List<TahsiliDomain> domains;
  final String? error;

  const TahsiliJob({
    required this.id,
    required this.status,
    this.domains = const [],
    this.error,
  });

  bool get isPending => status == 'pending';
  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';

  factory TahsiliJob.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map ? Map<String, dynamic>.from(json['result'] as Map) : const <String, dynamic>{};
    final rawDomains = result['domains'] ?? result['skills'] ?? result['outcomes'];

    return TahsiliJob(
      id: _int(json['id']),
      status: json['status']?.toString() ?? 'pending',
      domains: _maps(rawDomains).map(TahsiliDomain.fromJson).where((d) => d.name.isNotEmpty && d.questions.isNotEmpty).toList(),
      error: json['error']?.toString(),
    );
  }
}
