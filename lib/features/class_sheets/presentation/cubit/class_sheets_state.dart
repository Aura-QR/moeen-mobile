import 'package:moean/features/class_sheets/data/models/class_sheet_column.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_input.dart';
import 'package:moean/features/class_sheets/data/models/class_sheets_catalogue_model.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

enum ClassSheetsStatus { initial, loading, success, failure, saving }

class ClassSheetsState {
  final ClassSheetsStatus status;
  final String? errorMessage;
  final List<SheetKindModel> kinds;
  final SheetKindModel selectedKind;
  final ClassSheetInput input;
  final List<SchoolClassModel> classes;
  final bool isLoadingClasses;
  final int? savedDocumentId;
  final DocumentFollowUp? followUp;
  final String? feedbackMessage;
  final bool isErrorFeedback;

  const ClassSheetsState({
    this.status = ClassSheetsStatus.initial,
    this.errorMessage,
    this.kinds = SheetKindModel.fallbackKinds,
    this.selectedKind = SheetKindModel.defaultKind,
    this.input = const ClassSheetInput(
      kind: 'grades',
      columns: [
        ClassSheetColumn(label: 'المشاركة', max: 10),
        ClassSheetColumn(label: 'الواجبات', max: 10),
        ClassSheetColumn(label: 'المهام الأدائية', max: 10),
        ClassSheetColumn(label: 'اختبار قصير 1', max: 10),
        ClassSheetColumn(label: 'اختبار قصير 2', max: 10),
        ClassSheetColumn(label: 'المجموع', max: 50),
      ],
    ),
    this.classes = const [],
    this.isLoadingClasses = false,
    this.savedDocumentId,
    this.followUp,
    this.feedbackMessage,
    this.isErrorFeedback = false,
  });

  bool get isLoading => status == ClassSheetsStatus.loading;
  bool get isSaving => status == ClassSheetsStatus.saving;
  bool get isLandscape => selectedKind.isLandscape;

  ClassSheetsState copyWith({
    ClassSheetsStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<SheetKindModel>? kinds,
    SheetKindModel? selectedKind,
    ClassSheetInput? input,
    List<SchoolClassModel>? classes,
    bool? isLoadingClasses,
    int? savedDocumentId,
    DocumentFollowUp? followUp,
    bool clearFollowUp = false,
    String? feedbackMessage,
    bool? isErrorFeedback,
    bool clearFeedback = false,
  }) =>
      ClassSheetsState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        kinds: kinds ?? this.kinds,
        selectedKind: selectedKind ?? this.selectedKind,
        input: input ?? this.input,
        classes: classes ?? this.classes,
        isLoadingClasses: isLoadingClasses ?? this.isLoadingClasses,
        savedDocumentId: savedDocumentId ?? this.savedDocumentId,
        followUp: clearFollowUp ? null : (followUp ?? this.followUp),
        feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        isErrorFeedback: isErrorFeedback ?? this.isErrorFeedback,
      );
}
