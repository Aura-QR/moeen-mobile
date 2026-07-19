class SearchResultModel {
  final int? id;
  final String type;
  final String title;
  final String? subtitle;
  final String? description;
  final String? difficulty;
  final String? questionType;
  final List<String>? options;
  final String? correctAnswer;
  final Map<String, dynamic> raw;

  const SearchResultModel({
    this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.description,
    this.difficulty,
    this.questionType,
    this.options,
    this.correctAnswer,
    required this.raw,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json, String type) {
    List<String>? options;
    if (json['options'] is List) {
      options = (json['options'] as List).map((e) => e.toString()).toList();
    }

    return SearchResultModel(
      id: json['id'] as int?,
      type: type,
      title: (json['title'] ?? json['question_text'] ?? json['name'] ?? '').toString(),
      subtitle: (json['subject_name'] ?? json['lesson_name'] ?? '').toString().isNotEmpty
          ? (json['subject_name'] ?? json['lesson_name'] ?? '').toString()
          : null,
      description: (json['description'] ?? '').toString().isNotEmpty
          ? json['description'].toString()
          : null,
      difficulty: (json['difficulty'] ?? '').toString().isNotEmpty
          ? json['difficulty'].toString()
          : null,
      questionType: (json['question_type'] ?? '').toString().isNotEmpty
          ? json['question_type'].toString()
          : null,
      options: options,
      correctAnswer: (json['correct_answer'] ?? '').toString().isNotEmpty
          ? json['correct_answer'].toString()
          : null,
      raw: json,
    );
  }
}
