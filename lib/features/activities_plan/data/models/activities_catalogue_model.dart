/// Models for `GET /tools/activities` (DOCUMENTS_API.md § 6).
library;

import 'package:moean/features/activities_plan/data/models/activities_program_models.dart';

/// `primary`, `intermediate` or `secondary`, with a short [label] for the
/// picker and the full [name] for the document.
class ActivitiesStageModel {
  final String key;
  final String label;
  final String name;

  const ActivitiesStageModel({required this.key, required this.label, required this.name});

  factory ActivitiesStageModel.fromJson(Map<String, dynamic> json) => ActivitiesStageModel(
    key: json['key']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );
}

/// An activity domain: one column of the old layout, or a domain of the official one.
class ActivitiesDomainModel {
  final String key;
  final String label;

  const ActivitiesDomainModel({required this.key, required this.label});

  factory ActivitiesDomainModel.fromJson(Map<String, dynamic> json) =>
      ActivitiesDomainModel(key: json['key']?.toString() ?? '', label: json['label']?.toString() ?? '');
}

class ActivitiesCatalogueModel {
  /// The domain key of a week that holds an official day.
  static const String occasionsKey = 'occasions';

  static final RegExp _continued = RegExp(r'\s*\(تابع\)\s*$');

  /// The old layout's stages and domains, for reopening saved documents.
  final List<ActivitiesStageModel> stages;
  final List<ActivitiesDomainModel> domains;

  final List<ActivitiesBandModel> bands;

  /// The 5 official domains, each with its approved programs.
  final List<ActivitiesProgramDomainModel> programDomains;

  /// «الأيام والمناسبات».
  final ActivitiesDomainModel occasionsDomain;
  final List<ActivitiesExtracurricularModel> extracurricular;
  final List<ActivitiesOfficialDayModel> officialDays;

  /// The Ein portal, where the non-class timeline is published.
  final String einUrl;

  const ActivitiesCatalogueModel({
    this.stages = const [],
    this.domains = const [],
    this.bands = const [],
    this.programDomains = const [],
    this.occasionsDomain = const ActivitiesDomainModel(key: occasionsKey, label: ''),
    this.extracurricular = const [],
    this.officialDays = const [],
    this.einUrl = '',
  });

  factory ActivitiesCatalogueModel.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final value = json[key];
      return value is List ? value.whereType<Map<String, dynamic>>().map(parse).toList() : const [];
    }

    final occasions = json['occasions_domain'];
    return ActivitiesCatalogueModel(
      stages: list('stages', ActivitiesStageModel.fromJson),
      domains: list('domains', ActivitiesDomainModel.fromJson),
      bands: list('bands', ActivitiesBandModel.fromJson),
      programDomains: list('programs', ActivitiesProgramDomainModel.fromJson),
      occasionsDomain: occasions is Map<String, dynamic>
          ? ActivitiesDomainModel.fromJson(occasions)
          : const ActivitiesDomainModel(key: occasionsKey, label: ''),
      extracurricular: list('extracurricular', ActivitiesExtracurricularModel.fromJson),
      officialDays: list('official_days', ActivitiesOfficialDayModel.fromJson),
      einUrl: json['ein_url']?.toString() ?? '',
    );
  }

  /// The old layout's domain label, or its key when the catalogue doesn't list it.
  String domainLabel(String key) => domains.where((domain) => domain.key == key).firstOrNull?.label ?? key;

  ActivitiesBandModel? bandOf(String? key) => bands.where((band) => band.key == key).firstOrNull;

  /// The 5 official domains, then «الأيام والمناسبات»: what a week's domain picker offers.
  List<ActivitiesDomainModel> get officialDomains => [
    for (final domain in programDomains) ActivitiesDomainModel(key: domain.key, label: domain.label),
    occasionsDomain,
  ];

  /// The official domain's label, or the key itself when unknown.
  String officialDomainLabel(String key) =>
      officialDomains.where((domain) => domain.key == key).firstOrNull?.label ?? key;

  /// What the program picker offers for [domainKey] in [band]: the approved
  /// programs, or the official days for «الأيام والمناسبات». What the band
  /// doesn't offer (0 periods) is left out.
  List<ActivitiesProgramOption> programOptions(String domainKey, String? band) {
    if (band == null) return const [];
    if (domainKey == occasionsDomain.key) {
      return [
        for (final day in officialDays)
          if ((day.periods[band] ?? 0) > 0) ActivitiesProgramOption(label: day.name, periods: day.periods[band]!),
      ];
    }
    final domain = programDomains.where((domain) => domain.key == domainKey).firstOrNull;
    return [
      for (final program in domain?.programs ?? const <ActivitiesProgramModel>[])
        if (program.periodsFor(band) > 0)
          ActivitiesProgramOption(
            label: program.label,
            periods: program.periodsFor(band),
            outsideHours: program.outsideHours,
          ),
    ];
  }

  /// The program's text without the «(تابع)» the suggestion adds on following weeks.
  static String baseProgram(String text) => text.replaceAll(_continued, '').trim();

  /// Whether [text] is an approved program or official day. Anything else is
  /// a local program that needs approval.
  /// A week with two official days lists both, joined by «،».
  bool isOfficialProgram(String text) => baseProgram(text).split('،').map((name) => name.trim()).every(_isListed);

  bool _isListed(String name) =>
      programDomains.any((domain) => domain.programs.any((program) => program.label == name)) ||
      officialDays.any((day) => day.name == name);

  String extracurricularLabel(String key) =>
      extracurricular.where((program) => program.key == key).firstOrNull?.label ?? key;
}
