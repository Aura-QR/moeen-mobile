/// Models for `/ai-jobs` (AI_JOBS_API.md).
library;

abstract final class AiJobKinds {
  static const String remedialSuggestions = 'remedial_suggestions';
  static const String enrichmentSuggestions = 'enrichment_suggestions';
  static const String gradeRecommendations = 'grade_recommendations';
}

abstract final class AiJobStatus {
  static const String pending = 'pending';
  static const String done = 'done';
  static const String failed = 'failed';
}

class AiJobModel {
  final int id;
  final String kind;
  final String status;

  /// Lists keyed like the tool's sections, e.g. `weaknesses`. Empty until done.
  final Map<String, List<String>> result;

  /// A message for the user when [isFailed].
  final String? error;

  const AiJobModel({
    required this.id,
    required this.kind,
    required this.status,
    this.result = const {},
    this.error,
  });

  bool get isPending => status == AiJobStatus.pending;
  bool get isDone => status == AiJobStatus.done;
  bool get isFailed => status == AiJobStatus.failed;

  factory AiJobModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return AiJobModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      kind: json['kind']?.toString() ?? '',
      status: json['status']?.toString() ?? AiJobStatus.pending,
      result: result is Map
          ? {
              for (final entry in result.entries)
                if (entry.value is List) entry.key.toString(): (entry.value as List).map((e) => e.toString()).toList(),
            }
          : const {},
      error: json['error']?.toString(),
    );
  }
}
