class ExamEntity {
  final int id;
  final int teacherId;
  final String title;
  final String status;
  final double totalPoints;
  final String createdAt;
  final String updatedAt;
  final List<QuestionEntity> questions;

  ExamEntity({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.status,
    required this.totalPoints,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
  });
}

class QuestionEntity {
  final int id;
  final int lessonId;
  final String type;
  final String questionText;
  final dynamic options; // Will be properly typed in models depending on question type
  final String correctAnswer;
  final String source;
  final int usageCount;
  final int questionOrder;
  final double points;

  QuestionEntity({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.source,
    required this.usageCount,
    required this.questionOrder,
    required this.points,
  });
}

class RequestedCountsEntity {
  final int mcq;
  final int trueFalse;
  final int fillBlank;
  final int essay;
  final int matching;

  const RequestedCountsEntity({
    required this.mcq,
    required this.trueFalse,
    required this.fillBlank,
    required this.essay,
    required this.matching,
  });
  
  bool get hasQuestions => mcq > 0 || trueFalse > 0 || fillBlank > 0 || essay > 0 || matching > 0;
  
  int get total => mcq + trueFalse + fillBlank + essay + matching;
}

class ExamListEntity {
  final int id;
  final String title;
  final String status;
  final int questionsCount;
  final double totalPoints;
  final String createdAt;
  final String updatedAt;

  ExamListEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.questionsCount,
    required this.totalPoints,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ExamPaginationEntity {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<ExamListEntity> data;

  ExamPaginationEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });
}
