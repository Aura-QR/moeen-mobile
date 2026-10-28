/// Models for L3 «أنماط التعلم» (LEARNING_STYLES_API.md), teacher side.
library;

import 'dart:convert';
import 'dart:typed_data';

int _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
int? _intOrNull(dynamic v) => v == null ? null : _int(v);
num _num(dynamic v) => v is num ? v : (num.tryParse('$v') ?? 0);
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];
List<String> _strings(dynamic v) => v is List ? v.map((e) => '$e').toList() : const [];
Map<String, num> _numMap(dynamic v) =>
    v is Map ? {for (final e in v.entries) '${e.key}': _num(e.value)} : const {};
Map<String, int> _intMap(dynamic v) =>
    v is Map ? {for (final e in v.entries) '${e.key}': _int(e.value)} : const {};

/// Decodes a `data:image/png;base64,…` QR into bytes, or null.
Uint8List? qrBytesFromDataUri(String? dataUri) {
  if (dataUri == null || !dataUri.contains(',')) return null;
  try {
    return base64Decode(dataUri.split(',').last);
  } catch (_) {
    return null;
  }
}

/// The four learning-style keys.
abstract final class LearningStyleKeys {
  static const String visual = 'visual';
  static const String auditory = 'auditory';
  static const String readWrite = 'read_write';
  static const String kinesthetic = 'kinesthetic';
  static const List<String> all = [visual, auditory, readWrite, kinesthetic];
}

/// Questionnaire versions: `standard` (grades 4–12) and `simple` (grades 1–3).
abstract final class LearningStyleVersions {
  static const String standard = 'standard';
  static const String simple = 'simple';
  static const List<String> all = [standard, simple];
}

/// A survey group's state (per class).
abstract final class SurveyGroupState {
  static const String open = 'open';
  static const String closed = 'closed';
  static const String ended = 'ended';
}

/// The API's limits for «أنماط التعلم».
abstract final class LearningStylesLimits {
  static const int maxGroups = 10;
  static const int maxSurveys = 100;
  static const int maxTitleLength = 200;
  static const int maxGroupNameLength = 60;
}

/// One of the four styles, with its label and description.
class StyleInfo {
  final String key;
  final String label;
  final String description;

  const StyleInfo({required this.key, required this.label, this.description = ''});

  factory StyleInfo.fromJson(Map<String, dynamic> json) => StyleInfo(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );
}

/// One choice on a version's scale (e.g. «تنطبق عليّ» = 2).
class StyleScaleOption {
  final num value;
  final String label;
  final String? emoji;

  const StyleScaleOption({required this.value, required this.label, this.emoji});

  factory StyleScaleOption.fromJson(Map<String, dynamic> json) => StyleScaleOption(
        value: _num(json['value']),
        label: json['label']?.toString() ?? '',
        emoji: json['emoji']?.toString(),
      );
}

/// One statement in a version's questionnaire.
class StyleStatement {
  final String key;
  final String style;
  final String text;
  final String? emoji;

  const StyleStatement({required this.key, required this.style, required this.text, this.emoji});

  factory StyleStatement.fromJson(Map<String, dynamic> json) => StyleStatement(
        key: json['key']?.toString() ?? '',
        style: json['style']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        emoji: json['emoji']?.toString(),
      );
}

/// A questionnaire version with its scale and statements, for the teacher's preview.
class StylesVersion {
  final String key;
  final String label;
  final List<StyleScaleOption> scale;
  final List<StyleStatement> statements;

  const StylesVersion({required this.key, required this.label, this.scale = const [], this.statements = const []});

  factory StylesVersion.fromJson(Map<String, dynamic> json) => StylesVersion(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        scale: _maps(json['scale']).map(StyleScaleOption.fromJson).toList(),
        statements: _maps(json['statements']).map(StyleStatement.fromJson).toList(),
      );
}

/// `GET /learning-styles/options`.
class LearningStylesOptions {
  final List<StyleInfo> styles;
  final List<StylesVersion> versions;
  final int groupsLimit;

  const LearningStylesOptions({this.styles = const [], this.versions = const [], this.groupsLimit = LearningStylesLimits.maxGroups});

  factory LearningStylesOptions.fromJson(Map<String, dynamic> json) {
    final limits = json['limits'] is Map ? Map<String, dynamic>.from(json['limits'] as Map) : const <String, dynamic>{};
    return LearningStylesOptions(
      styles: _maps(json['styles']).map(StyleInfo.fromJson).toList(),
      versions: _maps(json['versions']).map(StylesVersion.fromJson).toList(),
      groupsLimit: limits['groups'] == null ? LearningStylesLimits.maxGroups : _int(limits['groups']),
    );
  }

  StylesVersion? version(String key) => versions.where((v) => v.key == key).firstOrNull;
}

/// One class's link and QR for a survey.
class SurveyGroup {
  final int id;
  final String name;
  final int? classId;
  final String url;
  final DateTime? closesAt;
  final String state;
  final int responses;

  /// A `data:image/png;base64,…` URI, only on `store`/`show`/`update`.
  final String? qr;

  const SurveyGroup({
    required this.id,
    required this.name,
    this.classId,
    this.url = '',
    this.closesAt,
    this.state = SurveyGroupState.open,
    this.responses = 0,
    this.qr,
  });

  factory SurveyGroup.fromJson(Map<String, dynamic> json) => SurveyGroup(
        id: _int(json['id']),
        name: json['name']?.toString() ?? '',
        classId: _intOrNull(json['class_id']),
        url: json['url']?.toString() ?? '',
        closesAt: DateTime.tryParse(json['closes_at']?.toString() ?? ''),
        state: json['state']?.toString() ?? SurveyGroupState.open,
        responses: _int(json['responses']),
        qr: json['qr']?.toString(),
      );
}

/// A saved survey (list item and `show`).
class LearningStyleSurvey {
  final int id;
  final String title;
  final String version;
  final bool isOpen;
  final int responses;
  final List<SurveyGroup> groups;
  final DateTime? createdAt;

  const LearningStyleSurvey({
    required this.id,
    required this.title,
    this.version = LearningStyleVersions.standard,
    this.isOpen = true,
    this.responses = 0,
    this.groups = const [],
    this.createdAt,
  });

  factory LearningStyleSurvey.fromJson(Map<String, dynamic> json) => LearningStyleSurvey(
        id: _int(json['id']),
        title: json['title']?.toString() ?? '',
        version: json['version']?.toString() ?? LearningStyleVersions.standard,
        isOpen: json['is_open'] != false,
        responses: _int(json['responses']),
        groups: _maps(json['groups']).map(SurveyGroup.fromJson).toList(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

/// What the teacher fills in to create a survey.
class NewLearningStyleSurvey {
  final String title;
  final String version;
  final List<({String name, int? classId})> groups;

  const NewLearningStyleSurvey({required this.title, this.version = LearningStyleVersions.standard, this.groups = const []});

  Map<String, dynamic> toJson() => {
        'title': title.trim(),
        'version': version,
        'groups': [
          for (final g in groups)
            {
              if (g.name.trim().isNotEmpty) 'name': g.name.trim(),
              if (g.classId != null) 'class_id': g.classId,
            },
        ],
      };
}

/// A suggested teaching strategy for the class's top styles.
class StrategyCard {
  final String key;
  final String style;
  final String name;
  final String definition;
  final List<String> steps;

  const StrategyCard({required this.key, this.style = '', this.name = '', this.definition = '', this.steps = const []});

  factory StrategyCard.fromJson(Map<String, dynamic> json) => StrategyCard(
        key: json['key']?.toString() ?? '',
        style: json['style']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        definition: json['definition']?.toString() ?? '',
        steps: _strings(json['steps']),
      );
}

/// The style mix of a class or of the whole survey.
class StyleSummary {
  final int count;
  final Map<String, num> percents;
  final Map<String, int> students;
  final List<String> topStyles;
  final List<StrategyCard> strategies;

  const StyleSummary({
    this.count = 0,
    this.percents = const {},
    this.students = const {},
    this.topStyles = const [],
    this.strategies = const [],
  });

  factory StyleSummary.fromJson(Map<String, dynamic> json) => StyleSummary(
        count: _int(json['count']),
        percents: _numMap(json['percents']),
        students: _intMap(json['students']),
        topStyles: _strings(json['top_styles']),
        strategies: _maps(json['strategies']).map(StrategyCard.fromJson).toList(),
      );
}

/// One student's result inside a class.
class StudentResponse {
  final int id;
  final String studentName;
  final Map<String, num> scores;
  final List<String> mainStyles;
  final String leaning;
  final DateTime? submittedAt;

  const StudentResponse({
    required this.id,
    required this.studentName,
    this.scores = const {},
    this.mainStyles = const [],
    this.leaning = '',
    this.submittedAt,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) => StudentResponse(
        id: _int(json['id']),
        studentName: json['student_name']?.toString() ?? '',
        scores: _numMap(json['scores']),
        mainStyles: _strings(json['main_styles']),
        leaning: json['leaning']?.toString() ?? '',
        submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? ''),
      );
}

/// A class's results: its summary and the students who answered.
class ResultsGroupModel {
  final int id;
  final String name;
  final int? classId;
  final StyleSummary summary;
  final List<StudentResponse> responses;

  const ResultsGroupModel({
    required this.id,
    required this.name,
    this.classId,
    this.summary = const StyleSummary(),
    this.responses = const [],
  });

  factory ResultsGroupModel.fromJson(Map<String, dynamic> json) => ResultsGroupModel(
        id: _int(json['id']),
        name: json['name']?.toString() ?? '',
        classId: _intOrNull(json['class_id']),
        summary: StyleSummary.fromJson(
          json['summary'] is Map ? Map<String, dynamic>.from(json['summary'] as Map) : const {},
        ),
        responses: _maps(json['responses']).map(StudentResponse.fromJson).toList(),
      );
}

/// `GET /learning-styles/{id}/results`.
class LearningStylesResults {
  final LearningStyleSurvey survey;
  final List<StyleInfo> styles;
  final StyleSummary overall;
  final List<ResultsGroupModel> groups;

  const LearningStylesResults({
    required this.survey,
    this.styles = const [],
    this.overall = const StyleSummary(),
    this.groups = const [],
  });

  factory LearningStylesResults.fromJson(Map<String, dynamic> json) => LearningStylesResults(
        survey: LearningStyleSurvey.fromJson(
          json['survey'] is Map ? Map<String, dynamic>.from(json['survey'] as Map) : const {},
        ),
        styles: _maps(json['styles']).map(StyleInfo.fromJson).toList(),
        overall: StyleSummary.fromJson(
          json['overall'] is Map ? Map<String, dynamic>.from(json['overall'] as Map) : const {},
        ),
        groups: _maps(json['groups']).map(ResultsGroupModel.fromJson).toList(),
      );
}
