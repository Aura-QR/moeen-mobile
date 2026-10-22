part of 'plan_form_cubit.dart';

enum PlanFormStatus { loading, success, failure }

class PlanFormState {
  /// The key [PlanFormCubit] uses for «الفئة المستهدفة» in its line methods.
  static const String targetGroupsKey = 'target_groups';

  final PlanFormStatus status;
  final String? errorMessage;

  /// Null until the first save; later saves PATCH it.
  final int? documentId;
  final PlanCatalogueModel catalogue;
  final DocumentDefaultsModel defaults;

  /// [PlanFormInput.linked] or [PlanFormInput.general]; null when the tool has no plan type.
  final String? planType;
  final List<PickedLessonModel> lessons;
  final DateTime? date;
  final int? classId;
  final List<String> students;
  final List<ChecklistSection> sections;
  final ChecklistSection targetGroups;
  final String improvement;
  final bool isOverridingHeader;
  final List<DocumentImageModel> images;
  final bool isUploadingImage;
  final DocumentTheme theme;

  /// «مسودة» or «نهائي».
  final String documentStatus;
  final bool isSaving;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;

  const PlanFormState({
    this.status = PlanFormStatus.loading,
    this.errorMessage,
    this.documentId,
    this.catalogue = const PlanCatalogueModel(),
    this.defaults = const DocumentDefaultsModel(),
    this.planType,
    this.lessons = const [],
    this.date,
    this.classId,
    this.students = const [],
    this.sections = const [],
    this.targetGroups = const ChecklistSection(key: targetGroupsKey, label: ''),
    this.improvement = '',
    this.isOverridingHeader = false,
    this.images = const [],
    this.isUploadingImage = false,
    this.theme = DocumentTheme.teal,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.followUp,
    this.feedback,
  });

  /// A general remedial plan has no lessons; every other plan may.
  bool get usesLessons => planType != PlanFormInput.general;

  /// The lessons to send and to ask the AI about.
  List<int> get aiLessonIds => usesLessons ? [for (final lesson in lessons) lesson.lessonId] : const [];

  ChecklistSection? sectionOf(String key) =>
      key == targetGroupsKey ? targetGroups : sections.where((section) => section.key == key).firstOrNull;

  PlanFormState copyWith({
    PlanFormStatus? status,
    String? errorMessage,
    int? documentId,
    PlanCatalogueModel? catalogue,
    DocumentDefaultsModel? defaults,
    String? planType,
    List<PickedLessonModel>? lessons,
    DateTime? date,
    int? classId,
    bool clearClassId = false,
    List<String>? students,
    List<ChecklistSection>? sections,
    ChecklistSection? targetGroups,
    String? improvement,
    bool? isOverridingHeader,
    List<DocumentImageModel>? images,
    bool? isUploadingImage,
    DocumentTheme? theme,
    String? documentStatus,
    bool? isSaving,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return PlanFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      documentId: documentId ?? this.documentId,
      catalogue: catalogue ?? this.catalogue,
      defaults: defaults ?? this.defaults,
      planType: planType ?? this.planType,
      lessons: lessons ?? this.lessons,
      date: date ?? this.date,
      classId: clearClassId ? null : (classId ?? this.classId),
      students: students ?? this.students,
      sections: sections ?? this.sections,
      targetGroups: targetGroups ?? this.targetGroups,
      improvement: improvement ?? this.improvement,
      isOverridingHeader: isOverridingHeader ?? this.isOverridingHeader,
      images: images ?? this.images,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      theme: theme ?? this.theme,
      documentStatus: documentStatus ?? this.documentStatus,
      isSaving: isSaving ?? this.isSaving,
      followUp: followUp,
      feedback: feedback,
    );
  }
}
