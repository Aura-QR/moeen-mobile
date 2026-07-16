import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';

class CreatorModel extends CreatorEntity {
  CreatorModel({
    required super.teacherId,
    required super.name,
    required super.email,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      teacherId: json['teacher_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class AdminQuestionModel extends AdminQuestionEntity {
  AdminQuestionModel({
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
    required super.reviewStatus,
    required super.difficulty,
    super.creator,
  });

  factory AdminQuestionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    dynamic parsedOptions;

    if (type == 'matching') {
      parsedOptions = MatchingOptionsModel.fromJson(json['options'] as Map<String, dynamic>? ?? {});
    } else if (type == 'mcq') {
      parsedOptions = (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    } else {
      parsedOptions = json['options'];
    }

    return AdminQuestionModel(
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
      difficulty: json['difficulty'] as String? ?? '',
      creator: json['creator'] != null ? CreatorModel.fromJson(json['creator'] as Map<String, dynamic>) : null,
    );
  }
}

class AdminQuestionPaginationModel extends AdminQuestionPaginationEntity {
  AdminQuestionPaginationModel({
    required super.currentPage,
    required super.lastPage,
    required super.perPage,
    required super.total,
    required super.data,
  });

  factory AdminQuestionPaginationModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return AdminQuestionPaginationModel(
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AdminQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
