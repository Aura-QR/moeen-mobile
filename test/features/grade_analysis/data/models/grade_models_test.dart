import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/models/grade_sheet_import.dart';

void main() {
  test('GradeOptionsModel reads the defaults', () {
    final options = GradeOptionsModel.fromJson({
      'pass_percent': 50,
      'bands': [
        {'label': 'ممتاز', 'min': 90},
        {'label': 'بحاجة لدعم', 'min': 0},
      ],
      'limits': {'classes': 5, 'students': 80, 'bands': 8},
    });

    expect(options.passPercent, 50);
    expect(options.bands.first, const GradeBand(label: 'ممتاز', min: 90));
    expect(options.limits.students, 80);
  });

  group('GradeAnalysisInput', () {
    test('toJson sends an absent student as a null grade and leaves out empty fields', () {
      final json = const GradeAnalysisInput(
        reportType: GradeReportTypes.detailed,
        totalMark: 20,
        classes: [
          GradeClassInput(
            name: 'رابع 1',
            classId: 3,
            students: [
              GradeStudentInput(name: 'أحمد', grade: 18),
              GradeStudentInput(name: 'خالد'),
            ],
          ),
        ],
        extra: {'academic_year': '1448 هـ'},
      ).toJson();

      expect(json['report_type'], 'detailed');
      expect(json.containsKey('pass_mark'), isFalse);
      expect(json.containsKey('bands'), isFalse);
      expect(json['academic_year'], '1448 هـ');
      expect((json['classes'] as List).single, {
        'name': 'رابع 1',
        'class_id': 3,
        'students': [
          {'name': 'أحمد', 'grade': 18.0},
          {'name': 'خالد', 'grade': null},
        ],
      });
    });

    test('fromJson round-trips a saved input', () {
      final input = GradeAnalysisInput.fromJson({
        'report_type': 'quick',
        'subject': 'الرياضيات',
        'date': '2026-10-25',
        'total_mark': 20,
        'pass_mark': 12,
        'bands': [
          {'label': 'ممتاز', 'min': 90},
        ],
        'classes': [
          {
            'name': '',
            'students': [
              {'name': '', 'grade': 15.5},
            ],
          },
        ],
        'recommendations': ['تعزيز التدريب'],
        'date_hijri': '١٤٤٨/٠٤/٠٣',
      });

      expect(input.subject, 'الرياضيات');
      expect(input.date, DateTime(2026, 10, 25));
      expect(input.passMark, 12);
      expect(input.classes.single.students.single.grade, 15.5);
      expect(input.recommendations, ['تعزيز التدريب']);
      expect(input.extra, {'date_hijri': '١٤٤٨/٠٤/٠٣'});
    });
  });

  test('GradeAnalysisResult headlines the combined numbers for a comparison', () {
    final result = GradeAnalysisResult.fromJson({
      'total_mark': 20,
      'pass_mark': 10,
      'classes': [
        {
          'name': 'رابع 1',
          'rank': 1,
          'stats': {'count': 2, 'mean': 15, 'pass_rate': 100},
          'absent': ['تركي'],
        },
        {
          'name': 'رابع 2',
          'rank': 2,
          'stats': {'count': 3},
        },
      ],
      'combined': {
        'name': 'الكل',
        'stats': {'count': 5, 'mean': 13.5},
      },
      'ai_input': {'mean_percent': 67.5},
    });

    expect(result.isComparison, isTrue);
    expect(result.overall?.stats.mean, 13.5);
    expect(result.classes.first.absent, ['تركي']);
    expect(result.aiInput, {'mean_percent': 67.5});
  });

  test('GradeSheetImport reads the rows and the grade column', () {
    final sheet = GradeSheetImport.fromJson({
      'rows': [
        {'name': 'أحمد علي', 'grade': 18},
        {'name': 'خالد', 'grade': null},
      ],
      'grade_column': 'المجموع',
    });

    expect(sheet.rows.map((row) => row.grade), [18, null]);
    expect(sheet.gradeColumn, 'المجموع');
  });
}
