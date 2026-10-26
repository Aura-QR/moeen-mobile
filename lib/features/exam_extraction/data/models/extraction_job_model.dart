import 'package:equatable/equatable.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';

class ExtractionJobModel extends Equatable {
  final int id;
  final String status;
  final String? source;
  final List<ExtractedQuestionModel> questions;
  final String? error;

  const ExtractionJobModel({
    required this.id,
    required this.status,
    this.source,
    this.questions = const [],
    this.error,
  });

  factory ExtractionJobModel.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final id = int.tryParse('${payload['id']}') ?? 0;
    final status = payload['status']?.toString() ?? 'pending';
    final error = payload['error']?.toString();

    String? source;
    List<ExtractedQuestionModel> questions = const [];

    final result = payload['result'];
    if (result is Map) {
      source = result['source']?.toString();
      final rawQuestions = result['questions'];
      if (rawQuestions is List) {
        questions = rawQuestions
            .whereType<Map<String, dynamic>>()
            .map(ExtractedQuestionModel.fromJson)
            .toList();
      }
    } else if (payload['questions'] is List) {
      source = payload['source']?.toString();
      questions = (payload['questions'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ExtractedQuestionModel.fromJson)
          .toList();
    }

    return ExtractionJobModel(
      id: id,
      status: status,
      source: source,
      questions: questions,
      error: error,
    );
  }

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending' || status == 'processing';

  @override
  List<Object?> get props => [id, status, source, questions, error];
}
