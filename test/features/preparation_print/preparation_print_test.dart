import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/preparation_print/data/models/preparation_print_models.dart';
import 'package:moean/features/preparation_print/data/repositories/preparation_print_repository.dart';
import 'package:moean/features/preparation_print/presentation/cubit/preparation_history_cubit.dart';
import 'package:moean/features/preparation_print/presentation/cubit/preparation_print_cubit.dart';

class MockPreparationPrintRepository extends Mock implements PreparationPrintRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class _Failure extends Failure {
  const _Failure(super.message);
}

DocumentModel _doc(int id, Map<String, dynamic> input) =>
    DocumentModel.fromJson({'id': id, 'type': 'lesson_preparation', 'title': 'تحضير', 'status': 'draft', 'input': input});

PreparationsPage _page(List<int> ids, {int current = 1, int last = 1}) => PreparationsPage(
      items: ids.map((id) => PreparationItem(id: id, title: 'درس $id', status: 'done')).toList(),
      currentPage: current,
      lastPage: last,
    );

void main() {
  group('models', () {
    test('a preparation takes its title from the lesson when it has none', () {
      final item = PreparationItem.fromJson({'id': 5, 'lesson_title': null, 'lesson': {'title': 'أجزاء النبات'}, 'status': 'done', 'created_at': '2026-10-21T09:00:00Z'});
      expect(item.title, 'أجزاء النبات');
      expect(item.isDone, isTrue);
      expect(item.date, isNotNull);
    });

    test('list sections are edited one line per item, empty lines dropped', () {
      final lesson = const PrintLesson({'preparation_id': 3, 'strategies': ['أ']}).withText('strategies', 'التعلم التعاوني\n\n التعلم باللعب ', isList: true);
      expect(lesson.data['strategies'], ['التعلم التعاوني', 'التعلم باللعب']);
      expect(lesson.data['preparation_id'], 3);
      expect(lesson.text('strategies'), 'التعلم التعاوني\nالتعلم باللعب');
    });
  });

  group('PreparationHistoryCubit', () {
    late MockPreparationPrintRepository repo;
    setUp(() => repo = MockPreparationPrintRepository());

    test('loads finished preparations and pages on', () async {
      when(() => repo.getPreparations(page: 1, onlyDone: true)).thenAnswer((_) async => Right(_page([1, 2], last: 2)));
      when(() => repo.getPreparations(page: 2, onlyDone: true)).thenAnswer((_) async => Right(_page([3], current: 2, last: 2)));
      final cubit = PreparationHistoryCubit(repo);
      await cubit.load();
      expect(cubit.state.items.map((e) => e.id), [1, 2]);
      expect(cubit.state.hasMore, isTrue);
      await cubit.loadMore();
      expect(cubit.state.items.map((e) => e.id), [1, 2, 3]);
      expect(cubit.state.hasMore, isFalse);
    });

    test('keeps the order lessons are ticked in, up to 10', () {
      final cubit = PreparationHistoryCubit(repo);
      for (final id in [5, 2, 9]) {
        cubit.toggle(id);
      }
      expect(cubit.state.picked, [5, 2, 9]);
      cubit.toggle(2);
      expect(cubit.state.picked, [5, 9]);
      for (var id = 100; id < 120; id++) {
        cubit.toggle(id);
      }
      expect(cubit.state.picked.length, PreparationHistoryState.maxPicked);
    });

    test('printing makes one document from the ticked lessons', () async {
      when(() => repo.createDocument([5, 9])).thenAnswer((_) async => Right(_doc(77, {})));
      final cubit = PreparationHistoryCubit(repo)
        ..toggle(5)
        ..toggle(9);
      await cubit.print();
      expect(cubit.state.createdDocumentId, 77);
      expect(cubit.state.picked, isEmpty);
    });

    test('a failure is shown and nothing opens', () async {
      when(() => repo.createDocument([4])).thenAnswer((_) async => const Left(_Failure('لم نجد تحضيرًا مكتملًا')));
      final cubit = PreparationHistoryCubit(repo);
      await cubit.print([4]);
      expect(cubit.state.createdDocumentId, isNull);
      expect(cubit.state.error, 'لم نجد تحضيرًا مكتملًا');
    });
  });

  group('PreparationPrintCubit', () {
    late MockDocumentsRepository docs;
    setUp(() => docs = MockDocumentsRepository());

    test('saves the edited lessons and keeps the other fields', () async {
      final input = {
        'academic_year': '1448 هـ',
        'lessons': [
          {'preparation_id': 3, 'lesson_title': 'الكسور', 'preparation_text': 'قديم'},
        ],
      };
      when(() => docs.getDocument(12)).thenAnswer((_) async => Right(_doc(12, input)));
      when(() => docs.updateDocument(12, any(), status: any(named: 'status'))).thenAnswer((_) async => Right(_doc(12, input)));

      final cubit = PreparationPrintCubit(documentId: 12, documents: docs);
      await cubit.load();
      expect(cubit.state.lessons.single.text('lesson_title'), 'الكسور');

      cubit.updateText(0, PrintSection.all.firstWhere((s) => s.key == 'preparation_text'), 'جديد');
      await cubit.save(followUp: DocumentFollowUp.export);

      final sent = verify(() => docs.updateDocument(12, captureAny(), status: DocumentStatus.finalized)).captured.single as Map<String, dynamic>;
      expect(sent['academic_year'], '1448 هـ');
      expect((sent['lessons'] as List).single, {'preparation_id': 3, 'lesson_title': 'الكسور', 'preparation_text': 'جديد'});
      expect(cubit.state.followUp, DocumentFollowUp.export);
      expect(cubit.state.feedback, 'document_saved');
    });
  });
}
