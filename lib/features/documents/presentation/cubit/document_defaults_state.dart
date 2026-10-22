part of 'document_defaults_cubit.dart';

enum DocumentDefaultsStatus { loading, success, failure }

class DocumentDefaultsState {
  final DocumentDefaultsStatus status;
  final String? errorMessage;
  final DocumentGenderForm genderForm;
  final DocumentRegionCalendar regionCalendar;

  /// `storage_path` per slot.
  final Map<DocumentLogoSlot, String> logos;

  /// Bytes of logos picked in this session; saved ones have no URL to show.
  final Map<DocumentLogoSlot, Uint8List> previews;
  final DocumentLogoSlot? uploadingSlot;
  final bool isSaving;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final UiFeedback? feedback;
  final bool saved;

  const DocumentDefaultsState({
    this.status = DocumentDefaultsStatus.loading,
    this.errorMessage,
    this.genderForm = DocumentGenderForm.male,
    this.regionCalendar = DocumentRegionCalendar.general,
    this.logos = const {},
    this.previews = const {},
    this.uploadingSlot,
    this.isSaving = false,
    this.feedback,
    this.saved = false,
  });

  DocumentDefaultsState copyWith({
    DocumentDefaultsStatus? status,
    String? errorMessage,
    DocumentGenderForm? genderForm,
    DocumentRegionCalendar? regionCalendar,
    Map<DocumentLogoSlot, String>? logos,
    Map<DocumentLogoSlot, Uint8List>? previews,
    DocumentLogoSlot? uploadingSlot,
    bool clearUploading = false,
    bool? isSaving,
    UiFeedback? feedback,
    bool saved = false,
  }) {
    return DocumentDefaultsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      genderForm: genderForm ?? this.genderForm,
      regionCalendar: regionCalendar ?? this.regionCalendar,
      logos: logos ?? this.logos,
      previews: previews ?? this.previews,
      uploadingSlot: clearUploading ? null : (uploadingSlot ?? this.uploadingSlot),
      isSaving: isSaving ?? this.isSaving,
      feedback: feedback,
      saved: saved,
    );
  }
}
