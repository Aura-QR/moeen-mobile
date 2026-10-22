/// Models for `/portfolios` responses.
/// See PORTFOLIO_AND_ACHIEVEMENTS_API.md § 1.
library;

class PortfolioModel {
  final int id;
  final String title;
  final String role;
  final String roleLabel;
  final bool isPublic;
  final PortfolioCompletionModel completion;
  final DateTime? updatedAt;

  /// Only present on the full portfolio, not on list summaries.
  final PortfolioProfileModel? profile;
  final String? shareUrl;
  final List<PortfolioItemModel> items;

  const PortfolioModel({
    required this.id,
    required this.title,
    required this.role,
    required this.roleLabel,
    required this.isPublic,
    required this.completion,
    this.updatedAt,
    this.profile,
    this.shareUrl,
    this.items = const [],
  });

  List<PortfolioItemModel> get includedItems =>
      items.where((item) => item.included).toList();

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final itemsJson = json['items'];
    final items = itemsJson is List
        ? itemsJson
            .whereType<Map<String, dynamic>>()
            .map(PortfolioItemModel.fromJson)
            .toList()
        : <PortfolioItemModel>[];
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return PortfolioModel(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roleLabel: json['role_label']?.toString() ?? '',
      isPublic: json['is_public'] == true,
      completion: PortfolioCompletionModel.fromJson(
        json['completion'] is Map<String, dynamic>
            ? json['completion'] as Map<String, dynamic>
            : const {},
      ),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      profile: profileJson is Map<String, dynamic>
          ? PortfolioProfileModel.fromJson(profileJson)
          : null,
      shareUrl: json['share_url']?.toString(),
      items: items,
    );
  }

  PortfolioModel copyWith({
    bool? isPublic,
    String? shareUrl,
    bool clearShareUrl = false,
    List<PortfolioItemModel>? items,
  }) {
    return PortfolioModel(
      id: id,
      title: title,
      role: role,
      roleLabel: roleLabel,
      isPublic: isPublic ?? this.isPublic,
      completion: completion,
      updatedAt: updatedAt,
      profile: profile,
      shareUrl: clearShareUrl ? null : (shareUrl ?? this.shareUrl),
      items: items ?? this.items,
    );
  }
}

class PortfolioCompletionModel {
  final int included;
  final int complete;
  final int percent;
  final List<String> missing;

  const PortfolioCompletionModel({
    required this.included,
    required this.complete,
    required this.percent,
    required this.missing,
  });

  factory PortfolioCompletionModel.fromJson(Map<String, dynamic> json) {
    final missing = json['missing'];
    return PortfolioCompletionModel(
      included: _asInt(json['included']),
      complete: _asInt(json['complete']),
      percent: _asInt(json['percent']),
      missing: missing is List ? missing.map((e) => e.toString()).toList() : const [],
    );
  }
}

class PortfolioSignatureModel {
  final String title;
  final String? name;

  const PortfolioSignatureModel({required this.title, this.name});

  factory PortfolioSignatureModel.fromJson(Map<String, dynamic> json) {
    return PortfolioSignatureModel(
      title: json['title']?.toString() ?? '',
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'name': name};
}

class PortfolioProfileModel {
  final String? name;
  final String? specialty;
  final String? stage;
  final String? schoolName;
  final String? academicYear;
  final String? phone;
  final String? email;
  final List<PortfolioSignatureModel> signatures;

  const PortfolioProfileModel({
    this.name,
    this.specialty,
    this.stage,
    this.schoolName,
    this.academicYear,
    this.phone,
    this.email,
    this.signatures = const [],
  });

  factory PortfolioProfileModel.fromJson(Map<String, dynamic> json) {
    final signatures = json['signatures'];
    return PortfolioProfileModel(
      name: json['name']?.toString(),
      specialty: json['specialty']?.toString(),
      stage: json['stage']?.toString(),
      schoolName: json['school_name']?.toString(),
      academicYear: json['academic_year']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      signatures: signatures is List
          ? signatures
              .whereType<Map<String, dynamic>>()
              .map(PortfolioSignatureModel.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialty': specialty,
        'stage': stage,
        'school_name': schoolName,
        'academic_year': academicYear,
        'phone': phone,
        'email': email,
        'signatures': signatures.map((s) => s.toJson()).toList(),
      };
}

class PortfolioItemModel {
  final int id;

  /// Null for the teacher's own items; standard items can't be deleted.
  final String? itemKey;
  final String title;
  final String? description;
  final bool included;
  final int sortOrder;
  final List<PortfolioFileModel> files;

  const PortfolioItemModel({
    required this.id,
    required this.itemKey,
    required this.title,
    required this.description,
    required this.included,
    required this.sortOrder,
    required this.files,
  });

  bool get isCustom => itemKey == null;

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    final filesJson = json['files'];
    final files = filesJson is List
        ? filesJson
            .whereType<Map<String, dynamic>>()
            .map(PortfolioFileModel.fromJson)
            .toList()
        : <PortfolioFileModel>[];
    files.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return PortfolioItemModel(
      id: _asInt(json['id']),
      itemKey: json['item_key']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      included: json['included'] != false,
      sortOrder: _asInt(json['sort_order']),
      files: files,
    );
  }

  PortfolioItemModel copyWith({bool? included, List<PortfolioFileModel>? files}) {
    return PortfolioItemModel(
      id: id,
      itemKey: itemKey,
      title: title,
      description: description,
      included: included ?? this.included,
      sortOrder: sortOrder,
      files: files ?? this.files,
    );
  }
}

class PortfolioFileModel {
  final int id;

  /// `file` (stored in R2), `link`, or `document` (a saved teacher document).
  final String kind;
  final String? title;
  final String? mime;
  final int? byteSize;
  final String? originalName;

  /// For stored files this is a signed URL that expires after 60 minutes.
  /// Empty for a document until the queue has built its file.
  final String url;
  final int sortOrder;

  const PortfolioFileModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.mime,
    required this.byteSize,
    required this.originalName,
    required this.url,
    required this.sortOrder,
  });

  bool get isLink => kind == 'link';
  bool get isDocument => kind == 'document';
  bool get isImage => kind == 'file' && (mime ?? '').startsWith('image/');
  bool get isPdf => mime == 'application/pdf';

  String get displayName {
    if (title != null && title!.isNotEmpty) return title!;
    if (originalName != null && originalName!.isNotEmpty) return originalName!;
    return url;
  }

  factory PortfolioFileModel.fromJson(Map<String, dynamic> json) {
    return PortfolioFileModel(
      id: _asInt(json['id']),
      kind: json['kind']?.toString() ?? 'file',
      title: json['title']?.toString(),
      mime: json['mime']?.toString(),
      byteSize: json['byte_size'] == null ? null : _asInt(json['byte_size']),
      originalName: json['original_name']?.toString(),
      url: json['url']?.toString() ?? '',
      sortOrder: _asInt(json['sort_order']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
