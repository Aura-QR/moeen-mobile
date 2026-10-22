/// The tick-box sections of the plan tools (DOCUMENTS_API.md § 8).
library;

/// Where a line came from: the catalogue, an AI suggestion («مقترح»), or the teacher.
enum ChecklistOrigin { ready, suggested, custom }

class ChecklistLine {
  final String text;
  final ChecklistOrigin origin;
  final bool isChecked;

  const ChecklistLine(this.text, {this.origin = ChecklistOrigin.ready, this.isChecked = false});

  bool get isCustom => origin == ChecklistOrigin.custom;

  ChecklistLine copyWith({String? text, bool? isChecked}) =>
      ChecklistLine(text ?? this.text, origin: origin, isChecked: isChecked ?? this.isChecked);
}

/// One section of ready options, as `GET /tools/remedial` or `/tools/enrichment` lists it.
class ChecklistCatalogueSection {
  final String key;
  final String label;
  final List<String> options;

  const ChecklistCatalogueSection({required this.key, required this.label, this.options = const []});

  factory ChecklistCatalogueSection.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    return ChecklistCatalogueSection(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      options: options is List ? options.map((e) => e.toString()).toList() : const [],
    );
  }
}

/// A section's lines. Immutable: every change returns a new section.
/// Its value is only the ticked lines, in order ([checkedTexts]).
class ChecklistSection {
  final String key;
  final String label;
  final List<ChecklistLine> lines;

  /// The API's limits: ticked lines per section, and characters per line.
  final int maxChecked;
  final int maxLength;

  const ChecklistSection({
    required this.key,
    required this.label,
    this.lines = const [],
    this.maxChecked = 20,
    this.maxLength = 300,
  });

  /// The ready options, with [saved] lines ticked. Saved lines that aren't
  /// options (the teacher's own, or AI suggestions) come back as custom lines, ticked.
  factory ChecklistSection.fromCatalogue(
    ChecklistCatalogueSection catalogue, {
    List<String> saved = const [],
    int maxChecked = 20,
    int maxLength = 300,
  }) {
    final ticked = saved.map((text) => text.trim()).where((text) => text.isNotEmpty).toSet();
    return ChecklistSection(
      key: catalogue.key,
      label: catalogue.label,
      maxChecked: maxChecked,
      maxLength: maxLength,
      lines: [
        for (final option in catalogue.options) ChecklistLine(option, isChecked: ticked.contains(option)),
        for (final text in ticked)
          if (!catalogue.options.contains(text)) ChecklistLine(text, origin: ChecklistOrigin.custom, isChecked: true),
      ],
    );
  }

  List<String> get checkedTexts => [for (final line in lines) if (line.isChecked) line.text];

  bool get isFull => checkedTexts.length >= maxChecked;

  bool _contains(String text) => lines.any((line) => line.text == text);

  /// Ticking is refused once [isFull]; unticking always works.
  ChecklistSection toggle(int index) {
    final line = lines[index];
    if (!line.isChecked && isFull) return this;
    return _withLines([...lines]..[index] = line.copyWith(isChecked: !line.isChecked));
  }

  /// «إضافة بند آخر»: added ticked. A line that already exists is ticked instead.
  ChecklistSection addCustom(String text) {
    final value = _clip(text.trim());
    if (value.isEmpty || isFull) return this;
    final existing = lines.indexWhere((line) => line.text == value);
    if (existing >= 0) return lines[existing].isChecked ? this : toggle(existing);
    return _withLines([...lines, ChecklistLine(value, origin: ChecklistOrigin.custom, isChecked: true)]);
  }

  /// Only custom lines can be edited; clearing the text removes the line.
  ChecklistSection editCustom(int index, String text) {
    if (!lines[index].isCustom) return this;
    final value = _clip(text.trim());
    if (value.isEmpty) return removeCustom(index);
    return _withLines([...lines]..[index] = lines[index].copyWith(text: value));
  }

  ChecklistSection removeCustom(int index) =>
      lines[index].isCustom ? _withLines([...lines]..removeAt(index)) : this;

  /// AI suggestions join as unticked options; lines already there are skipped,
  /// so nothing the teacher chose is unticked or overwritten.
  ChecklistSection addSuggestions(List<String> texts) {
    final added = <ChecklistLine>[];
    for (final text in texts.map((text) => _clip(text.trim()))) {
      if (text.isEmpty || _contains(text) || added.any((line) => line.text == text)) continue;
      added.add(ChecklistLine(text, origin: ChecklistOrigin.suggested));
    }
    return added.isEmpty ? this : _withLines([...lines, ...added]);
  }

  String _clip(String text) => text.length > maxLength ? text.substring(0, maxLength) : text;

  ChecklistSection _withLines(List<ChecklistLine> lines) => ChecklistSection(
        key: key,
        label: label,
        lines: lines,
        maxChecked: maxChecked,
        maxLength: maxLength,
      );
}
