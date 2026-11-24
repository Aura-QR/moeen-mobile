/// The official layout's part of `GET /tools/activities`: the bands, the
/// approved programs, the non-class programs and the official days
/// (DOCUMENTS_API.md § 6, «دليل الخطط الدراسية – الإصدار السادس 1448»).
library;

Map<String, int> _periodsOf(dynamic value) => value is Map
    ? {for (final entry in value.entries) entry.key.toString(): int.tryParse('${entry.value}') ?? 0}
    : const {};

/// One of the 4 groups the guide counts activity periods for.
class ActivitiesBandModel {
  final String key;
  final String label;

  /// The stage's full name, for the document.
  final String name;
  final int periodsPerYear;

  /// The form's default for periods per week.
  final int periodsPerWeek;

  const ActivitiesBandModel({
    required this.key,
    required this.label,
    this.name = '',
    this.periodsPerYear = 0,
    this.periodsPerWeek = 1,
  });

  factory ActivitiesBandModel.fromJson(Map<String, dynamic> json) => ActivitiesBandModel(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    periodsPerYear: int.tryParse('${json['periods_per_year']}') ?? 0,
    periodsPerWeek: int.tryParse('${json['periods_per_week']}') ?? 1,
  );
}

/// An approved program. A period count of 0 for a band means it isn't offered.
class ActivitiesProgramModel {
  final String key;
  final String label;
  final Map<String, int> periods;

  /// The program includes hours outside school.
  final bool outsideHours;

  const ActivitiesProgramModel({
    required this.key,
    required this.label,
    this.periods = const {},
    this.outsideHours = false,
  });

  factory ActivitiesProgramModel.fromJson(Map<String, dynamic> json) => ActivitiesProgramModel(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    periods: _periodsOf(json['periods']),
    outsideHours: json['outside_hours'] == true,
  );

  int periodsFor(String band) => periods[band] ?? 0;
}

/// One of the 5 domains, with its approved programs.
class ActivitiesProgramDomainModel {
  final String key;
  final String label;
  final List<ActivitiesProgramModel> programs;

  const ActivitiesProgramDomainModel({required this.key, required this.label, this.programs = const []});

  factory ActivitiesProgramDomainModel.fromJson(Map<String, dynamic> json) {
    final programs = json['programs'];
    return ActivitiesProgramDomainModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      programs: programs is List
          ? programs.whereType<Map<String, dynamic>>().map(ActivitiesProgramModel.fromJson).toList()
          : const [],
    );
  }
}

/// A non-class program (الفترات اللاصفية); the plan stores its [key].
class ActivitiesExtracurricularModel {
  final String key;
  final String label;

  const ActivitiesExtracurricularModel({required this.key, required this.label});

  factory ActivitiesExtracurricularModel.fromJson(Map<String, dynamic> json) =>
      ActivitiesExtracurricularModel(key: json['key']?.toString() ?? '', label: json['label']?.toString() ?? '');
}

/// A national or international day that takes periods from the plan.
class ActivitiesOfficialDayModel {
  final String key;
  final String name;
  final Map<String, int> periods;

  const ActivitiesOfficialDayModel({required this.key, required this.name, this.periods = const {}});

  factory ActivitiesOfficialDayModel.fromJson(Map<String, dynamic> json) => ActivitiesOfficialDayModel(
    key: json['key']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    periods: _periodsOf(json['periods']),
  );
}

/// A program the week's picker offers: its name and its periods for the band.
class ActivitiesProgramOption {
  final String label;
  final int periods;
  final bool outsideHours;

  const ActivitiesProgramOption({required this.label, required this.periods, this.outsideHours = false});
}
