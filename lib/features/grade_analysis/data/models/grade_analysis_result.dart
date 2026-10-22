/// `POST /tools/grades/analyze` (GRADE_ANALYSIS_API.md § 3). Nothing is saved.
library;

double _number(dynamic value) => double.tryParse('$value') ?? 0;

/// How many grades fell in a level.
class GradeBandCount {
  final String label;
  final int count;
  final double percent;

  const GradeBandCount({required this.label, required this.count, required this.percent});

  factory GradeBandCount.fromJson(Map<String, dynamic> json) => GradeBandCount(
    label: json['label']?.toString() ?? '',
    count: _number(json['count']).toInt(),
    percent: _number(json['percent']),
  );
}

class GradeStats {
  /// Graded students; absent ones are left out.
  final int count;
  final double mean;
  final double meanPercent;
  final double median;

  /// Population standard deviation (Excel's STDEV.P).
  final double stddev;
  final double min;
  final double max;
  final int passed;
  final int failed;
  final double passRate;
  final List<GradeBandCount> bands;

  const GradeStats({
    this.count = 0,
    this.mean = 0,
    this.meanPercent = 0,
    this.median = 0,
    this.stddev = 0,
    this.min = 0,
    this.max = 0,
    this.passed = 0,
    this.failed = 0,
    this.passRate = 0,
    this.bands = const [],
  });

  factory GradeStats.fromJson(Map<String, dynamic> json) {
    final bands = json['bands'];
    return GradeStats(
      count: _number(json['count']).toInt(),
      mean: _number(json['mean']),
      meanPercent: _number(json['mean_percent']),
      median: _number(json['median']),
      stddev: _number(json['stddev']),
      min: _number(json['min']),
      max: _number(json['max']),
      passed: _number(json['passed']).toInt(),
      failed: _number(json['failed']).toInt(),
      passRate: _number(json['pass_rate']),
      bands: bands is List ? bands.whereType<Map<String, dynamic>>().map(GradeBandCount.fromJson).toList() : const [],
    );
  }
}

class GradeClassResult {
  final String name;

  /// By average percentage, ties sharing a place; null for one class.
  final int? rank;
  final GradeStats stats;
  final List<String> absent;

  const GradeClassResult({required this.name, this.rank, this.stats = const GradeStats(), this.absent = const []});

  factory GradeClassResult.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final absent = json['absent'];
    return GradeClassResult(
      name: json['name']?.toString() ?? '',
      rank: int.tryParse('${json['rank']}'),
      stats: stats is Map<String, dynamic> ? GradeStats.fromJson(stats) : const GradeStats(),
      absent: absent is List ? absent.map((name) => name.toString()).toList() : const [],
    );
  }
}

class GradeAnalysisResult {
  final double totalMark;
  final double passMark;
  final List<GradeClassResult> classes;

  /// All the classes together; null for one class.
  final GradeClassResult? combined;

  /// Statistics only, no names: the `input` for «اقترح توصيات».
  final Map<String, dynamic> aiInput;

  const GradeAnalysisResult({
    this.totalMark = 0,
    this.passMark = 0,
    this.classes = const [],
    this.combined,
    this.aiInput = const {},
  });

  /// The numbers to headline: all the classes together, or the only one.
  GradeClassResult? get overall => combined ?? classes.firstOrNull;

  bool get isComparison => classes.length > 1;

  factory GradeAnalysisResult.fromJson(Map<String, dynamic> json) {
    final classes = json['classes'];
    final combined = json['combined'];
    final aiInput = json['ai_input'];
    return GradeAnalysisResult(
      totalMark: _number(json['total_mark']),
      passMark: _number(json['pass_mark']),
      classes: classes is List
          ? classes.whereType<Map<String, dynamic>>().map(GradeClassResult.fromJson).toList()
          : const [],
      combined: combined is Map<String, dynamic> ? GradeClassResult.fromJson(combined) : null,
      aiInput: aiInput is Map<String, dynamic> ? aiInput : const {},
    );
  }
}
