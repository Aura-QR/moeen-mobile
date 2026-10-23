/// One past preparation in «تحضيراتي» (`GET /preparations`).
class PreparationItem {
  final int id;
  final String title;
  final String status;
  final DateTime? date;

  const PreparationItem({required this.id, required this.title, required this.status, this.date});

  bool get isDone => status == 'done';

  factory PreparationItem.fromJson(Map<String, dynamic> json) {
    final lesson = json['lesson'];
    final title = (json['lesson_title'] as String?) ??
        (lesson is Map<String, dynamic> ? lesson['title'] as String? : null) ??
        '';
    return PreparationItem(
      id: (json['id'] as num).toInt(),
      title: title,
      status: json['status'] as String? ?? '',
      date: DateTime.tryParse((json['completed_at'] ?? json['created_at'] ?? '') as String),
    );
  }
}

/// A page of preparations (Laravel paginator, not wrapped in `data`).
class PreparationsPage {
  final List<PreparationItem> items;
  final int currentPage;
  final int lastPage;

  const PreparationsPage({required this.items, required this.currentPage, required this.lastPage});

  factory PreparationsPage.fromJson(Map<String, dynamic> json) => PreparationsPage(
        items: (json['data'] as List? ?? []).whereType<Map<String, dynamic>>().map(PreparationItem.fromJson).toList(),
        currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      );
}

/// One printed section: a text, or a list of lines (strategies, tools).
class PrintSection {
  final String key;
  final String labelKey;
  final bool isList;

  const PrintSection(this.key, this.labelKey, {this.isList = false});

  /// Print order, as in the backend's LessonPreparationBuilder.
  static const List<PrintSection> all = [
    PrintSection('goals', 'prep_print_goals'),
    PrintSection('preparation_text', 'prep_print_preparation_text'),
    PrintSection('strategies', 'prep_print_strategies', isList: true),
    PrintSection('tools', 'prep_print_tools', isList: true),
    PrintSection('vocabulary', 'prep_print_vocabulary'),
    PrintSection('thinking_skills', 'prep_print_thinking_skills'),
    PrintSection('closure', 'prep_print_closure'),
    PrintSection('homework', 'prep_print_homework'),
    PrintSection('enrichment', 'prep_print_enrichment'),
    PrintSection('teacher_note', 'prep_print_teacher_note'),
  ];
}

/// One lesson of the `lesson_preparation` document's `input.lessons`. Kept as
/// a map so fields the app doesn't edit (e.g. `preparation_id`) are sent back.
class PrintLesson {
  final Map<String, dynamic> data;

  const PrintLesson(this.data);

  String text(String key) {
    final value = data[key];
    if (value is List) return value.whereType<String>().join('\n');
    return value is String ? value : '';
  }

  PrintLesson withText(String key, String value, {bool isList = false}) {
    final next = Map<String, dynamic>.from(data);
    next[key] = isList ? value.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).take(20).toList() : value;
    return PrintLesson(next);
  }
}
