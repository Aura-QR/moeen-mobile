import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/models/grade_sheet_import.dart';
import 'package:moean/features/grade_analysis/data/repositories/grade_analysis_repository.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

class MockGradeAnalysisRepository extends Mock implements GradeAnalysisRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _options = GradeOptionsModel(
  bands: [
    GradeBand(label: 'ممتاز', min: 90),
    GradeBand(label: 'جيد', min: 70),
    GradeBand(label: 'بحاجة لدعم', min: 0),
  ],
);

DocumentModel _saved(int id, {Map<String, dynamic> input = const {}}) => DocumentModel(
  id: id,
  type: DocumentTypes.gradeAnalysis,
  title: 'تحليل نتائج الطلاب',
  status: DocumentStatus.draft,
  input: input,
);

void main() {
  late MockGradeAnalysisRepository grades;
  late MockDocumentsRepository documents;
  late MockDeviceFilePicker picker;

  GradeAnalysisCubit build({int? documentId}) => GradeAnalysisCubit(
    documentId: documentId,
    gradesRepository: grades,
    documentsRepository: documents,
    filePicker: picker,
    today: () => DateTime(2026, 10, 22),
  );

  Future<GradeAnalysisCubit> loaded({int? documentId}) async {
    final cubit = build(documentId: documentId);
    await cubit.load();
    return cubit;
  }

  /// Types [grades] into the active class's first rows.
  void type(GradeAnalysisCubit cubit, List<(String, String)> rows) {
    final active = cubit.state.active!;
    for (var i = 0; i < rows.length; i++) {
      cubit.editor.row(active.rowIds[i]).name.text = rows[i].$1;
      cubit.editor.row(active.rowIds[i]).grade.text = rows[i].$2;
    }
  }

  Map<String, dynamic> capturedCreateInput() =>
      verify(
            () => documents.createDocument(
              type: DocumentTypes.gradeAnalysis,
              input: captureAny(named: 'input'),
              status: any(named: 'status'),
            ),
          ).captured.single
          as Map<String, dynamic>;

  setUpAll(() => registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: '', mime: null)));

  setUp(() {
    grades = MockGradeAnalysisRepository();
    documents = MockDocumentsRepository();
    picker = MockDeviceFilePicker();
    when(() => grades.getOptions()).thenAnswer((_) async => const Right(_options));
    when(() => documents.getDefaults()).thenAnswer((_) async => const Right(DocumentDefaultsModel()));
    when(
      () => documents.createDocument(
        type: any(named: 'type'),
        input: any(named: 'input'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(_saved(40)));
  });

  test('load starts one class with empty rows and the default levels', () async {
    final cubit = await loaded();

    expect(cubit.state.status, GradeAnalysisStatus.success);
    expect(cubit.state.classes.single.rowIds, hasLength(GradeAnalysisCubit.newClassRows));
    expect(cubit.state.bands, _options.bands);
    expect(cubit.state.date, DateTime(2026, 10, 22));
    await cubit.close();
  });

  test('load fails when the options fail', () async {
    when(() => grades.getOptions()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = await loaded();

    expect(cubit.state.status, GradeAnalysisStatus.failure);
    await cubit.close();
  });

  test('the numbers wait for a total mark and a grade, then every change re-analyses', () async {
    final cubit = await loaded();
    expect(cubit.analysisIssue, 'grades_issue_total');

    cubit.totalMarkController.text = '20';
    expect(cubit.analysisIssue, 'grades_issue_no_grades');

    final revision = cubit.state.revision;
    type(cubit, [('أحمد', '18'), ('خالد', '')]);
    expect(cubit.state.revision, greaterThan(revision));
    expect(cubit.analysisIssue, isNull);
    expect(cubit.analysisInput()!['total_mark'], 20);

    type(cubit, [('أحمد', '25')]);
    expect(cubit.analysisIssue, 'grades_issue_invalid_grade');
    await cubit.close();
  });

  test('a pass mark above the total is refused', () async {
    final cubit = await loaded();
    cubit.totalMarkController.text = '20';
    cubit.passMarkController.text = '30';
    type(cubit, [('', '12')]);

    expect(cubit.analysisIssue, 'grades_issue_pass_mark');
    await cubit.close();
  });

  test('a detailed report needs names, and turns grade-only classes back into rows', () async {
    final cubit = await loaded();
    cubit.totalMarkController.text = '20';
    cubit.setGradesOnly(true);
    cubit.editor.classFields(cubit.state.active!.id).grades.text = '18\n12';
    expect(cubit.analysisIssue, isNull);

    cubit.setReportType(GradeReportTypes.detailed);
    expect(cubit.state.active!.gradesOnly, isFalse);
    expect(cubit.analysisIssue, 'grades_issue_names');

    cubit.setGradesOnly(true);
    expect(cubit.state.active!.gradesOnly, isFalse);
    await cubit.close();
  });

  test('up to five classes, each removable but the last one', () async {
    final cubit = await loaded();
    for (var i = 0; i < 6; i++) {
      cubit.addClass();
    }
    expect(cubit.state.classes, hasLength(5));
    expect(cubit.state.activeClass, 4);

    cubit.removeClass(4);
    expect(cubit.state.classes, hasLength(4));
    expect(cubit.state.activeClass, 3);
    await cubit.close();
  });

  test('«اختيار من فصولي» fills the names and the empty class details', () async {
    final cubit = await loaded();
    cubit.setClassStudents(
      const StudentPickerResult(classId: 3, className: 'رابع 1', subject: 'الرياضيات', students: ['سارة', 'نورة']),
    );

    final active = cubit.state.active!;
    expect(active.classId, 3);
    expect(cubit.editor.className(active), 'رابع 1');
    expect(cubit.subjectController.text, 'الرياضيات');
    expect(cubit.editor.students(active).map((s) => s.name), ['سارة', 'نورة']);
    await cubit.close();
  });

  test('an imported sheet comes back for review, then replaces the rows', () async {
    when(
      () => picker.pickSpreadsheet(),
    ).thenAnswer((_) async => DevicePickedFile(bytes: Uint8List(10), name: 'grades.xlsx', mime: null));
    const sheet = GradeSheetImport(
      rows: [GradeStudentInput(name: 'أحمد', grade: 18)],
      gradeColumn: 'المجموع',
    );
    when(() => grades.importSheet(any())).thenAnswer((_) async => const Right(sheet));
    final cubit = await loaded();
    final states = <GradeAnalysisState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.importSheet();
    await pumpEventQueue();
    expect(states.last.importedSheet, same(sheet));

    cubit.applyImport(sheet);
    expect(cubit.editor.students(cubit.state.active!).single.name, 'أحمد');
    await sub.cancel();
    await cubit.close();
  });

  test('levels stay highest first, the lowest starts at 0, and at least two remain', () async {
    final cubit = await loaded();
    cubit.addBand('مقبول', '60');
    expect(cubit.state.bands.map((b) => b.min), [90, 70, 60, 0]);

    cubit.setBand(3, 'بحاجة لدعم', '10');
    expect(cubit.state.bands.last.min, 0);

    cubit.addBand('', '50');
    expect(cubit.state.bands, hasLength(4));

    for (var i = 0; i < 5; i++) {
      cubit.removeBand(0);
    }
    expect(cubit.state.bands, hasLength(GradeLimits.minBands));

    cubit.resetBands();
    expect(cubit.state.bands, _options.bands);
    await cubit.close();
  });

  test('AI recommendations join unticked; only ticked ones are saved', () async {
    final cubit = await loaded();
    cubit.totalMarkController.text = '20';
    type(cubit, [('أحمد', '18')]);
    cubit.addSuggestions(['مراجعة الكسور', 'تدريب إضافي']);
    cubit.toggleRecommendation(1);
    cubit.addRecommendation('توصية المعلم');
    await cubit.save();

    expect(capturedCreateInput()['recommendations'], ['تدريب إضافي', 'توصية المعلم']);
    expect(cubit.state.documentId, 40);
    await cubit.close();
  });

  test('saving with an issue shows it and saves nothing', () async {
    final cubit = await loaded();
    final states = <GradeAnalysisState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.saveAndExport();

    expect(states.last.feedback?.message, 'grades_issue_total');
    verifyNever(
      () => documents.createDocument(
        type: any(named: 'type'),
        input: any(named: 'input'),
        status: any(named: 'status'),
      ),
    );
    await sub.cancel();
    await cubit.close();
  });

  test('save and export opens the export after the save', () async {
    final cubit = await loaded();
    cubit.totalMarkController.text = '20';
    type(cubit, [('', '15')]);
    final states = <GradeAnalysisState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.saveAndExport();
    await pumpEventQueue();

    expect(states.last.followUp, DocumentFollowUp.export);
    await sub.cancel();
    await cubit.close();
  });

  test('reopening fills the whole form from input', () async {
    when(() => documents.getDocument(7)).thenAnswer(
      (_) async => Right(
        _saved(
          7,
          input: {
            'report_type': 'quick',
            'test_name': 'اختبار الفترة الأولى',
            'total_mark': 20,
            'pass_mark': 12,
            'bands': [
              {'label': 'ممتاز', 'min': 90},
              {'label': 'غيره', 'min': 0},
            ],
            'classes': [
              {
                'name': 'رابع 1',
                'class_id': 3,
                'students': [
                  {'name': 'أحمد', 'grade': 18},
                  {'name': 'خالد', 'grade': null},
                ],
              },
              {
                'name': '',
                'students': [
                  {'name': '', 'grade': 14},
                ],
              },
            ],
            'recommendations': ['تعزيز'],
            'academic_year': '1448 هـ',
          },
        ),
      ),
    );
    final cubit = await loaded(documentId: 7);

    expect(cubit.testNameController.text, 'اختبار الفترة الأولى');
    expect(cubit.passMarkController.text, '12');
    expect(cubit.state.bands, hasLength(2));
    expect(cubit.state.classes, hasLength(2));
    expect(cubit.state.classes[0].classId, 3);
    expect(cubit.editor.students(cubit.state.classes[0]).map((s) => s.grade), [18, null]);
    expect(cubit.state.classes[1].gradesOnly, isTrue);
    expect(cubit.state.recommendations.checkedTexts, ['تعزيز']);
    expect(cubit.analysisInput()!['academic_year'], '1448 هـ');
    await cubit.close();
  });

  test('«حذف كل بيانات التحليل» forgets the deleted document', () async {
    when(() => grades.deleteAll()).thenAnswer((_) async => const Right(3));
    final cubit = await loaded();
    cubit.totalMarkController.text = '20';
    type(cubit, [('', '15')]);
    await cubit.save();
    expect(cubit.state.documentId, 40);

    await cubit.deleteAll();
    expect(cubit.state.documentId, isNull);
    await cubit.close();
  });
}
