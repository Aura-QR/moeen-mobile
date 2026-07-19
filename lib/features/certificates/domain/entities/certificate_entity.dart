class CertificateEntity {
  final String studentName;
  final String gender;
  final String schoolName;
  final String className;
  final String directorName;
  final String teacherName;
  final String certDate;
  final String certText;
  final int templateIndex;

  const CertificateEntity({
    required this.studentName,
    required this.gender,
    required this.schoolName,
    required this.className,
    required this.directorName,
    required this.teacherName,
    required this.certDate,
    required this.certText,
    required this.templateIndex,
  });
}
