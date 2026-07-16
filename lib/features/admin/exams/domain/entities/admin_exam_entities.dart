import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

class CreatorEntity {
  final int teacherId;
  final String name;
  final String email;

  CreatorEntity({
    required this.teacherId,
    required this.name,
    required this.email,
  });
}

class AdminQuestionEntity extends QuestionEntity {
  final CreatorEntity? creator;
  final String reviewStatus;
  final String difficulty;

  AdminQuestionEntity({
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
    required this.reviewStatus,
    required this.difficulty,
    this.creator,
  });
}

class AdminQuestionPaginationEntity {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<AdminQuestionEntity> data;

  AdminQuestionPaginationEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });
}
