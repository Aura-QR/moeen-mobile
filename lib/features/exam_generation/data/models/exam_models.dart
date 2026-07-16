import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

class ExamModel extends ExamEntity {
  ExamModel({
    required super.id,
    required super.teacherId,
    required super.title,
    required super.status,
    required super.totalPoints,
    required super.createdAt,
    required super.updatedAt,
    required super.questions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuestionModel extends QuestionEntity {
  QuestionModel({
    required super.id,
    required super.lessonId,
    required super.type,
    required super.questionText,
    required super.options,
    required super.correctAnswer,
    required super.source,
    required super.usageCount,
    required super.questionOrder,
    required super.points,
    super.reviewStatus,
    super.rejectionReason,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    dynamic parsedOptions;

    if (type == 'matching') {
      parsedOptions = MatchingOptionsModel.fromJson(json['options'] as Map<String, dynamic>? ?? {});
    } else if (type == 'mcq') {
      parsedOptions = (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    } else {
      parsedOptions = json['options'];
    }

    return QuestionModel(
      id: json['id'] as int? ?? 0,
      lessonId: json['lesson_id'] as int? ?? 0,
      type: type,
      questionText: json['question_text'] as String? ?? '',
      options: parsedOptions,
      correctAnswer: json['correct_answer'] as String? ?? '',
      source: json['source'] as String? ?? '',
      usageCount: json['usage_count'] as int? ?? 0,
      questionOrder: json['question_order'] as int? ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      reviewStatus: json['review_status'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}

class MatchingOptionsModel {
  final List<String> columnA;
  final List<String> columnB;

  MatchingOptionsModel({
    required this.columnA,
    required this.columnB,
  });

  factory MatchingOptionsModel.fromJson(Map<String, dynamic> json) {
    return MatchingOptionsModel(
      columnA: (json['column_a'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      columnB: (json['column_b'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class ExamListModel extends ExamListEntity {
  ExamListModel({
    required super.id,
    required super.title,
    required super.status,
    required super.questionsCount,
    required super.totalPoints,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExamListModel.fromJson(Map<String, dynamic> json) {
    return ExamListModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      questionsCount: json['questions_count'] as int? ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class ExamPaginationModel extends ExamPaginationEntity {
  ExamPaginationModel({
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
    required super.data,
  });

  factory ExamPaginationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return ExamPaginationModel(
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ExamListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuestionPaginationModel extends QuestionPaginationEntity {
  QuestionPaginationModel({
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
    required super.data,
  });

  factory QuestionPaginationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return QuestionPaginationModel(
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
