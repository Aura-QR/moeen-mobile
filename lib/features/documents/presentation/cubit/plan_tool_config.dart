/// What differs between the plan tools that share [PlanFormCubit]
/// (DOCUMENTS_API.md § 8).
class PlanToolConfig {
  /// A [DocumentTypes] value.
  final String documentType;

  /// An [AiJobKinds] value.
  final String aiKind;

  /// Where the ready options come from, e.g. `remedialToolApi`.
  final String catalogueUrl;

  /// «نوع الخطة» (مرتبطة بدروس / عامة); without it the lessons are optional.
  final bool hasPlanType;

  /// «مستوى التحسن».
  final bool hasImprovement;

  /// «الفئة المستهدفة».
  final bool hasTargetGroups;

  const PlanToolConfig({
    required this.documentType,
    required this.aiKind,
    required this.catalogueUrl,
    this.hasPlanType = false,
    this.hasImprovement = false,
    this.hasTargetGroups = false,
  });

  /// «تحسين نتائج المتعلمين», preselected when adding to a portfolio.
  static const String portfolioItemKey = 'learner_results';

  static const int maxLessons = 5;
  static const int maxTargetGroups = 6;
  static const int maxTargetGroupLength = 60;
}
