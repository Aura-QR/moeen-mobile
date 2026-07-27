class SavedReportModel {
  final int id;
  final String reportType;
  final String grade;
  final dynamic subject; // Can be String or List
  final List<String> selectedLessons;
  final Map<String, dynamic> reportData;
  final String createdAt;

  SavedReportModel({
    required this.id,
    required this.reportType,
    required this.grade,
    required this.subject,
    required this.selectedLessons,
    required this.reportData,
    required this.createdAt,
  });

  factory SavedReportModel.fromJson(Map<String, dynamic> json) {
    List<String> lessons = [];
    if (json['selected_lessons'] != null) {
      if (json['selected_lessons'] is List) {
        lessons = List<String>.from(json['selected_lessons'].map((e) => e.toString()));
      }
    }

    Map<String, dynamic> rData = {};
    if (json['report_data'] is Map<String, dynamic>) {
      rData = json['report_data'];
    }

    return SavedReportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reportType: json['report_type']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      subject: json['subject'] ?? '',
      selectedLessons: lessons,
      reportData: rData,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get displaySubject {
    if (subject is List) {
      return (subject as List).join('، ');
    }
    return subject?.toString() ?? '';
  }
}

class SavedReportsMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SavedReportsMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SavedReportsMeta.fromJson(Map<String, dynamic> json) {
    return SavedReportsMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }
}
