import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/data/repositories/nafs_repository.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';

class MockNafsRepository extends Mock implements NafsRepository {}

class _TestFailure extends Failure {
  const _TestFailure(super.message);
}

void main() {
  const domainMath1 = NafsDomainOption(
    id: 'd_math_1',
    name: 'الأعداد والعمليات',
    outcome: 'إجراء العمليات الحسابية على الأعداد الكلية',
  );
  const domainMath2 = NafsDomainOption(
    id: 'd_math_2',
    name: 'الهندسة والقياس',
    outcome: 'حساب مساحات ومحيطات الأشكال الهندسية',
  );
  const domainReading1 = NafsDomainOption(
    id: 'd_read_1',
    name: 'استيعاب المقروء',
    outcome: 'تحديد الفكرة الرئيسة للنص المقروء واستخلاص المعاني',
  );

  const subjectMath = NafsSubjectOption(
    id: 'math',
    name: 'الرياضيات',
    subjectIds: [101],
    realExamQuestions: 20,
    domains: [domainMath1, domainMath2],
  );

  const subjectReading = NafsSubjectOption(
    id: 'reading',
    name: 'القراءة',
    subjectIds: [102],
    realExamQuestions: 20,
    domains: [domainReading1],
  );

  const subjectScienceEmpty = NafsSubjectOption(
    id: 'science',
    name: 'العلوم',
    subjectIds: [],
    realExamQuestions: 20,
    domains: [],
  );

  const gradePrimary3 = NafsGradeOption(
    id: 'primary_3',
    name: 'الصف الثالث الابتدائي',
    subjects: [subjectReading, subjectMath, subjectScienceEmpty],
  );

  const gradePrimary6 = NafsGradeOption(
    id: 'primary_6',
    name: 'الصف السادس الابتدائي',
    subjects: [
      subjectReading,
      subjectMath,
      NafsSubjectOption(
        id: 'science',
        name: 'العلوم',
        subjectIds: [103],
        realExamQuestions: 20,
        domains: [],
      ),
    ],
  );

  const sampleQuestion = NafsQuestion(
    text: 'ما حاصل ضرب 6 × 7؟',
    options: ['42', '36', '48', '54'],
    answer: '42',
  );

  const sampleDomain = NafsDomain(
    name: 'الأعداد والعمليات',
    outcome: 'إجراء العمليات الحسابية',
    lessonIds: [101],
    questions: [sampleQuestion],
  );

  group('Nafs models', () {
    test('NafsGradeOption hides subjects with empty subject_ids (Primary 3 shows only reading and math)', () {
      final visible = gradePrimary3.visibleSubjects;
      expect(visible.length, 2);
      expect(visible.map((s) => s.id).toList(), ['reading', 'math']);
      expect(visible.any((s) => s.id == 'science'), isFalse);

      final p6Visible = gradePrimary6.visibleSubjects;
      expect(p6Visible.length, 3);
      expect(p6Visible.any((s) => s.id == 'science'), isTrue);
    });

    test('Nafs models parse backend keys (key, label, real_test) correctly', () {
      final backendJson = {
        'key': 'p3',
        'label': 'الثالث الابتدائي',
        'subjects': [
          {
            'key': 'reading',
            'label': 'القراءة',
            'real_test': {'questions': 20, 'minutes': 40},
            'domains': [
              {
                'key': 'vocabulary',
                'name': 'دلالات الألفاظ',
                'outcome': 'استنتاج معاني المفردات',
              }
            ],
            'subject_ids': [58],
          }
        ],
      };
      final grade = NafsGradeOption.fromJson(backendJson);
      expect(grade.id, 'p3');
      expect(grade.name, 'الثالث الابتدائي');
      expect(grade.subjects.length, 1);
      final subj = grade.subjects.first;
      expect(subj.id, 'reading');
      expect(subj.name, 'القراءة');
      expect(subj.realExamQuestions, 20);
      expect(subj.domains.length, 1);
      expect(subj.domains.first.id, 'vocabulary');
      expect(subj.domains.first.name, 'دلالات الألفاظ');
    });

    test('NafsQuestion requires non-empty text, at least 2 options, and valid answer in options', () {
      expect(sampleQuestion.isComplete, isTrue);

      final noAnswer = sampleQuestion.copyWith(answer: '99');
      expect(noAnswer.isComplete, isFalse);

      final emptyText = sampleQuestion.copyWith(text: '   ');
      expect(emptyText.isComplete, isFalse);

      final oneOption = sampleQuestion.copyWith(options: ['42']);
      expect(oneOption.isComplete, isFalse);
    });

    test('NafsQuestion normalizes AI letter prefixes and resolves matching answer', () {
      final q = NafsQuestion.fromJson({
        'question_text': 'عاصمة المملكة العربية السعودية هي:',
        'options': ['أ) الرياض', 'ب) جدة', 'ج) الدمام', 'د) مكة المكرمة'],
        'correct_answer': 'أ',
      });

      expect(q.text, 'عاصمة المملكة العربية السعودية هي:');
      expect(q.options, ['الرياض', 'جدة', 'الدمام', 'مكة المكرمة']);
      expect(q.answer, 'الرياض');
      expect(q.isComplete, isTrue);
    });

    test('NafsJob parses result with passage and domains correctly', () {
      final job = NafsJob.fromJson({
        'id': 15,
        'status': 'done',
        'result': {
          'passage': 'نص تجريبي للقراءة في اختبار نافس.',
          'domains': [
            {
              'name': 'استيعاب المقروء',
              'outcome': 'فهم الأفكار',
              'questions': [
                {
                  'question_text': 'ما موضوع النص؟',
                  'options': ['القراءة', 'الرياضة', 'العلوم', 'التاريخ'],
                  'correct_answer': 'القراءة',
                }
              ],
            }
          ],
        },
      });

      expect(job.isDone, isTrue);
      expect(job.passage, 'نص تجريبي للقراءة في اختبار نافس.');
      expect(job.domains.length, 1);
      expect(job.domains.first.name, 'استيعاب المقروء');
      expect(job.domains.first.questions.length, 1);
      expect(job.domains.first.questions.first.isComplete, isTrue);
    });
  });

  group('NafsCubit (choose -> generate -> review -> save)', () {
    late MockNafsRepository repo;
    late NafsCubit cubit;

    setUp(() {
      repo = MockNafsRepository();
      cubit = NafsCubit(repo, pollEvery: Duration.zero);
    });

    tearDown(() {
      cubit.close();
    });

    test('Step 2 (Choose): loadOptions sets grades, selects grade, subject and domains', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right([gradePrimary6, gradePrimary3]));

      await cubit.loadOptions();

      expect(cubit.state.isLoadingOptions, isFalse);
      expect(cubit.state.grades.length, 2);
      expect(cubit.state.selectedGrade?.id, 'primary_6');
      expect(cubit.state.selectedSubject?.id, 'reading');
      expect(cubit.state.selectedDomainIds.contains('d_read_1'), isTrue);
      expect(cubit.state.questionsCount, 20);
      expect(cubit.state.isRealExam, isTrue);
      expect(cubit.state.canGenerate, isTrue);
    });

    test('Step 2: selectGrade to Primary 3 shows only reading and math', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right([gradePrimary6, gradePrimary3]));
      await cubit.loadOptions();

      cubit.selectGrade(gradePrimary3);

      expect(cubit.state.selectedGrade?.id, 'primary_3');
      expect(cubit.state.availableSubjects.map((s) => s.id).toList(), ['reading', 'math']);

      cubit.selectSubject(subjectMath);
      expect(cubit.state.selectedSubject?.id, 'math');
      expect(cubit.state.selectedDomainIds, {'d_math_1', 'd_math_2'});

      cubit.toggleDomain('d_math_2');
      expect(cubit.state.selectedDomainIds, {'d_math_1'});
      expect(cubit.state.isRealExam, isFalse);

      cubit.toggleRealExam(true);
      expect(cubit.state.selectedDomainIds, {'d_math_1', 'd_math_2'});
      expect(cubit.state.isRealExam, isTrue);
    });

    test('Step 3 & 4 (Generate & Review): starts job, polls until done, transitions to review', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right([gradePrimary6]));
      await cubit.loadOptions();
      cubit.selectSubject(subjectMath);

      when(() => repo.generate(
            grade: 'primary_6',
            subject: 'math',
            subjectIds: [101],
            domainIds: any(named: 'domainIds'),
            domains: any(named: 'domains'),
            questionsCount: 20,
            isRealExam: true,
          )).thenAnswer((_) async => const Right(NafsJob(id: 42, status: 'pending')));

      when(() => repo.getJob(42)).thenAnswer(
        (_) async => const Right(
          NafsJob(
            id: 42,
            status: 'done',
            domains: [sampleDomain],
            passage: 'قطعة تدريبية',
          ),
        ),
      );

      await cubit.generate();

      expect(cubit.state.step, NafsStep.review);
      expect(cubit.state.title, contains('اختبار تدريبي بأسلوب نافس'));
      expect(cubit.state.domains.length, 1);
      expect(cubit.state.totalQuestionsCount, 1);
      expect(cubit.state.passage, 'قطعة تدريبية');
      expect(cubit.state.allComplete, isTrue);
    });

    test('Step 5 (Save): incomplete question blocks saving; valid exam saves and returns id', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right([gradePrimary6]));
      await cubit.loadOptions();
      cubit.selectSubject(subjectMath);

      when(() => repo.generate(
            grade: any(named: 'grade'),
            subject: any(named: 'subject'),
            subjectIds: any(named: 'subjectIds'),
            domainIds: any(named: 'domainIds'),
            domains: any(named: 'domains'),
            questionsCount: any(named: 'questionsCount'),
            isRealExam: any(named: 'isRealExam'),
          )).thenAnswer(
        (_) async => const Right(
          NafsJob(id: 42, status: 'done', domains: [sampleDomain]),
        ),
      );

      await cubit.generate();

      // Incomplete question blocks saving
      cubit.updateQuestion(0, 0, sampleQuestion.copyWith(answer: ''));
      await cubit.save();

      expect(cubit.state.error, 'nafs_missing_answers');
      verifyNever(() => repo.save(
            grade: any(named: 'grade'),
            subject: any(named: 'subject'),
            subjectIds: any(named: 'subjectIds'),
            title: any(named: 'title'),
            domains: any(named: 'domains'),
          ));

      // Restore complete question and save successfully
      cubit.updateQuestion(0, 0, sampleQuestion);
      when(() => repo.save(
            grade: 'primary_6',
            subject: 'math',
            subjectIds: [101],
            title: any(named: 'title'),
            passage: any(named: 'passage'),
            domains: any(named: 'domains'),
          )).thenAnswer((_) async => const Right(105));

      await cubit.save();

      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.savedExamId, 105);
    });

    test('Error handling: failed generation job returns to choose step with error', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right([gradePrimary6]));
      await cubit.loadOptions();

      when(() => repo.generate(
            grade: any(named: 'grade'),
            subject: any(named: 'subject'),
            subjectIds: any(named: 'subjectIds'),
            domainIds: any(named: 'domainIds'),
            domains: any(named: 'domains'),
            questionsCount: any(named: 'questionsCount'),
            isRealExam: any(named: 'isRealExam'),
          )).thenAnswer((_) async => const Left(_TestFailure('تعذر الاتصال بالخادم')));

      await cubit.generate();

      expect(cubit.state.step, NafsStep.choose);
      expect(cubit.state.error, 'تعذر الاتصال بالخادم');
    });
  });
}
