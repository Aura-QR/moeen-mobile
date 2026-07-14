class GenerateExamRequest {
  final String? title;
  final String grade;
  final String subject;
  final List<LessonRequest> lessons;

  GenerateExamRequest({
    this.title,
    required this.grade,
    required this.subject,
    required this.lessons,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null && title!.isNotEmpty) 'title': title,
      'grade': grade,
      'subject': subject,
      'lessons': lessons.map((e) => e.toJson()).toList(),
    };
  }
}

class LessonRequest {
  final int lessonId;
  final String lessonName;
  final RequestedCounts requestedCounts;

  LessonRequest({
    required this.lessonId,
    required this.lessonName,
    required this.requestedCounts,
  });

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'lesson_name': lessonName,
      'requested_counts': requestedCounts.toJson(),
    };
  }
}

class RequestedCounts {
  final int mcq;
  final int trueFalse;
  final int fillBlank;
  final int essay;
  final int matching;

  const RequestedCounts({
    required this.mcq,
    required this.trueFalse,
    required this.fillBlank,
    required this.essay,
    required this.matching,
  });

  Map<String, dynamic> toJson() {
    // Backend requires all keys even if 0
    return {
      'mcq': mcq,
      'true_false': trueFalse,
      'fill_blank': fillBlank,
      'essay': essay,
      'matching': matching,
    };
  }
}

class UpdateQuestionPointsRequest {
  final List<QuestionPoints> questions;

  UpdateQuestionPointsRequest({required this.questions});

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }
}

class QuestionPoints {
  final int questionId;
  final double points;

  QuestionPoints({
    required this.questionId,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'points': points,
    };
  }
}
