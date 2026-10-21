/// `GET /portfolios/roles`: roles, their standard items, limits and types.
class PortfolioRolesModel {
  static const List<String> defaultAllowedMimes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  ];
  static const int defaultMaxFileBytes = 10 * 1024 * 1024;

  final List<PortfolioRoleModel> roles;
  final List<String> allowedMimes;
  final int maxFileBytes;

  const PortfolioRolesModel({
    required this.roles,
    this.allowedMimes = defaultAllowedMimes,
    this.maxFileBytes = defaultMaxFileBytes,
  });

  factory PortfolioRolesModel.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final rolesJson = json is List ? json : map['roles'];
    final mimes = map['allowed_mimes'];
    final limits = map['limits'];
    final sizeLimit = limits is Map ? limits['file_size'] ?? limits['max_file_bytes'] : null;

    return PortfolioRolesModel(
      roles: rolesJson is List
          ? rolesJson
              .whereType<Map<String, dynamic>>()
              .map(PortfolioRoleModel.fromJson)
              .toList()
          : const [],
      allowedMimes: mimes is List && mimes.isNotEmpty
          ? mimes.map((e) => e.toString()).toList()
          : defaultAllowedMimes,
      maxFileBytes: sizeLimit is int && sizeLimit > 0 ? sizeLimit : defaultMaxFileBytes,
    );
  }
}

class PortfolioRoleModel {
  final String key;
  final String label;
  final List<String> itemTitles;

  const PortfolioRoleModel({
    required this.key,
    required this.label,
    required this.itemTitles,
  });

  factory PortfolioRoleModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] ?? json['standard_items'];
    return PortfolioRoleModel(
      key: (json['role'] ?? json['key'] ?? json['value'])?.toString() ?? '',
      label: (json['label'] ?? json['name'])?.toString() ?? '',
      itemTitles: items is List
          ? items
              .map((e) => e is Map ? e['title']?.toString() ?? '' : e.toString())
              .where((title) => title.isNotEmpty)
              .toList()
          : const [],
    );
  }
}
