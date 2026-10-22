import 'package:flutter/widgets.dart';

/// One student's name and grade fields. The grade's focus lets «التالي»
/// jump straight to the next student's grade.
class GradeRowFields {
  GradeRowFields({String name = '', String grade = ''})
    : name = TextEditingController(text: name),
      grade = TextEditingController(text: grade);

  final TextEditingController name;
  final TextEditingController grade;
  final FocusNode gradeFocus = FocusNode();

  void dispose() {
    name.dispose();
    grade.dispose();
    gradeFocus.dispose();
  }
}

/// A class's name, and its «إدخال الدرجات فقط» box (one grade per line).
class GradeClassFields {
  GradeClassFields({String name = '', String grades = ''})
    : name = TextEditingController(text: name),
      grades = TextEditingController(text: grades);

  final TextEditingController name;
  final TextEditingController grades;

  void dispose() {
    name.dispose();
    grades.dispose();
  }
}

/// A class tab as the state sees it: which rows it has, in order. The
/// text lives in the fields the editor keeps for [id] and each of [rowIds].
class GradeClassLayout {
  final int id;
  final List<int> rowIds;

  /// «إدخال الدرجات فقط»: grades without names, quick reports only.
  final bool gradesOnly;

  /// The «فصولي» class the names came from.
  final int? classId;

  const GradeClassLayout({required this.id, this.rowIds = const [], this.gradesOnly = false, this.classId});

  GradeClassLayout copyWith({List<int>? rowIds, bool? gradesOnly, int? classId, bool clearClassId = false}) =>
      GradeClassLayout(
        id: id,
        rowIds: rowIds ?? this.rowIds,
        gradesOnly: gradesOnly ?? this.gradesOnly,
        classId: clearClassId ? null : (classId ?? this.classId),
      );
}
