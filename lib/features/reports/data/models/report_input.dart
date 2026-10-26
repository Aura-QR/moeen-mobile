/// `input` of a `report` document (DOCUMENTS_API.md § 12).
library;

import 'package:equatable/equatable.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/reports/data/models/report_block.dart';

/// A row of the details table under the title. Rows without a value aren't printed.
class ReportMetaRow extends Equatable {
  /// A local id for the list's keys; never sent.
  final int id;
  final String label;
  final String value;

  const ReportMetaRow(this.id, {this.label = '', this.value = ''});

  @override
  List<Object?> get props => [id, label, value];
}

class ReportSignature extends Equatable {
  final String title;
  final String name;

  const ReportSignature({this.title = '', this.name = ''});

  @override
  List<Object?> get props => [title, name];
}

class ReportInput {
  final String? template;
  final String title;
  final List<ReportMetaRow> meta;
  final List<ReportBlock> blocks;

  /// Empty prints the teacher and the principal from the defaults.
  final List<ReportSignature> signatures;

  /// Every photo the report uses, as storage paths.
  final List<String> images;
  final DocumentTheme theme;
  final Map<String, dynamic> header;

  /// Keys this app doesn't edit, sent back as they came.
  final Map<String, dynamic> extra;

  const ReportInput({
    this.template,
    this.title = '',
    this.meta = const [],
    this.blocks = const [],
    this.signatures = const [],
    this.images = const [],
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.extra = const {},
  });

  static const _ownKeys = {'template', 'title', 'meta', 'blocks', 'signatures', 'images', 'theme', 'header'};

  /// [nextId] numbers the blocks and meta rows for the editor.
  factory ReportInput.fromJson(Map<String, dynamic> json, int Function() nextId) {
    final meta = json['meta'];
    final blocks = json['blocks'];
    final signatures = json['signatures'];
    final images = json['images'];
    final header = json['header'];
    final template = json['template']?.toString();
    return ReportInput(
      template: template == null || template.isEmpty ? null : template,
      title: json['title']?.toString() ?? '',
      meta: meta is List
          ? meta
              .whereType<Map>()
              .map((row) => ReportMetaRow(
                    nextId(),
                    label: row['label']?.toString() ?? '',
                    value: row['value']?.toString() ?? '',
                  ))
              .toList()
          : const [],
      blocks: blocks is List
          ? blocks.whereType<Map>().map((b) => ReportBlock.fromJson(Map<String, dynamic>.from(b), nextId())).toList()
          : const [],
      signatures: signatures is List
          ? signatures
              .whereType<Map>()
              .map((s) => ReportSignature(title: s['title']?.toString() ?? '', name: s['name']?.toString() ?? ''))
              .toList()
          : const [],
      images: images is List ? images.map((path) => path.toString()).toList() : const [],
      theme: DocumentTheme.fromJson(json['theme']),
      header: header is Map ? Map<String, dynamic>.from(header) : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        'template': ?template,
        'title': title.trim(),
        'meta': [
          for (final row in meta) {'label': row.label.trim(), 'value': row.value.trim()},
        ],
        'blocks': blocks.map((block) => block.toJson()).toList(),
        'signatures': [
          for (final s in signatures)
            if (s.title.trim().isNotEmpty) {'title': s.title.trim(), 'name': s.name.trim()},
        ],
        'images': images,
        'theme': theme.name,
        if (header.isNotEmpty) 'header': header,
      };

  ReportInput copyWith({
    String? title,
    List<ReportMetaRow>? meta,
    List<ReportBlock>? blocks,
    List<ReportSignature>? signatures,
    List<String>? images,
    DocumentTheme? theme,
    Map<String, dynamic>? header,
  }) {
    return ReportInput(
      template: template,
      title: title ?? this.title,
      meta: meta ?? this.meta,
      blocks: blocks ?? this.blocks,
      signatures: signatures ?? this.signatures,
      images: images ?? this.images,
      theme: theme ?? this.theme,
      header: header ?? this.header,
      extra: extra,
    );
  }
}
