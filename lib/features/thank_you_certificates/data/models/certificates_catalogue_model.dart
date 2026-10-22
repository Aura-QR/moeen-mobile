/// `GET /tools/certificates` (DOCUMENTS_API.md § 10).
library;

/// `male` (طلاب) or `female` (طالبات).
class CertificateAudienceModel {
  final String key;
  final String label;

  const CertificateAudienceModel({required this.key, required this.label});

  factory CertificateAudienceModel.fromJson(Map<String, dynamic> json) =>
      CertificateAudienceModel(key: json['key']?.toString() ?? '', label: json['label']?.toString() ?? '');
}

/// A reason, e.g. «التفوق الدراسي», with its default title and text per audience.
class CertificateReasonModel {
  final String key;
  final String label;
  final String title;

  /// Audience key → the default text, with `{name}`.
  final Map<String, String> texts;

  const CertificateReasonModel({required this.key, required this.label, this.title = '', this.texts = const {}});

  String textFor(String audience) => texts[audience] ?? texts.values.firstOrNull ?? '';

  factory CertificateReasonModel.fromJson(Map<String, dynamic> json) {
    final texts = json['text'];
    return CertificateReasonModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      texts: texts is Map
          ? {for (final entry in texts.entries) entry.key.toString(): entry.value?.toString() ?? ''}
          : const {},
    );
  }
}

/// One of the six backgrounds. [imageUrl] is public, so it loads without a token.
class CertificateDesignModel {
  final String key;
  final String label;
  final String imageUrl;

  const CertificateDesignModel({required this.key, required this.label, required this.imageUrl});

  factory CertificateDesignModel.fromJson(Map<String, dynamic> json) => CertificateDesignModel(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    imageUrl: json['image_url']?.toString() ?? '',
  );
}

class CertificatesLimits {
  final int names;
  final int textChars;
  final int titleChars;

  const CertificatesLimits({this.names = 80, this.textChars = 300, this.titleChars = 60});

  factory CertificatesLimits.fromJson(Map<String, dynamic> json) => CertificatesLimits(
    names: int.tryParse('${json['names']}') ?? 80,
    textChars: int.tryParse('${json['text_chars']}') ?? 300,
    titleChars: int.tryParse('${json['title_chars']}') ?? 60,
  );
}

class CertificatesCatalogueModel {
  final List<CertificateAudienceModel> audiences;
  final List<CertificateReasonModel> reasons;
  final List<CertificateDesignModel> designs;
  final CertificatesLimits limits;

  const CertificatesCatalogueModel({
    this.audiences = const [],
    this.reasons = const [],
    this.designs = const [],
    this.limits = const CertificatesLimits(),
  });

  CertificateReasonModel? reasonOf(String? key) => reasons.where((reason) => reason.key == key).firstOrNull;

  factory CertificatesCatalogueModel.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final value = json[key];
      return value is List ? value.whereType<Map<String, dynamic>>().map(parse).toList() : <T>[];
    }

    final limits = json['limits'];
    return CertificatesCatalogueModel(
      audiences: list('audiences', CertificateAudienceModel.fromJson),
      reasons: list('reasons', CertificateReasonModel.fromJson),
      designs: list('designs', CertificateDesignModel.fromJson),
      limits: limits is Map<String, dynamic> ? CertificatesLimits.fromJson(limits) : const CertificatesLimits(),
    );
  }
}
