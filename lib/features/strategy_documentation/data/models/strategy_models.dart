/// Models for `/tools/strategies` (DOCUMENTS_API.md § 5).
library;

/// The four editable lists, with the API's limits.
enum StrategyListSection {
  steps('steps', 12),
  teacherRole('teacher_role', 10),
  studentRole('student_role', 10),
  outcomes('outcomes', 10);

  const StrategyListSection(this.jsonKey, this.maxItems);

  final String jsonKey;
  final int maxItems;

  /// Characters per line.
  static const int maxItemLength = 300;

  String get titleKey => 'strategy_section_$jsonKey';
}

class StrategyCategoryModel {
  final String key;
  final String label;

  const StrategyCategoryModel({required this.key, required this.label});

  factory StrategyCategoryModel.fromJson(Map<String, dynamic> json) => StrategyCategoryModel(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );
}

class StrategySummaryModel {
  final String key;
  final String name;
  final String category;

  const StrategySummaryModel({required this.key, required this.name, required this.category});

  factory StrategySummaryModel.fromJson(Map<String, dynamic> json) => StrategySummaryModel(
        key: json['key']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
      );
}

class StrategyCatalogueModel {
  final List<StrategyCategoryModel> categories;
  final List<StrategySummaryModel> items;

  const StrategyCatalogueModel({this.categories = const [], this.items = const []});

  factory StrategyCatalogueModel.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    final items = json['items'];
    return StrategyCatalogueModel(
      categories: categories is List
          ? categories.whereType<Map<String, dynamic>>().map(StrategyCategoryModel.fromJson).toList()
          : const [],
      items: items is List
          ? items.whereType<Map<String, dynamic>>().map(StrategySummaryModel.fromJson).toList()
          : const [],
    );
  }

  StrategySummaryModel? byKey(String? key) => items.where((item) => item.key == key).firstOrNull;

  /// Categories in API order with the strategies whose name contains
  /// [query]; empty categories are left out.
  List<(StrategyCategoryModel, List<StrategySummaryModel>)> grouped(String query) {
    final q = query.trim();
    final groups = <(StrategyCategoryModel, List<StrategySummaryModel>)>[];
    for (final category in categories) {
      final matches = items.where((item) => item.category == category.key && item.name.contains(q)).toList();
      if (matches.isNotEmpty) groups.add((category, matches));
    }
    return groups;
  }
}

/// The full catalogue texts, used to prefill and to «استعادة النص الأصلي».
class StrategyDetailsModel {
  final String key;
  final String name;
  final String definition;
  final Map<StrategyListSection, List<String>> lists;

  const StrategyDetailsModel({
    required this.key,
    required this.name,
    required this.definition,
    required this.lists,
  });

  factory StrategyDetailsModel.fromJson(Map<String, dynamic> json) {
    return StrategyDetailsModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      definition: json['definition']?.toString() ?? '',
      lists: {
        for (final section in StrategyListSection.values) section: _strings(json[section.jsonKey]),
      },
    );
  }

  static List<String> _strings(dynamic value) =>
      value is List ? value.map((e) => e.toString()).toList() : const [];
}
