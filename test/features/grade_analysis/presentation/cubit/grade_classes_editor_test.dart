import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_classes_editor.dart';

void main() {
  late GradeClassesEditor editor;
  var changes = 0;

  setUp(() {
    changes = 0;
    editor = GradeClassesEditor(onChanged: () => changes++);
  });

  tearDown(() => editor.dispose());

  test('rows with neither a name nor a grade are left out; an empty grade is absent', () {
    final layout = editor.create(
      const GradeClassInput(
        students: [
          GradeStudentInput(name: 'أحمد', grade: 18),
          GradeStudentInput(name: 'خالد'),
          GradeStudentInput(),
        ],
      ),
    );

    expect(editor.students(layout).map((s) => (s.name, s.grade)), [('أحمد', 18.0), ('خالد', null)]);
  });

  test('typing in a field reports a change', () {
    final layout = editor.create(const GradeClassInput(students: [GradeStudentInput()]));
    editor.row(layout.rowIds.single).grade.text = '١٥';

    expect(changes, 1);
    expect(editor.students(layout).single.grade, 15);
  });

  test('grades only: one grade per line, and back to rows without names', () {
    var layout = editor.create(
      const GradeClassInput(
        students: [
          GradeStudentInput(name: 'أحمد', grade: 18),
          GradeStudentInput(name: 'خالد'),
        ],
      ),
    );
    layout = editor.setGradesOnly(layout, true);

    expect(editor.classFields(layout.id).grades.text, '18');
    editor.classFields(layout.id).grades.text = '18\n15.5';
    expect(editor.students(layout).map((s) => s.grade), [18, 15.5]);

    layout = editor.setGradesOnly(layout, false);
    expect(layout.rowIds, hasLength(2));
    expect(editor.students(layout).map((s) => s.name), ['', '']);
  });

  test('picked names keep the grades already typed for them', () {
    var layout = editor.create(const GradeClassInput(students: [GradeStudentInput(name: 'سارة', grade: 17)]));
    layout = editor.replaceRows(
      layout,
      const [GradeStudentInput(name: 'نورة'), GradeStudentInput(name: 'سارة')],
      keepGrades: true,
      classId: 4,
    );

    expect(layout.classId, 4);
    expect(editor.students(layout).map((s) => (s.name, s.grade)), [('نورة', null), ('سارة', 17.0)]);
  });

  group('issue', () {
    test('a grade above the total blocks the analysis', () {
      final layout = editor.create(const GradeClassInput(students: [GradeStudentInput(name: 'أحمد', grade: 25)]));
      expect(editor.issue(layout, total: 20, namesRequired: false), 'grades_issue_invalid_grade');
    });

    test('a class needs one grade', () {
      final layout = editor.create(const GradeClassInput(students: [GradeStudentInput(name: 'أحمد')]));
      expect(editor.issue(layout, total: 20, namesRequired: false), 'grades_issue_no_grades');
    });

    test('a detailed report needs every name', () {
      final layout = editor.create(const GradeClassInput(students: [GradeStudentInput(grade: 12)]));
      expect(editor.issue(layout, total: 20, namesRequired: true), 'grades_issue_names');
      expect(editor.issue(layout, total: 20, namesRequired: false), isNull);
    });
  });

  test('«التالي» goes to the next grade, and stops on the last row', () {
    final layout = editor.create(const GradeClassInput(students: [GradeStudentInput(), GradeStudentInput()]));

    expect(editor.nextGradeFocus(layout, layout.rowIds.first), editor.row(layout.rowIds.last).gradeFocus);
    expect(editor.nextGradeFocus(layout, layout.rowIds.last), isNull);
  });
}
