/// Pure merge of a `role_document` AI job `result` into an open [ReportInput].
library;

import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_input.dart';

/// Merges [result] into [current] following `FRONTEND_TASK_ROLE_SUITES.md` § 4:
/// - Replaces `title` and `blocks` with the result's;
/// - `meta` rows and `kv` pairs: takes the result's value, keeping the value
///   the teacher already typed where the result's value is empty (matched by label);
/// - `images` blocks: copies each existing [ImagesBlock]'s `items` into the
///   result's [ImagesBlock] in the same position;
/// - `signatures`, `theme`, and the photos panel (`images`) remain unchanged.
ReportInput mergeRoleAiResult({
  required ReportInput current,
  required String currentTitle,
  required Map<String, dynamic> result,
  required int Function() nextId,
}) {
  final rawTitle = result['title']?.toString().trim() ?? '';
  final nextTitle = rawTitle.isNotEmpty ? rawTitle : currentTitle;

  final nextMeta = _mergeMeta(current.meta, result['meta'], nextId);
  final nextBlocks = _mergeBlocks(current.blocks, result['blocks'], nextId);

  return current.copyWith(
    title: nextTitle,
    meta: nextMeta,
    blocks: nextBlocks,
  );
}

List<ReportMetaRow> _mergeMeta(
  List<ReportMetaRow> currentMeta,
  dynamic rawMeta,
  int Function() nextId,
) {
  if (rawMeta is! List) return currentMeta;
  final typedByLabel = <String, String>{
    for (final row in currentMeta)
      if (row.label.trim().isNotEmpty && row.value.trim().isNotEmpty) row.label.trim(): row.value,
  };
  return [
    for (final item in rawMeta.whereType<Map>())
      _buildMergedMetaRow(Map<String, dynamic>.from(item), typedByLabel, nextId),
  ];
}

ReportMetaRow _buildMergedMetaRow(
  Map<String, dynamic> item,
  Map<String, String> typedByLabel,
  int Function() nextId,
) {
  final label = item['label']?.toString() ?? '';
  final aiValue = item['value']?.toString() ?? '';
  final resolved = aiValue.trim().isNotEmpty ? aiValue : (typedByLabel[label.trim()] ?? '');
  return ReportMetaRow(nextId(), label: label, value: resolved);
}

List<ReportBlock> _mergeBlocks(
  List<ReportBlock> currentBlocks,
  dynamic rawBlocks,
  int Function() nextId,
) {
  if (rawBlocks is! List) return currentBlocks;
  final oldKvBlocks = currentBlocks.whereType<KvBlock>().toList();
  final allTypedKv = <String, String>{
    for (final kv in oldKvBlocks)
      for (final pair in kv.pairs)
        if (pair.label.trim().isNotEmpty && pair.value.trim().isNotEmpty) pair.label.trim(): pair.value,
  };
  final oldImagesBlocks = currentBlocks.whereType<ImagesBlock>().toList();

  var kvIndex = 0;
  var imagesIndex = 0;
  final merged = <ReportBlock>[];

  for (final raw in rawBlocks.whereType<Map>()) {
    final parsed = ReportBlock.fromJson(Map<String, dynamic>.from(raw), nextId());
    if (parsed is KvBlock) {
      final localTyped = kvIndex < oldKvBlocks.length
          ? <String, String>{
              for (final pair in oldKvBlocks[kvIndex].pairs)
                if (pair.label.trim().isNotEmpty && pair.value.trim().isNotEmpty) pair.label.trim(): pair.value,
            }
          : const <String, String>{};
      kvIndex++;
      merged.add(
        parsed.copyWith(
          pairs: [
            for (final pair in parsed.pairs)
              ReportPair(
                label: pair.label,
                value: pair.value.trim().isNotEmpty
                    ? pair.value
                    : (localTyped[pair.label.trim()] ?? allTypedKv[pair.label.trim()] ?? ''),
              ),
          ],
        ),
      );
    } else if (parsed is ImagesBlock) {
      final preservedItems = imagesIndex < oldImagesBlocks.length ? oldImagesBlocks[imagesIndex].items : parsed.items;
      imagesIndex++;
      merged.add(parsed.copyWith(items: preservedItems));
    } else {
      merged.add(parsed);
    }
  }
  return merged;
}
