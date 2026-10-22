import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';

/// `POST /tools/grades/import`: the rows read from a sheet, for review. Nothing is saved.
class GradeSheetImport {
  final List<GradeStudentInput> rows;

  /// The column the grades were taken from, e.g. «المجموع».
  final String gradeColumn;

  const GradeSheetImport({this.rows = const [], this.gradeColumn = ''});

  factory GradeSheetImport.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'];
    return GradeSheetImport(
      rows: rows is List ? rows.whereType<Map<String, dynamic>>().map(GradeStudentInput.fromJson).toList() : const [],
      gradeColumn: json['grade_column']?.toString() ?? '',
    );
  }
}
