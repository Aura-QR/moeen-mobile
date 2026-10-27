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
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

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
        {
          'name': 'الجمع',
          'mastery': 80,
          'groups': [
            {'id': 1, 'name': 'رابع 1', 'mastery': 100},
            {'id': 2, 'name': 'رابع 2', 'mastery': 50},
          ],
          'weak_students': [
            {'submission_id': 9, 'name': 'سالم', 'mastery': 50},
          ],
        },
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
    test('mcq/true_false need a valid answer; fill_blank only needs text (answer is optional)', () {
      expect(_skill.questions[0].isComplete, isTrue);
      expect(_skill.questions[0].copyWith(answer: '40').isComplete, isFalse);
      // fill_blank: a blank answer is allowed — the teacher may fill it later.
      expect(const DiagnosticQuestion(type: 'fill_blank', text: 'س', answer: ' ').isComplete, isTrue);
      expect(const DiagnosticQuestion(type: 'fill_blank', text: ' ').isComplete, isFalse);
      expect(_skill.toJson()['questions'][1]['options'], isEmpty);
    });

    test('AI-generated questions normalize mcq options/answers and true_false variants so they are immediately complete', () {
      final job = DiagnosticJob.fromJson({
        'id': 10,
        'status': 'done',
        'result': {
          'skills': [
            {
              'name': 'حساب المساحة',
              'lesson_ids': [1, 2],
              'questions': [
                {
                  'type': 'mcq',
                  'question_text': 'مستطيل طوله 6 سم وعرضه 2 سم، ما مساحته؟',
                  'options': ['12 سم مربع ', '8 سم مربع', '16 سم مربع', '4 سم مربع'],
                  'correct_answer': 'أ) 12 سم مربع',
                },
                {
                  'type': 'mcq',
                  'question_text': 'مربع طول ضلعه 3 سم، مساحته:',
                  'options': ['6 سم مربع', '9 سم مربع', '12 سم مربع'],
                  'correct_answer': 'ب',
                },
                {
                  'type': 'mcq',
                  'question_text': 'سؤال بخيار صحيح خارج القائمة:',
                  'options': ['خاطئ 1', 'خاطئ 2', 'خاطئ 3'],
                  'correct_answer': 'الإجابة الصحيحة',
                },
                {
                  'type': 'mcq',
                  'question_text': 'سؤال بدون إجابة محددة من الذكاء:',
                  'options': ['الخيار الأول', 'الخيار الثاني'],
                  'correct_answer': '',
                },
                {
                  'type': 'true_false',
                  'question_text': 'مساحة المستطيل = الطول × العرض',
                  'correct_answer': true,
                },
                {
                  'type': 'true_false',
                  'question_text': 'مساحة المربع = الطول + العرض',
                  'correct_answer': 'خطا',
                },
                {
                  'type': 'true_false',
                  'question_text': 'الوحدة المربعة تقيس المساحة',
                  'correct_answer': '',
                },
              ],
            },
          ],
        },
      });

      final questions = job.skills.single.questions;
      expect(questions.length, 7);
      expect(questions[0].answer, '12 سم مربع');
      expect(questions[1].answer, '9 سم مربع');
      expect(questions[2].options.first, 'الإجابة الصحيحة');
      expect(questions[2].answer, 'الإجابة الصحيحة');
      expect(questions[3].answer, 'الخيار الأول');
      expect(questions[4].answer, 'صح');
      expect(questions[5].answer, 'خطأ');
      expect(questions[6].answer, 'صح');
      expect(questions.every((q) => q.isComplete), isTrue);
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
      when(() => repo.getSource(12)).thenAnswer(
        (_) async => const Right(
          DiagnosticSource(mode: 'previous_grade', subject: 'الرياضيات', grade: 'الرابع', sourceGrade: 'الثالث', lessonsCount: 30),
        ),
      );
    });

    test('cascading stage -> track -> grade -> subject selection sorts stages, resets downstream, and loads source', () async {
      final mathSubject = CurriculumSubjectModel(id: 12, name: 'الرياضيات');
      final grade4 = CurriculumGradeModel(id: 4, name: 'الرابع', subjects: [mathSubject]);
      final hsGeneralGrade = CurriculumGradeModel(id: 10, name: 'الأول الثانوي', track: 'المسار العام', subjects: [mathSubject]);
      final hsCsGrade = CurriculumGradeModel(id: 11, name: 'الثاني الثانوي', track: 'مسار الحاسب', subjects: []);

      final secondaryStage = CurriculumStageModel(id: 3, name: 'المرحلة الثانوية', grades: [hsGeneralGrade, hsCsGrade]);
      final primaryStage = CurriculumStageModel(id: 1, name: 'المرحلة الابتدائية', grades: [grade4]);

      when(() => repo.getStages()).thenAnswer((_) async => Right([secondaryStage, primaryStage]));

      await cubit.loadStages();
      expect(cubit.state.stages.map((s) => s.name).toList(), ['المرحلة الابتدائية', 'المرحلة الثانوية']);

      cubit.selectStage(primaryStage);
      expect(cubit.state.availableTracks, isEmpty);
      expect(cubit.state.availableGrades, [grade4]);

      cubit.selectGrade(grade4);
      await cubit.selectSubject(mathSubject);
      expect(cubit.state.subjectId, 12);
      expect(cubit.state.subjectLabel, 'الرياضيات — الرابع');
      expect(cubit.state.source?.sourceGrade, 'الثالث');

      // Changing stage clears grade, subject, and source; secondary stage requires track first.
      cubit.selectStage(secondaryStage);
      expect(cubit.state.selectedGrade, isNull);
      expect(cubit.state.selectedSubject, isNull);
      expect(cubit.state.subjectId, isNull);
      expect(cubit.state.source, isNull);
      expect(cubit.state.availableTracks, ['المسار العام', 'مسار الحاسب']);
      expect(cubit.state.availableGrades, isEmpty);

      cubit.selectTrack('المسار العام');
      expect(cubit.state.availableGrades, [hsGeneralGrade]);
    });

    test('the AI result opens for review with a title, and is saved immediately without manual answer selection', () async {
      await cubit.pickSubject(12, 'الرياضيات — الرابع');
      when(() => repo.start(subjectId: 12, skills: 5, perSkill: 3)).thenAnswer((_) async => const Right(DiagnosticJob(id: 4, status: 'pending')));
      when(() => repo.getJob(4)).thenAnswer((_) async => const Right(DiagnosticJob(id: 4, status: 'done', skills: [_skill])));
      await cubit.generate();
      expect(cubit.state.step, DiagnosticStep.review);
      expect(cubit.state.title, 'اختبار تشخيصي — الرياضيات — الرابع');
      expect(cubit.state.questionsCount, 2);
      expect(cubit.state.allComplete, isTrue);

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
