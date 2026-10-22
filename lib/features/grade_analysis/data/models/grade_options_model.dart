/// `GET /tools/grades` (GRADE_ANALYSIS_API.md § 1).
library;

/// A performance level: a grade reaches it from [min] percent of the total.
class GradeBand {
  final String label;
  final double min;

  const GradeBand({required this.label, required this.min});

  factory GradeBand.fromJson(Map<String, dynamic> json) =>
      GradeBand(label: json['label']?.toString() ?? '', min: double.tryParse('${json['min']}') ?? 0);

  Map<String, dynamic> toJson() => {'label': label, 'min': min};

  @override
  bool operator ==(Object other) => other is GradeBand && other.label == label && other.min == min;

  @override
  int get hashCode => Object.hash(label, min);
}

/// `quick` (سريع) or `detailed` (مفصّل).
abstract final class GradeReportTypes {
  static const String quick = 'quick';
  static const String detailed = 'detailed';

  static const List<String> all = [quick, detailed];
}

class GradeLimits {
  final int classes;
  final int students;
  final int bands;

  /// Ticked recommendations; not in the response, so the API doc's value.
  static const int recommendations = 8;
  static const int recommendationLength = 300;
  static const double maxTotalMark = 1000;

  const GradeLimits({this.classes = 5, this.students = 80, this.bands = 8});

  /// The API's minimum number of levels.
  static const int minBands = 2;

  factory GradeLimits.fromJson(Map<String, dynamic> json) => GradeLimits(
    classes: int.tryParse('${json['classes']}') ?? 5,
    students: int.tryParse('${json['students']}') ?? 80,
    bands: int.tryParse('${json['bands']}') ?? 8,
  );
}

class GradeOptionsModel {
  /// The default pass mark, as a percentage of the total mark.
  final double passPercent;

  /// Highest first.
  final List<GradeBand> bands;
  final GradeLimits limits;

  const GradeOptionsModel({this.passPercent = 50, this.bands = const [], this.limits = const GradeLimits()});

  factory GradeOptionsModel.fromJson(Map<String, dynamic> json) {
    final bands = json['bands'];
    final limits = json['limits'];
    return GradeOptionsModel(
      passPercent: double.tryParse('${json['pass_percent']}') ?? 50,
      bands: bands is List ? bands.whereType<Map<String, dynamic>>().map(GradeBand.fromJson).toList() : const [],
      limits: limits is Map<String, dynamic> ? GradeLimits.fromJson(limits) : const GradeLimits(),
    );
  }
}
