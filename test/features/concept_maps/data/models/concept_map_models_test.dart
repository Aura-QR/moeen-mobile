import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_field_error.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';

void main() {
  group('ConceptMapInput & limits', () {
    test('blank map initializes with one root concept at level 1', () {
      final input = ConceptMapInput.blank(
        title: 'المادة',
        mainConcept: 'حالات المادة',
      );
      expect(input.nodes.length, 1);
      expect(input.nodes.first.isRoot, isTrue);
      expect(input.levelOf(input.nodes.first.id), 1);
      expect(input.hasBlanks, isFalse);
    });

    test('fromAiResult merges lesson_id and forces tree layout', () {
      final input = ConceptMapInput.fromAiResult({
        'title': 'التفاعلات الكيميائية',
        'nodes': [
          {'id': 'n1', 'text': 'التفاعل'},
          {'id': 'n2', 'parent_id': 'n1', 'text': 'احتراق', 'link': 'يشمل'},
        ],
        'custom_meta': 'keep_me',
      }, lessonId: 42);

      expect(input.title, 'التفاعلات الكيميائية');
      expect(input.lessonId, 42);
      expect(input.layout, ConceptMapLayout.tree);
      expect(input.nodes.length, 2);
      expect(input.toJson()['custom_meta'], 'keep_me');
    });

    test('enforces level 4, 6 children per concept, and 30 total concepts', () {
      var input = ConceptMapInput.blank(mainConcept: 'Root');
      // Add chain down to level 4: n1 (L1) -> n2 (L2) -> n3 (L3) -> n4 (L4)
      input = input
          .addChild('n1', id: 'n2', text: 'L2')
          .addChild('n2', id: 'n3', text: 'L3')
          .addChild('n3', id: 'n4', text: 'L4');

      expect(input.levelOf('n4'), 4);
      expect(input.canAddChild('n4'), isFalse);

      // Add up to 6 children under n1 (already has n2 -> add 5 more)
      for (var i = 0; i < 5; i++) {
        expect(input.canAddChild('n1'), isTrue);
        input = input.addChild('n1', id: 'c$i', text: 'Child $i');
      }
      expect(input.childrenOf('n1').length, 6);
      expect(input.canAddChild('n1'), isFalse);

      // Fill up to 30 total nodes across c0..c4
      var parentIdx = 0;
      while (input.nodes.length < ConceptMapLimits.maxNodes) {
        final parentId = 'c${parentIdx % 5}';
        input = input.addChild(parentId, text: 'Extra');
        parentIdx++;
      }
      expect(input.nodes.length, ConceptMapLimits.maxNodes);
      expect(input.canAddChild('c0'), isFalse);
    });

    test('moveSibling reorders siblings while keeping subtrees attached', () {
      var input = ConceptMapInput.blank(mainConcept: 'Root')
          .addChild('n1', id: 'a', text: 'A')
          .addChild('a', id: 'a1', text: 'A1')
          .addChild('n1', id: 'b', text: 'B');

      expect(input.nodes.map((n) => n.id).toList(), ['n1', 'a', 'a1', 'b']);
      input = input.moveSibling('b', delta: -1);
      expect(input.nodes.map((n) => n.id).toList(), ['n1', 'b', 'a', 'a1']);
    });

    test(
      'deleteSubtree removes node and all descendants and resets showAnswers when no blanks remain',
      () {
        var input = ConceptMapInput.blank(mainConcept: 'Root')
            .addChild('n1', id: 'a', text: 'A')
            .addChild('a', id: 'a1', text: 'A1')
            .updateNode('a1', blank: true)
            .copyWith(showAnswers: true);

        expect(input.hasBlanks, isTrue);
        expect(input.toJson()['show_answers'], isTrue);

        input = input.deleteSubtree('a');
        expect(input.nodes.map((n) => n.id).toList(), ['n1']);
        expect(input.hasBlanks, isFalse);
        expect(input.showAnswers, isFalse);
        expect(input.toJson()['show_answers'], isFalse);
      },
    );
  });

  group('ConceptMapFieldError.parse', () {
    test('parses nodes.N and input.nodes.N keys', () {
      final err1 = ConceptMapFieldError.parse('nodes.3.text', ['النص طويل']);
      expect(err1?.nodeIndex, 3);
      expect(err1?.message, 'النص طويل');

      final err2 = ConceptMapFieldError.parse('input.nodes.0.link', 'خطأ');
      expect(err2?.nodeIndex, 0);
      expect(err2?.message, 'خطأ');

      final titleErr = ConceptMapFieldError.parse('input.title', [
        'العنوان مطلوب',
      ]);
      expect(titleErr?.isTitle, isTrue);
      expect(titleErr?.nodeIndex, isNull);
    });
  });
}
