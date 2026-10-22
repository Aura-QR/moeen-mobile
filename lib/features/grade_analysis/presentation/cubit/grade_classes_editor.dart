import 'package:flutter/widgets.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_input.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_form_fields.dart';

/// Keeps the text fields of every class and student, owned by the grade
/// analysis cubit. Each change returns a new [GradeClassLayout] for the
/// state; typing calls [onChanged].
class GradeClassesEditor {
  GradeClassesEditor({required this.onChanged});

  final VoidCallback onChanged;
  final Map<int, GradeClassFields> _classes = {};
  final Map<int, GradeRowFields> _rows = {};
  int _nextId = 0;

  GradeClassFields classFields(int classId) => _classes[classId]!;

  GradeRowFields row(int rowId) => _rows[rowId]!;

  GradeClassLayout create(GradeClassInput input, {bool gradesOnly = false}) {
    final id = _nextId++;
    _classes[id] = GradeClassFields(name: input.name, grades: gradesOnly ? _gradeText(input.students) : '')
      ..listen(onChanged);
    return GradeClassLayout(
      id: id,
      rowIds: gradesOnly ? const [] : _newRows(input.students),
      gradesOnly: gradesOnly,
      classId: input.classId,
    );
  }

  void remove(GradeClassLayout layout) {
    _classes.remove(layout.id)?.dispose();
    _disposeRows(layout.rowIds);
  }

  GradeClassLayout addRow(GradeClassLayout layout) => layout.copyWith(
    rowIds: [
      ...layout.rowIds,
      ..._newRows(const [GradeStudentInput()]),
    ],
  );

  GradeClassLayout removeRow(GradeClassLayout layout, int rowId) {
    _disposeRows([rowId]);
    return layout.copyWith(rowIds: layout.rowIds.where((id) => id != rowId).toList());
  }

  /// New rows for [students]. When [keepGrades], a name already in the class keeps its grade.
  GradeClassLayout replaceRows(
    GradeClassLayout layout,
    List<GradeStudentInput> students, {
    bool keepGrades = false,
    int? classId,
  }) {
    final grades = {
      if (keepGrades)
        for (final student in this.students(layout))
          if (student.name.isNotEmpty) student.name: student.grade,
    };
    final rows = [
      for (final student in students)
        GradeStudentInput(name: student.name, grade: student.grade ?? grades[student.name]),
    ];
    _disposeRows(layout.rowIds);
    _classes[layout.id]!.grades.clear();
    return layout.copyWith(rowIds: _newRows(rows), gradesOnly: false, classId: classId, clearClassId: classId == null);
  }

  /// Switches between rows and one grade per line. Going to lines drops the names.
  GradeClassLayout setGradesOnly(GradeClassLayout layout, bool gradesOnly) {
    if (layout.gradesOnly == gradesOnly) return layout;
    final fields = _classes[layout.id]!;
    if (gradesOnly) {
      fields.grades.text = _gradeText(students(layout));
      _disposeRows(layout.rowIds);
      return layout.copyWith(rowIds: const [], gradesOnly: true, clearClassId: true);
    }
    final rows = [for (final line in gradeLines(fields.grades.text)) GradeStudentInput(grade: parseGrade(line))];
    fields.grades.clear();
    return layout.copyWith(rowIds: _newRows(rows), gradesOnly: false);
  }

  String className(GradeClassLayout layout) => _classes[layout.id]!.name.text.trim();

  /// The rows to send. A row with no name and no grade is left out.
  List<GradeStudentInput> students(GradeClassLayout layout) {
    if (layout.gradesOnly) {
      return [
        for (final line in gradeLines(_classes[layout.id]!.grades.text)) GradeStudentInput(grade: parseGrade(line)),
      ];
    }
    return [
      for (final id in layout.rowIds)
        if (_rows[id]!.name.text.trim().isNotEmpty || _rows[id]!.grade.text.trim().isNotEmpty)
          GradeStudentInput(name: _rows[id]!.name.text.trim(), grade: parseGrade(_rows[id]!.grade.text)),
    ];
  }

  GradeClassInput build(GradeClassLayout layout) =>
      GradeClassInput(name: className(layout), classId: layout.classId, students: students(layout));

  /// Why the class can't be analysed yet, as a translation key, or null.
  String? issue(GradeClassLayout layout, {required double? total, required bool namesRequired}) {
    final texts = layout.gradesOnly
        ? gradeLines(_classes[layout.id]!.grades.text)
        : [for (final id in layout.rowIds) _rows[id]!.grade.text];
    if (texts.any((text) => gradeError(text, total) != null)) return 'grades_issue_invalid_grade';
    final rows = students(layout);
    if (!rows.any((row) => row.grade != null)) return 'grades_issue_no_grades';
    if (namesRequired && (layout.gradesOnly || rows.any((row) => row.name.isEmpty))) return 'grades_issue_names';
    return null;
  }

  /// The grade field after [rowId]'s, or null on the last row.
  FocusNode? nextGradeFocus(GradeClassLayout layout, int rowId) {
    final index = layout.rowIds.indexOf(rowId);
    if (index < 0 || index + 1 >= layout.rowIds.length) return null;
    return _rows[layout.rowIds[index + 1]]!.gradeFocus;
  }

  void dispose() {
    for (final fields in _classes.values) {
      fields.dispose();
    }
    for (final fields in _rows.values) {
      fields.dispose();
    }
  }

  List<int> _newRows(List<GradeStudentInput> students) => [
    for (final student in students)
      _add(GradeRowFields(name: student.name, grade: student.grade == null ? '' : formatGrade(student.grade!))),
  ];

  int _add(GradeRowFields fields) {
    final id = _nextId++;
    _rows[id] = fields..listen(onChanged);
    return id;
  }

  void _disposeRows(Iterable<int> ids) {
    for (final id in ids) {
      _rows.remove(id)?.dispose();
    }
  }

  static String _gradeText(List<GradeStudentInput> students) => [
    for (final student in students)
      if (student.grade != null) formatGrade(student.grade!),
  ].join('\n');
}

extension on GradeRowFields {
  void listen(VoidCallback onChanged) {
    name.addListener(onChanged);
    grade.addListener(onChanged);
  }
}

extension on GradeClassFields {
  void listen(VoidCallback onChanged) {
    name.addListener(onChanged);
    grades.addListener(onChanged);
  }
}
