/// Models and portfolio-role matching for L1 «حقائب الأدوار» (DOCUMENTS_API.md § 13).
library;

import 'package:equatable/equatable.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

class RoleSuiteSummary extends Equatable {
  final String key;
  final String label;
  final String description;
  final int documentsCount;

  const RoleSuiteSummary({
    required this.key,
    required this.label,
    this.description = '',
    required this.documentsCount,
  });

  factory RoleSuiteSummary.fromJson(Map<String, dynamic> json) {
    return RoleSuiteSummary(
      key: (json['key'] ?? json['role'] ?? '').toString(),
      label: (json['label'] ?? json['title'] ?? '').toString(),
      description: json['description']?.toString() ?? '',
      documentsCount: _readInt(json['documents_count'] ?? json['count'], 0),
    );
  }

  @override
  List<Object?> get props => [key, label, description, documentsCount];
}

class RoleDocumentSummary extends Equatable {
  final String key;
  final String label;
  final String type;
  final bool ai;
  final bool sensitive;
  final String description;

  const RoleDocumentSummary({
    required this.key,
    required this.label,
    this.type = DocumentTypes.report,
    this.ai = false,
    this.sensitive = false,
    this.description = '',
  });

  factory RoleDocumentSummary.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? '';
    return RoleDocumentSummary(
      key: (json['key'] ?? json['doc'] ?? '').toString(),
      label: (json['label'] ?? json['title'] ?? '').toString(),
      type: rawType.isEmpty ? DocumentTypes.report : rawType,
      ai: json['ai'] == true,
      sensitive: json['sensitive'] == true,
      description: json['description']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [key, label, type, ai, sensitive, description];
}

class RoleCategoryModel extends Equatable {
  final String key;
  final String label;
  final List<RoleDocumentSummary> documents;

  const RoleCategoryModel({
    required this.key,
    required this.label,
    required this.documents,
  });

  factory RoleCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['documents'] ?? json['items'];
    return RoleCategoryModel(
      key: json['key']?.toString() ?? '',
      label: (json['label'] ?? json['title'] ?? '').toString(),
      documents: rawDocs is List
          ? rawDocs
                .whereType<Map>()
                .map((d) => RoleDocumentSummary.fromJson(Map<String, dynamic>.from(d)))
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [key, label, documents];
}

class RoleSuiteDetailModel extends Equatable {
  final String key;
  final String label;
  final List<RoleCategoryModel> categories;

  const RoleSuiteDetailModel({
    required this.key,
    required this.label,
    required this.categories,
  });

  factory RoleSuiteDetailModel.fromJson(Map<String, dynamic> json, {String fallbackKey = ''}) {
    final rawCategories = json['categories'];
    final key = (json['key'] ?? json['role'] ?? '').toString();
    return RoleSuiteDetailModel(
      key: key.isEmpty ? fallbackKey : key,
      label: (json['label'] ?? json['title'] ?? '').toString(),
      categories: rawCategories is List
          ? rawCategories
                .whereType<Map>()
                .map((c) => RoleCategoryModel.fromJson(Map<String, dynamic>.from(c)))
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [key, label, categories];
}

/// Full starter payload returned by `GET /tools/roles/{role}/{doc}`.
class RoleDocumentTemplateModel extends Equatable {
  final String role;
  final String doc;
  final String label;
  final String type;
  final String? element;
  final bool ai;
  final String briefHint;
  final bool sensitive;

  /// Column index (0-based `int`) or header name (`String`) for member lists / sign-in sheets.
  final Object? namesColumn;

  /// Kept from the response for weekly-plan `role_document` AI jobs.
  final Object? term;
  final Object? region;

  /// Starter `input` for T8 (`report`) or T3 (`certificates`).
  final Map<String, dynamic> input;

  const RoleDocumentTemplateModel({
    required this.role,
    required this.doc,
    this.label = '',
    this.type = DocumentTypes.report,
    this.element,
    this.ai = false,
    this.briefHint = '',
    this.sensitive = false,
    this.namesColumn,
    this.term,
    this.region,
    this.input = const {},
  });

  factory RoleDocumentTemplateModel.fromJson(
    Map<String, dynamic> json, {
    required String fallbackRole,
    required String fallbackDoc,
  }) {
    final rawInput = json['input'];
    final inputMap = rawInput is Map ? Map<String, dynamic>.from(rawInput) : const <String, dynamic>{};
    final rawRole = (json['role'] ?? inputMap['role'] ?? '').toString();
    final rawDoc = (json['doc'] ?? json['key'] ?? inputMap['doc'] ?? '').toString();
    final rawType = json['type']?.toString() ?? '';
    final rawElement = json['element']?.toString();
    return RoleDocumentTemplateModel(
      role: rawRole.isEmpty ? fallbackRole : rawRole,
      doc: rawDoc.isEmpty ? fallbackDoc : rawDoc,
      label: (json['label'] ?? json['title'] ?? inputMap['title'] ?? '').toString(),
      type: rawType.isEmpty ? DocumentTypes.report : rawType,
      element: rawElement == null || rawElement.trim().isEmpty ? null : rawElement.trim(),
      ai: json['ai'] == true || inputMap['ai'] == true,
      briefHint: (json['brief_hint'] ?? inputMap['brief_hint'] ?? '').toString(),
      sensitive: json['sensitive'] == true || inputMap['sensitive'] == true,
      namesColumn: json['names_column'] ?? inputMap['names_column'],
      term: json['term'] ?? inputMap['term'],
      region: json['region'] ?? inputMap['region'],
      input: inputMap,
    );
  }

  @override
  List<Object?> get props => [
        role,
        doc,
        label,
        type,
        element,
        ai,
        briefHint,
        sensitive,
        namesColumn,
        term,
        region,
        input,
      ];
}

/// Maps a portfolio role key (`PORTFOLIO_AND_ACHIEVEMENTS_API.md`) to its L1 role suite key.
String? roleSuiteKeyForPortfolioRole(String? portfolioRole) {
  final trimmed = portfolioRole?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return switch (trimmed) {
    'activity_leader' => 'activity_leader',
    'health_guide' => 'health_guide',
    'student_counselor' || 'student_counsellor' => 'student_counsellor',
    'vice_principal' => 'vice_principal',
    _ => null,
  };
}

/// Returns the first [RoleSuiteSummary.key] in [roles] matching one of [portfolioRoles], or null.
String? matchedRoleSuiteKey(List<RoleSuiteSummary> roles, Iterable<String> portfolioRoles) {
  final mapped = portfolioRoles.map(roleSuiteKeyForPortfolioRole).whereType<String>().toSet();
  if (mapped.isEmpty) return null;
  for (final role in roles) {
    if (mapped.contains(role.key)) return role.key;
  }
  return null;
}

/// Moves the teacher's matching portfolio role card to the front while preserving order.
List<RoleSuiteSummary> sortRolesByPortfolio(
  List<RoleSuiteSummary> roles,
  Iterable<String> portfolioRoles,
) {
  final match = matchedRoleSuiteKey(roles, portfolioRoles);
  if (match == null) return List<RoleSuiteSummary>.unmodifiable(roles);
  final first = roles.where((r) => r.key == match);
  final rest = roles.where((r) => r.key != match);
  return List<RoleSuiteSummary>.unmodifiable([...first, ...rest]);
}

List<RoleSuiteSummary> parseRoleSuitesList(dynamic data) {
  final dynamic list = data is List
      ? data
      : (data is Map ? (data['roles'] ?? data['items'] ?? data['data']) : null);
  if (list is! List) return const [];
  return list
      .whereType<Map>()
      .map((item) => RoleSuiteSummary.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

int _readInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
