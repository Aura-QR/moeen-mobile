/// Models for `/me/document-defaults` (DOCUMENTS_API.md § 1).
library;

/// The header text fields every document starts from. A document can
/// override any of them in `input.header`.
enum DocumentHeaderField {
  teacherName('teacher_name', 120),
  schoolName('school_name', 200),
  principalName('principal_name', 120),
  deputyName('deputy_name', 120),
  educationDepartment('education_department', 200),
  educationOffice('education_office', 200);

  const DocumentHeaderField(this.jsonKey, this.maxLength);

  final String jsonKey;
  final int maxLength;

  String get labelKey => 'document_field_$jsonKey';
}

/// The two header logos, as `storage_path`s from `POST /documents/uploads`.
enum DocumentLogoSlot {
  right('logo_right'),
  left('logo_left');

  const DocumentLogoSlot(this.jsonKey);

  final String jsonKey;
}

/// «الصيغة»: drives «المعلم/المعلمة» and «مدير/مديرة المدرسة».
enum DocumentGenderForm {
  male,
  female;

  String get labelKey => 'document_gender_$name';

  static DocumentGenderForm fromJson(dynamic value) =>
      value == female.name ? female : male;
}

enum DocumentRegionCalendar {
  general,
  western;

  String get labelKey => 'document_calendar_$name';

  static DocumentRegionCalendar fromJson(dynamic value) =>
      value == western.name ? western : general;
}

class DocumentDefaultsModel {
  /// Only fields with a value.
  final Map<DocumentHeaderField, String> texts;
  final DocumentGenderForm genderForm;
  final DocumentRegionCalendar regionCalendar;
  final Map<DocumentLogoSlot, String> logos;

  const DocumentDefaultsModel({
    this.texts = const {},
    this.genderForm = DocumentGenderForm.male,
    this.regionCalendar = DocumentRegionCalendar.general,
    this.logos = const {},
  });

  String text(DocumentHeaderField field) => texts[field] ?? '';

  factory DocumentDefaultsModel.fromJson(Map<String, dynamic> json) {
    return DocumentDefaultsModel(
      texts: {
        for (final field in DocumentHeaderField.values)
          if (_filled(json[field.jsonKey])) field: json[field.jsonKey].toString().trim(),
      },
      genderForm: DocumentGenderForm.fromJson(json['gender_form']),
      regionCalendar: DocumentRegionCalendar.fromJson(json['region_calendar']),
      logos: {
        for (final slot in DocumentLogoSlot.values)
          if (_filled(json[slot.jsonKey])) slot: json[slot.jsonKey].toString(),
      },
    );
  }

  /// The whole form: `PUT` replaces the stored values, so empty fields are
  /// sent as null and fall back to the account.
  Map<String, dynamic> toJson() => {
        for (final field in DocumentHeaderField.values) field.jsonKey: texts[field],
        'gender_form': genderForm.name,
        'region_calendar': regionCalendar.name,
        for (final slot in DocumentLogoSlot.values) slot.jsonKey: logos[slot],
      };

  static bool _filled(dynamic value) => value != null && value.toString().trim().isNotEmpty;
}
