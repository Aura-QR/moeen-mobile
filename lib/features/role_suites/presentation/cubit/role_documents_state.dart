part of 'role_documents_cubit.dart';

enum RoleDocumentsStatus { loading, success, failure }

class RoleDocumentsState {
  final RoleDocumentsStatus status;
  final String roleKey;
  final String roleLabel;
  final List<RoleCategoryModel> categories;
  final int? selectedCategoryIndex;
  final String searchQuery;
  final String? openingDocKey;
  final String? errorMessage;

  /// One-shot fields cleared unless explicitly passed to [copyWith].
  final RoleDocumentTemplateModel? openedTemplate;
  final UiFeedback? feedback;

  const RoleDocumentsState({
    this.status = RoleDocumentsStatus.loading,
    required this.roleKey,
    this.roleLabel = '',
    this.categories = const [],
    this.selectedCategoryIndex,
    this.searchQuery = '',
    this.openingDocKey,
    this.errorMessage,
    this.openedTemplate,
    this.feedback,
  });

  bool get isOpening => openingDocKey != null;

  /// Categories and documents filtered by [selectedCategoryIndex] and [searchQuery].
  List<RoleCategoryModel> get visibleCategories {
    final scoped = selectedCategoryIndex != null && selectedCategoryIndex! < categories.length
        ? [categories[selectedCategoryIndex!]]
        : categories;
    final needle = searchQuery.trim().toLowerCase();
    if (needle.isEmpty) return scoped;
    return [
      for (final category in scoped)
        if (category.documents.any((doc) => doc.label.toLowerCase().contains(needle)))
          RoleCategoryModel(
            key: category.key,
            label: category.label,
            documents: category.documents.where((doc) => doc.label.toLowerCase().contains(needle)).toList(),
          ),
    ];
  }

  RoleDocumentsState copyWith({
    RoleDocumentsStatus? status,
    String? roleLabel,
    List<RoleCategoryModel>? categories,
    int? selectedCategoryIndex,
    bool clearSelectedCategory = false,
    String? searchQuery,
    String? openingDocKey,
    bool clearOpeningDoc = false,
    String? errorMessage,
    RoleDocumentTemplateModel? openedTemplate,
    UiFeedback? feedback,
  }) {
    return RoleDocumentsState(
      status: status ?? this.status,
      roleKey: roleKey,
      roleLabel: roleLabel ?? this.roleLabel,
      categories: categories ?? this.categories,
      selectedCategoryIndex: clearSelectedCategory
          ? null
          : (selectedCategoryIndex ?? this.selectedCategoryIndex),
      searchQuery: searchQuery ?? this.searchQuery,
      openingDocKey: clearOpeningDoc ? null : (openingDocKey ?? this.openingDocKey),
      errorMessage: errorMessage ?? this.errorMessage,
      openedTemplate: openedTemplate,
      feedback: feedback,
    );
  }
}
