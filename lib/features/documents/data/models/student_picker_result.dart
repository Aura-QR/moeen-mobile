/// What the student picker returns: the names, and the «فصولي» class they
/// came from (null for typed names), to prefill the form and reopen the picker.
class StudentPickerResult {
  final int? classId;
  final String className;
  final String grade;
  final String subject;
  final List<String> students;

  const StudentPickerResult({
    this.classId,
    this.className = '',
    this.grade = '',
    this.subject = '',
    required this.students,
  });
}
