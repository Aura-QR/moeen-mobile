/// The performance elements a document can count as evidence for (T9),
/// from `GET /portfolios/roles` → `elements` and `rating_scale`.
class PortfolioElementsModel {
  final List<PortfolioElementModel> elements;
  final int ratingMin;
  final int ratingMax;

  const PortfolioElementsModel({
    required this.elements,
    this.ratingMin = 1,
    this.ratingMax = 5,
  });

  /// [body] is the whole response: `elements` sits beside `data`.
  factory PortfolioElementsModel.fromJson(dynamic body) {
    final map = body is Map ? body : const {};
    final elements = map['elements'];
    final scale = map['rating_scale'];
    return PortfolioElementsModel(
      elements: elements is List
          ? elements.whereType<Map>().map((e) => PortfolioElementModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      ratingMin: scale is Map ? _asInt(scale['min']) ?? 1 : 1,
      ratingMax: scale is Map ? _asInt(scale['max']) ?? 5 : 5,
    );
  }

  PortfolioElementModel? byKey(String? key) => elements.where((e) => e.key == key).firstOrNull;
}

class PortfolioElementModel {
  final String key;
  final String title;

  /// Null for the student-activity items, which aren't Ministry elements.
  final int? number;
  final int? weight;

  const PortfolioElementModel({required this.key, required this.title, this.number, this.weight});

  factory PortfolioElementModel.fromJson(Map<String, dynamic> json) {
    return PortfolioElementModel(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      number: _asInt(json['number']),
      weight: _asInt(json['weight']),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
