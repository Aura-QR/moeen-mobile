/// Models and pure tree operations for `concept_map` documents (DOCUMENTS_API.md § 14).
library;

import 'package:equatable/equatable.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';

abstract final class ConceptMapLimits {
  static const int maxNodes = 30;
  static const int maxChildrenPerNode = 6;
  static const int maxLevel = 4;
  static const int maxTextLength = 60;
  static const int maxLinkLength = 30;
  static const int maxTitleLength = 150;
}

enum ConceptMapLayout {
  tree('tree', 'concept_map_layout_tree'),
  radial('radial', 'concept_map_layout_radial');

  final String jsonValue;
  final String labelKey;

  const ConceptMapLayout(this.jsonValue, this.labelKey);

  static ConceptMapLayout fromJson(dynamic raw) {
    final value = raw?.toString() ?? '';
    return ConceptMapLayout.values.firstWhere(
      (item) => item.jsonValue == value,
      orElse: () => ConceptMapLayout.tree,
    );
  }
}

class ConceptMapNode extends Equatable {
  final String id;
  final String? parentId;
  final String text;
  final String link;
  final bool blank;
  final Map<String, dynamic> extra;

  const ConceptMapNode({
    required this.id,
    this.parentId,
    this.text = '',
    this.link = '',
    this.blank = false,
    this.extra = const {},
  });

  bool get isRoot => parentId == null || parentId!.isEmpty;

  static const _ownKeys = {
    'id',
    'parent_id',
    'parent',
    'text',
    'label',
    'link',
    'link_label',
    'blank',
    'is_blank',
  };

  factory ConceptMapNode.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) {
    final rawId = json['id']?.toString().trim() ?? '';
    final rawParent = (json['parent_id'] ?? json['parent'])?.toString().trim();
    return ConceptMapNode(
      id: rawId.isEmpty ? fallbackId : rawId,
      parentId: rawParent == null || rawParent.isEmpty ? null : rawParent,
      text: (json['text'] ?? json['label'])?.toString() ?? '',
      link: (json['link'] ?? json['link_label'])?.toString() ?? '',
      blank: json['blank'] == true || json['is_blank'] == true,
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'id': id,
    'parent_id': isRoot ? null : parentId,
    'text': text.trim(),
    if (!isRoot && link.trim().isNotEmpty) 'link': link.trim(),
    'blank': blank,
  };

  ConceptMapNode copyWith({
    String? id,
    String? parentId,
    bool clearParent = false,
    String? text,
    String? link,
    bool? blank,
  }) => ConceptMapNode(
    id: id ?? this.id,
    parentId: clearParent ? null : (parentId ?? this.parentId),
    text: text ?? this.text,
    link: link ?? this.link,
    blank: blank ?? this.blank,
    extra: extra,
  );

  @override
  List<Object?> get props => [id, parentId, text, link, blank, extra];
}

class ConceptMapInput extends Equatable {
  final String title;
  final int? lessonId;
  final ConceptMapLayout layout;
  final bool showAnswers;
  final List<ConceptMapNode> nodes;
  final DocumentTheme theme;
  final Map<String, dynamic> header;
  final Map<String, dynamic> extra;

  const ConceptMapInput({
    this.title = '',
    this.lessonId,
    this.layout = ConceptMapLayout.tree,
    this.showAnswers = false,
    this.nodes = const [],
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.extra = const {},
  });

  static const _ownKeys = {
    'title',
    'lesson_id',
    'layout',
    'show_answers',
    'nodes',
    'theme',
    'header',
  };

  factory ConceptMapInput.blank({String title = '', String mainConcept = ''}) =>
      ConceptMapInput(
        title: title,
        nodes: [ConceptMapNode(id: 'n1', text: mainConcept)],
      );

  factory ConceptMapInput.fromAiResult(
    Map<String, dynamic> result, {
    required int lessonId,
    String fallbackTitle = '',
  }) {
    final merged = <String, dynamic>{
      ...result,
      'lesson_id': lessonId,
      'layout': ConceptMapLayout.tree.jsonValue,
    };
    final parsed = ConceptMapInput.fromJson(merged);
    if (parsed.title.trim().isNotEmpty || fallbackTitle.trim().isEmpty) {
      return parsed;
    }
    return parsed.copyWith(title: fallbackTitle.trim());
  }

  factory ConceptMapInput.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'];
    final parsedNodes = <ConceptMapNode>[];
    if (rawNodes is List) {
      var index = 0;
      for (final item in rawNodes.whereType<Map>()) {
        index++;
        parsedNodes.add(
          ConceptMapNode.fromJson(
            Map<String, dynamic>.from(item),
            fallbackId: 'n$index',
          ),
        );
      }
    }
    final normalized = _normalizePreOrder(parsedNodes);
    final header = json['header'];
    return ConceptMapInput(
      title: json['title']?.toString() ?? '',
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? ''),
      layout: ConceptMapLayout.fromJson(json['layout']),
      showAnswers: json['show_answers'] == true,
      nodes: normalized,
      theme: DocumentTheme.fromJson(json['theme']),
      header: header is Map ? Map<String, dynamic>.from(header) : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  bool get hasBlanks => nodes.any((node) => node.blank);

  Map<String, dynamic> toJson() => {
    ...extra,
    'title': title.trim(),
    'lesson_id': ?lessonId,
    'layout': layout.jsonValue,
    'show_answers': hasBlanks && showAnswers,
    'nodes': [
      for (final node in nodes)
        node.isRoot ? node.copyWith(link: '').toJson() : node.toJson(),
    ],
    'theme': theme.name,
    if (header.isNotEmpty) 'header': header,
  };

  ConceptMapNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  /// 1-based depth: main concept = 1, max allowed = 4.
  int levelOf(String nodeId) {
    final byId = {for (final node in nodes) node.id: node};
    var current = byId[nodeId];
    if (current == null) return 1;
    var level = 1;
    final visited = <String>{current.id};
    while (current != null && !current.isRoot) {
      final parent = byId[current.parentId];
      if (parent == null || !visited.add(parent.id)) break;
      level++;
      current = parent;
    }
    return level;
  }

  List<ConceptMapNode> childrenOf(String parentId) =>
      nodes.where((node) => node.parentId == parentId).toList();

  List<ConceptMapNode> siblingsOf(String nodeId) {
    final target = nodeById(nodeId);
    if (target == null) return const [];
    if (target.isRoot) return nodes.where((node) => node.isRoot).toList();
    return childrenOf(target.parentId!);
  }

  Set<String> subtreeIds(String nodeId) {
    final ids = <String>{nodeId};
    var added = true;
    while (added) {
      added = false;
      for (final node in nodes) {
        if (node.parentId != null &&
            ids.contains(node.parentId) &&
            ids.add(node.id)) {
          added = true;
        }
      }
    }
    return ids;
  }

  bool canAddChild(String parentId) =>
      nodeById(parentId) != null &&
      nodes.length < ConceptMapLimits.maxNodes &&
      childrenOf(parentId).length < ConceptMapLimits.maxChildrenPerNode &&
      levelOf(parentId) < ConceptMapLimits.maxLevel;

  bool canMoveUp(String nodeId) {
    final siblings = siblingsOf(nodeId);
    final idx = siblings.indexWhere((n) => n.id == nodeId);
    return idx > 0;
  }

  bool canMoveDown(String nodeId) {
    final siblings = siblingsOf(nodeId);
    final idx = siblings.indexWhere((n) => n.id == nodeId);
    return idx >= 0 && idx < siblings.length - 1;
  }

  bool canDelete(String nodeId) {
    final node = nodeById(nodeId);
    return node != null && !node.isRoot;
  }

  String nextNodeId() {
    final used = nodes.map((n) => n.id).toSet();
    var counter = nodes.length + 1;
    while (used.contains('n$counter')) {
      counter++;
    }
    return 'n$counter';
  }

  ConceptMapInput updateNode(
    String nodeId, {
    String? text,
    String? link,
    bool? blank,
  }) {
    final updated = [
      for (final node in nodes)
        if (node.id == nodeId)
          node.copyWith(text: text, link: node.isRoot ? '' : link, blank: blank)
        else
          node,
    ];
    final nextHasBlanks = updated.any((n) => n.blank);
    return copyWith(
      nodes: updated,
      showAnswers: nextHasBlanks ? showAnswers : false,
    );
  }

  ConceptMapInput addChild(String parentId, {String text = '', String? id}) {
    if (!canAddChild(parentId)) return this;
    final child = ConceptMapNode(
      id: id ?? nextNodeId(),
      parentId: parentId,
      text: text,
    );
    return copyWith(nodes: _normalizePreOrder([...nodes, child]));
  }

  ConceptMapInput moveSibling(String nodeId, {required int delta}) {
    final target = nodeById(nodeId);
    if (target == null || target.isRoot) return this;
    final siblings = siblingsOf(nodeId);
    final index = siblings.indexWhere((n) => n.id == nodeId);
    final swapIndex = index + delta;
    if (index < 0 || swapIndex < 0 || swapIndex >= siblings.length) return this;

    final otherId = siblings[swapIndex].id;
    final reordered = [...nodes];
    final posA = reordered.indexWhere((n) => n.id == nodeId);
    final posB = reordered.indexWhere((n) => n.id == otherId);
    if (posA < 0 || posB < 0) return this;
    final temp = reordered[posA];
    reordered[posA] = reordered[posB];
    reordered[posB] = temp;
    return copyWith(nodes: _normalizePreOrder(reordered));
  }

  ConceptMapInput deleteSubtree(String nodeId) {
    if (!canDelete(nodeId)) return this;
    final toRemove = subtreeIds(nodeId);
    final remaining = nodes
        .where((node) => !toRemove.contains(node.id))
        .toList();
    final nextHasBlanks = remaining.any((n) => n.blank);
    return copyWith(
      nodes: _normalizePreOrder(remaining),
      showAnswers: nextHasBlanks ? showAnswers : false,
    );
  }

  ConceptMapInput copyWith({
    String? title,
    int? lessonId,
    ConceptMapLayout? layout,
    bool? showAnswers,
    List<ConceptMapNode>? nodes,
    DocumentTheme? theme,
    Map<String, dynamic>? header,
  }) => ConceptMapInput(
    title: title ?? this.title,
    lessonId: lessonId ?? this.lessonId,
    layout: layout ?? this.layout,
    showAnswers: showAnswers ?? this.showAnswers,
    nodes: nodes ?? this.nodes,
    theme: theme ?? this.theme,
    header: header ?? this.header,
    extra: extra,
  );

  static List<ConceptMapNode> _normalizePreOrder(List<ConceptMapNode> raw) {
    if (raw.isEmpty) return const [ConceptMapNode(id: 'n1')];

    final seenIds = <String>{};
    final unique = <ConceptMapNode>[];
    for (var i = 0; i < raw.length; i++) {
      var id = raw[i].id.trim();
      if (id.isEmpty || seenIds.contains(id)) {
        var c = i + 1;
        while (seenIds.contains('n$c')) {
          c++;
        }
        id = 'n$c';
      }
      seenIds.add(id);
      unique.add(raw[i].copyWith(id: id));
    }

    var rootIndex = unique.indexWhere((n) => n.isRoot);
    if (rootIndex < 0) {
      unique[0] = unique[0].copyWith(clearParent: true, link: '');
      rootIndex = 0;
    }
    final mainRoot = unique[rootIndex].copyWith(clearParent: true, link: '');
    final childrenByParent = <String, List<ConceptMapNode>>{};

    for (var i = 0; i < unique.length; i++) {
      if (i == rootIndex) continue;
      final node = unique[i];
      final parentId =
          (node.parentId != null &&
              seenIds.contains(node.parentId) &&
              node.parentId != node.id)
          ? node.parentId!
          : mainRoot.id;
      childrenByParent
          .putIfAbsent(parentId, () => [])
          .add(node.copyWith(parentId: parentId));
    }

    final ordered = <ConceptMapNode>[];
    final visited = <String>{};

    void walk(ConceptMapNode current) {
      if (!visited.add(current.id)) return;
      ordered.add(current);
      for (final child
          in childrenByParent[current.id] ?? const <ConceptMapNode>[]) {
        walk(child);
      }
    }

    walk(mainRoot);
    for (final node in unique) {
      if (!visited.contains(node.id)) {
        walk(node.copyWith(parentId: mainRoot.id));
      }
    }
    return ordered;
  }

  @override
  List<Object?> get props => [
    title,
    lessonId,
    layout,
    showAnswers,
    nodes,
    theme,
    header,
    extra,
  ];
}
