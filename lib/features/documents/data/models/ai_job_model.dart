/// Models for `/ai-jobs` (AI_JOBS_API.md).
library;

abstract final class AiJobKinds {
  static const String remedialSuggestions = 'remedial_suggestions';
  static const String enrichmentSuggestions = 'enrichment_suggestions';
  static const String gradeRecommendations = 'grade_recommendations';
  static const String roleDocument = 'role_document';
  static const String conceptMap = 'concept_map';
  static const String lessonOutcomes = 'lesson_outcomes';
  static const String readingPassage = 'reading_passage';
}

abstract final class AiJobStatus {
  static const String pending = 'pending';
  static const String running = 'running';
  static const String done = 'done';
  static const String failed = 'failed';
}

class AiJobModel {
  final int id;
  final String kind;
  final String status;

  /// Lists keyed like the tool's sections, e.g. `weaknesses`. Empty until done.
  final Map<String, List<String>> result;

  /// Full structured `result` object (e.g. `{title, meta, blocks}` for [AiJobKinds.roleDocument]).
  final Map<String, dynamic> rawResult;

  /// A message for the user when [isFailed].
  final String? error;

  const AiJobModel({
    required this.id,
    required this.kind,
    required this.status,
    this.result = const {},
    this.rawResult = const {},
    this.error,
  });

  bool get isPending =>
      status == AiJobStatus.pending || status == AiJobStatus.running;
  bool get isDone => status == AiJobStatus.done;
  bool get isFailed => status == AiJobStatus.failed;

  factory AiJobModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return AiJobModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      kind: json['kind']?.toString() ?? '',
      status: json['status']?.toString() ?? AiJobStatus.pending,
      result: result is Map
          ? {
              for (final entry in result.entries)
                if (entry.value is List)
                  entry.key.toString(): (entry.value as List)
                      .map((e) => e.toString())
                      .toList(),
            }
          : const {},
      rawResult: result is Map ? Map<String, dynamic>.from(result) : const {},
      error: json['error']?.toString(),
    );
  }
}
