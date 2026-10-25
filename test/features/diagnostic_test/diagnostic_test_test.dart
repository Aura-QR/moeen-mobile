import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnosis_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

class MockDiagnosticRepository extends Mock implements DiagnosticRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class _Failure extends Failure {
  const _Failure(super.message);
}

const _skill = DiagnosticSkill(name: 'جدول الضرب', lessonIds: [3], questions: [
  DiagnosticQuestion(type: 'mcq', text: '6 × 7 =', options: ['42', '36'], answer: '42'),
  DiagnosticQuestion(type: 'true_false', text: '2 × 5 = 10', answer: 'صح'),
]);

Diagnosis _diagnosis() => Diagnosis.fromJson({
      'thresholds': {'weak_below': 60, 'strong_from': 90},
      'skills': [
        {'name': 'الجمع', 'mastery': 80, 'groups': [{'id': 1, 'name': 'رابع 1', 'mastery': 100}, {'id': 2, 'name': 'رابع 2', 'mastery': 50}], 'weak_students': [{'submission_id': 9, 'name': 'سالم', 'mastery': 50}]},
        {'name': 'الضرب', 'mastery': 33.3, 'groups': [], 'weak_students': []},
      ],
      'students': [
        {'submission_id': 8, 'name': 'أحمد', 'group_id': 1, 'group': 'رابع 1', 'skills': {'الجمع': 100, 'الضرب': null}, 'weak_skills': []},
        {'submission_id': 9, 'name': 'سالم', 'group_id': 2, 'group': 'رابع 2', 'skills': {'الجمع': 50, 'الضرب': 0}, 'weak_skills': ['الجمع', 'الضرب']},
      ],
      'to_review': 0,
      'remedial': {'plan_type': 'general', 'weaknesses': ['الضرب'], 'students': ['سالم']},
      'enrichment': {'plan_type': 'general', 'students': []},
    });

void main() {
  group('models', () {
    test('a question is complete only with an answer, and for mcq one of its options', () {
      expect(_skill.questions[0].isComplete, isTrue);
      expect(_skill.questions[0].copyWith(answer: '40').isComplete, isFalse);
      expect(const DiagnosticQuestion(type: 'fill_blank', text: 'س', answer: ' ').isComplete, isFalse);
      expect(_skill.toJson()['questions'][1]['options'], isEmpty);
    });

    test('a diagnosis is read with plan counts and null masteries', () {
      final d = _diagnosis();
      expect(d.remedialCount, 1);
      expect(d.enrichmentCount, 0);
      expect(d.students.first.skills['الضرب'], isNull);
    });
  });

  group('create', () {
    late MockDiagnosticRepository repo;
    late DiagnosticCreateCubit cubit;

    setUp(() {
      repo = MockDiagnosticRepository();
      cubit = DiagnosticCreateCubit(repo, pollEvery: Duration.zero);
      when(() => repo.getSource(12)).thenAnswer((_) async => const Right(DiagnosticSource(mode: 'previous_grade', subject: 'الرياضيات', grade: 'الرابع', sourceGrade: 'الثالث', lessonsCount: 30)));
    });

    test('the AI result opens for review with a title, and is saved', () async {
      await cubit.pickSubject(12, 'الرياضيات — الرابع');
      when(() => repo.start(subjectId: 12, skills: 5, perSkill: 3)).thenAnswer((_) async => const Right(DiagnosticJob(id: 4, status: 'pending')));
      when(() => repo.getJob(4)).thenAnswer((_) async => const Right(DiagnosticJob(id: 4, status: 'done', skills: [_skill])));
      await cubit.generate();
      expect(cubit.state.step, DiagnosticStep.review);
      expect(cubit.state.title, 'اختبار تشخيصي — الرياضيات — الرابع');
      expect(cubit.state.questionsCount, 2);

      when(() => repo.save(subjectId: 12, title: any(named: 'title'), skills: any(named: 'skills'))).thenAnswer((_) async => const Right(55));
      await cubit.save();
      expect(cubit.state.savedExamId, 55);
    });

    test('an incomplete question blocks saving, and a failed job goes back with its error', () async {
      await cubit.pickSubject(12, 'x');
      when(() => repo.start(subjectId: 12, skills: 5, perSkill: 3)).thenAnswer((_) async => const Right(DiagnosticJob(id: 4, status: 'done', skills: [_skill])));
      await cubit.generate();
      cubit.updateQuestion(0, 0, _skill.questions[0].copyWith(answer: ''));
      await cubit.save();
      expect(cubit.state.error, 'diagnostic_missing_answers');
      verifyNever(() => repo.save(subjectId: any(named: 'subjectId'), title: any(named: 'title'), skills: any(named: 'skills')));

      cubit.restart();
      when(() => repo.start(subjectId: 12, skills: 5, perSkill: 3)).thenAnswer((_) async => const Right(DiagnosticJob(id: 5, status: 'failed', error: 'تعذر')));
      await cubit.generate();
      expect(cubit.state.step, DiagnosticStep.pick);
      expect(cubit.state.error, 'تعذر');
    });
  });

  group('diagnosis', () {
    test('a class filter changes the masteries and students, and a plan is saved to open', () async {
      final repo = MockDiagnosticRepository();
      final docs = MockDocumentsRepository();
      when(() => repo.getDiagnosis(7)).thenAnswer((_) async => Right(_diagnosis()));
      final cubit = DiagnosisCubit(testId: 7, repository: repo, documents: docs);
      await cubit.load();

      final add = cubit.state.diagnosis!.skills.first;
      expect(cubit.state.masteryOf(add), 80);
      cubit.setGroup(2);
      expect(cubit.state.masteryOf(add), 50);
      expect(cubit.state.students.map((s) => s.name), ['سالم']);
      cubit.setGroup(null);
      expect(cubit.state.students.length, 2);

      when(() => docs.createDocument(type: 'remedial_plan', input: any(named: 'input'), status: 'draft'))
          .thenAnswer((_) async => Right(DocumentModel.fromJson({'id': 31, 'type': 'remedial_plan', 'title': 't', 'status': 'draft', 'input': {}})));
      await cubit.createPlan('remedial_plan');
      expect(cubit.state.createdPlan, (type: 'remedial_plan', id: 31));
    });

    test('a load error is kept for the error view', () async {
      final repo = MockDiagnosticRepository();
      when(() => repo.getDiagnosis(7)).thenAnswer((_) async => const Left(_Failure('هذا الاختبار ليس اختبارًا تشخيصيًا.')));
      final cubit = DiagnosisCubit(testId: 7, repository: repo, documents: MockDocumentsRepository());
      await cubit.load();
      expect(cubit.state.diagnosis, isNull);
      expect(cubit.state.error, contains('تشخيصي'));
    });
  });
}
