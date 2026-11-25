/// The performance elements a document can count as evidence for (T9),
/// from `GET /portfolios/roles`: each role's `form`, plus `elements` beside
/// `data`.
class PortfolioElementsModel {
  /// The role whose form a teacher without a portfolio sees.
  static const String defaultRole = 'teacher';

  /// Every element the server knows, used to name a key outside a form.
  final List<PortfolioElementModel> elements;

  /// Role key → that role's evaluation form, in order.
  final Map<String, List<PortfolioElementModel>> forms;

  const PortfolioElementsModel({required this.elements, this.forms = const {}});

  /// [body] is the whole response.
  factory PortfolioElementsModel.fromJson(dynamic body) {
    final map = body is Map ? body : const {};
    final data = map['data'];
    final roles = data is List ? data : (data is Map ? data['roles'] : null);
    return PortfolioElementsModel(
      elements: parsePortfolioElements(map['elements']),
      forms: {
        if (roles is List)
          for (final role in roles.whereType<Map>().where((role) => role['form'] is List))
            (role['role'] ?? role['key'] ?? role['value'])?.toString() ?? '': parsePortfolioElements(role['form']),
      }..remove(''),
    );
  }

  /// The picker's list: [role]'s form (the teacher's when [role] is null),
  /// with [current] added at the end when it isn't in that form. A server
  /// without forms gets its flat `elements` list, as before.
  List<PortfolioElementModel> optionsFor(String? role, String? current) {
    final form = forms.isEmpty
        ? elements
        : forms[role ?? defaultRole] ?? forms[defaultRole] ?? const <PortfolioElementModel>[];
    if (current == null || form.any((element) => element.key == current)) return form;
    return [...form, _outsideForm(current)];
  }

  /// Named from any list that has it, without a form number or weight.
  PortfolioElementModel _outsideForm(String key) {
    final known = [...elements, for (final form in forms.values) ...form].where((e) => e.key == key).firstOrNull;
    return PortfolioElementModel(key: key, title: known?.title ?? key);
  }
}

class PortfolioElementModel {
  final String key;
  final String title;

  /// Null for an item that isn't a numbered element of the form.
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

/// A JSON list of `{key, title, number, weight}`; anything else is empty.
List<PortfolioElementModel> parsePortfolioElements(dynamic json) => json is List
    ? json.whereType<Map>().map((e) => PortfolioElementModel.fromJson(Map<String, dynamic>.from(e))).toList()
    : const [];

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
