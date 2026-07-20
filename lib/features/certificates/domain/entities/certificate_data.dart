class CertificateData {
  final String studentName;
  final String schoolName;
  final String className;
  final String teacherName;
  final String principalName;
  final String certDate;
  final String certText;

  /// 'male' or 'female'
  final String gender;

  const CertificateData({
    required this.studentName,
    required this.schoolName,
    required this.className,
    required this.teacherName,
    required this.principalName,
    required this.certDate,
    required this.certText,
    required this.gender,
  });

  /// "للطالب" or "للطالبة" based on gender
  String get studentLabel => gender == 'female' ? 'للطالبة' : 'للطالب';
}
