part of 'certificates_cubit.dart';

enum CertificatesStatus { loading, success, failure }

class CertificatesState {
  final CertificatesStatus status;
  final String? errorMessage;

  /// Null until the first save; later saves PATCH it.
  final int? documentId;
  final CertificatesCatalogueModel catalogue;
  final DocumentDefaultsModel defaults;

  /// One certificate per name, in this order.
  final List<String> names;

  /// The «فصولي» class the names came from, to reopen the picker.
  final int? classId;
  final String audience;
  final String? reason;
  final String? design;

  /// Null prints no date.
  final DateTime? date;
  final bool isImporting;
  final bool isOverridingHeader;
  final bool isSaving;

  /// Grows with every change the preview shows, so the screen re-renders it.
  final int revision;

  /// One-shot fields, cleared by [copyWith] unless passed.
  /// [importedNames] are the names read from Excel, for review.
  final List<String>? importedNames;
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;

  const CertificatesState({
    this.status = CertificatesStatus.loading,
    this.errorMessage,
    this.documentId,
    this.catalogue = const CertificatesCatalogueModel(),
    this.defaults = const DocumentDefaultsModel(),
    this.names = const [],
    this.classId,
    this.audience = '',
    this.reason,
    this.design,
    this.date,
    this.isImporting = false,
    this.isOverridingHeader = false,
    this.isSaving = false,
    this.revision = 0,
    this.importedNames,
    this.followUp,
    this.feedback,
  });

  CertificateReasonModel? get reasonModel => catalogue.reasonOf(reason);

  /// The reason's title and text for the audience: what an untouched form shows.
  String get defaultTitle => reasonModel?.title ?? '';
  String get defaultText => reasonModel?.textFor(audience) ?? '';

  bool get isFull => names.length >= catalogue.limits.names;

  CertificatesState copyWith({
    CertificatesStatus? status,
    String? errorMessage,
    int? documentId,
    CertificatesCatalogueModel? catalogue,
    DocumentDefaultsModel? defaults,
    List<String>? names,
    int? classId,
    bool clearClassId = false,
    String? audience,
    String? reason,
    String? design,
    DateTime? date,
    bool clearDate = false,
    bool? isImporting,
    bool? isOverridingHeader,
    bool? isSaving,
    int? revision,
    List<String>? importedNames,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return CertificatesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      documentId: documentId ?? this.documentId,
      catalogue: catalogue ?? this.catalogue,
      defaults: defaults ?? this.defaults,
      names: names ?? this.names,
      classId: clearClassId ? null : (classId ?? this.classId),
      audience: audience ?? this.audience,
      reason: reason ?? this.reason,
      design: design ?? this.design,
      date: clearDate ? null : (date ?? this.date),
      isImporting: isImporting ?? this.isImporting,
      isOverridingHeader: isOverridingHeader ?? this.isOverridingHeader,
      isSaving: isSaving ?? this.isSaving,
      revision: revision ?? this.revision,
      importedNames: importedNames,
      followUp: followUp,
      feedback: feedback,
    );
  }
}
