import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/data/repositories/tahsili_repository.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';

class MockTahsiliRepository extends Mock implements TahsiliRepository {}

class _TestFailure extends Failure {
  const _TestFailure(super.message);
}

void main() {
  const domainMechanics = TahsiliDomainOption(
    id: 'mechanics',
    name: 'الميكانيكا',
    outcome: 'تطبيق قوانين نيوتن للحركة وحساب التسارع والقوة',
  );

  const domainElectromagnetism = TahsiliDomainOption(
    id: 'electromagnetism',
    name: 'الكهرومغناطيسية',
    outcome: 'حساب المجال المغناطيسي والقوة الدافعة الكهربائية الحثية',
  );

  const domainOrganicChemistry = TahsiliDomainOption(
    id: 'organic_chem',
    name: 'الكيمياء العضوية',
    outcome: 'تسمية المركبات الهيدروكربونية وتحديد المجموعات الوظيفية',
  );

  const subjectPhysics = TahsiliSubjectOption(
    id: 'physics',
    name: 'الفيزياء',
    available: true,
    domains: [domainMechanics, domainElectromagnetism],
    limits: TahsiliLimits(min: 5, max: 25, defaultCount: 10),
  );

  const subjectChemistry = TahsiliSubjectOption(
    id: 'chemistry',
    name: 'الكيمياء',
    available: true,
    domains: [domainOrganicChemistry],
    limits: TahsiliLimits(min: 5, max: 25, defaultCount: 10),
  );

  const subjectBiologyUnavailable = TahsiliSubjectOption(
    id: 'biology',
    name: 'الأحياء',
    available: false,
    domains: [],
  );

  const defaultOptions = TahsiliOptions(
    notice: 'أسئلة تدريبية جديدة بأسلوب التحصيلي، وليست من أسئلة الهيئة',
    limits: TahsiliLimits(min: 5, max: 25, defaultCount: 10),
    subjects: [subjectPhysics, subjectChemistry, subjectBiologyUnavailable],
  );

  const sampleQuestion = TahsiliQuestion(
    text: 'ما وحدة قياس القوة في النظام الدولي للوحدات؟',
    options: ['النيوتن', 'الجول', 'الواط', 'الباسكال'],
    answer: 'النيوتن',
    check: 'القوة = الكتلة × التسارع، وتقاس بنيوتن (N = kg·m/s²).',
  );

  const sampleDomain = TahsiliDomain(
    name: 'الميكانيكا',
    outcome: 'تطبيق قوانين نيوتن للحركة وحساب التسارع والقوة',
    questions: [sampleQuestion],
  );

  group('Tahsili models', () {
    test('TahsiliOptions hides subjects with available: false', () {
      final visible = defaultOptions.visibleSubjects;
      expect(visible.length, 2);
      expect(visible.map((s) => s.id).toList(), ['physics', 'chemistry']);
      expect(visible.any((s) => s.id == 'biology'), isFalse);
    });

    test('TahsiliOptions parses backend notice, limits, and subjects correctly', () {
      final json = {
        'notice': 'تنبيه خاص بالتحصيلي',
        'limits': {'min': 5, 'max': 30, 'default': 15},
        'subjects': [
          {
            'key': 'physics',
            'name': 'الفيزياء',
            'available': true,
            'domains': [
              {
                'key': 'waves',
                'name': 'الموجات والضوء',
                'outcome': 'دراسة خصائص الموجات الكهرومغناطيسية',
              }
            ],
          },
          {
            'key': 'math',
            'name': 'الرياضيات',
            'available': false,
            'domains': [],
          }
        ]
      };

      final options = TahsiliOptions.fromJson(json);
      expect(options.notice, 'تنبيه خاص بالتحصيلي');
      expect(options.limits.min, 5);
      expect(options.limits.max, 30);
      expect(options.limits.defaultCount, 15);
      expect(options.subjects.length, 2);
      expect(options.visibleSubjects.length, 1);
      expect(options.visibleSubjects.first.id, 'physics');
      expect(options.visibleSubjects.first.domains.first.name, 'الموجات والضوء');
    });

    test('TahsiliQuestion requires non-empty text, >= 2 options, and valid answer in options', () {
      expect(sampleQuestion.isComplete, isTrue);

      final noAnswer = sampleQuestion.copyWith(answer: 'الكلفن');
      expect(noAnswer.isComplete, isFalse);

      final emptyText = sampleQuestion.copyWith(text: '   ');
      expect(emptyText.isComplete, isFalse);

      final oneOption = sampleQuestion.copyWith(options: ['النيوتن']);
      expect(oneOption.isComplete, isFalse);
    });

    test('TahsiliQuestion parses check/solution field and normalizes answer', () {
      final q = TahsiliQuestion.fromJson({
        'question_text': 'تسارع الجاذبية الأرضية يساوي تقريباً:',
        'options': ['أ) 9.8 م/ث²', 'ب) 8.9 م/ث²', 'ج) 10.5 م/ث²', 'د) 12 م/ث²'],
        'correct_answer': 'أ',
        'check': 'قيمة تسارع السقوط الحر قرب سطح الأرض هي 9.8 m/s².',
      });

      expect(q.text, 'تسارع الجاذبية الأرضية يساوي تقريباً:');
      expect(q.options, ['9.8 م/ث²', '8.9 م/ث²', '10.5 م/ث²', '12 م/ث²']);
      expect(q.answer, '9.8 م/ث²');
      expect(q.check, 'قيمة تسارع السقوط الحر قرب سطح الأرض هي 9.8 m/s².');
      expect(q.isComplete, isTrue);
    });

    test('TahsiliJob parses status and domains correctly', () {
      final job = TahsiliJob.fromJson({
        'id': 77,
        'status': 'done',
        'result': {
          'domains': [
            {
              'name': 'الميكانيكا',
              'outcome': 'قوانين الحركة',
              'questions': [
                {
                  'question_text': 'ما صيغة قانون نيوتن الثاني؟',
                  'options': ['F = ma', 'E = mc²', 'V = IR', 'P = IV'],
                  'correct_answer': 'F = ma',
                  'check': 'القوة المحصلة تساوي حاصل ضرب الكتلة في التسارع.',
                }
              ]
            }
          ]
        }
      });

      expect(job.isDone, isTrue);
      expect(job.domains.length, 1);
      expect(job.domains.first.name, 'الميكانيكا');
      expect(job.domains.first.questions.length, 1);
      expect(job.domains.first.questions.first.check, contains('القوة المحصلة'));
    });
  });

  group('TahsiliCubit (choose -> generate -> review -> save)', () {
    late MockTahsiliRepository repo;
    late TahsiliCubit cubit;

    setUp(() {
      repo = MockTahsiliRepository();
      cubit = TahsiliCubit(repo, pollEvery: Duration.zero);
    });

    tearDown(() {
      cubit.close();
    });

    test('Step 2 (Choose): loadOptions sets subjects (hiding unavailable), selects physics, domains and default questions', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));

      await cubit.loadOptions();

      expect(cubit.state.isLoadingOptions, isFalse);
      expect(cubit.state.availableSubjects.length, 2);
      expect(cubit.state.selectedSubject?.id, 'physics');
      expect(cubit.state.selectedDomainIds.contains('mechanics'), isTrue);
      expect(cubit.state.selectedDomainIds.contains('electromagnetism'), isTrue);
      expect(cubit.state.questionsCount, 10);
      expect(cubit.state.canGenerate, isTrue);
    });

    test('Step 2: selectSubject, toggleDomain, toggleSelectAllDomains, setQuestionsCount', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      // Switch to Chemistry
      cubit.selectSubject(subjectChemistry);
      expect(cubit.state.selectedSubject?.id, 'chemistry');
      expect(cubit.state.selectedDomainIds, {'organic_chem'});

      // Switch back to Physics
      cubit.selectSubject(subjectPhysics);
      expect(cubit.state.selectedSubject?.id, 'physics');
      expect(cubit.state.selectedDomainIds, {'mechanics', 'electromagnetism'});

      // Toggle domain
      cubit.toggleDomain('electromagnetism');
      expect(cubit.state.selectedDomainIds, {'mechanics'});

      // Toggle select all
      cubit.toggleSelectAllDomains();
      expect(cubit.state.selectedDomainIds, {'mechanics', 'electromagnetism'});

      cubit.toggleSelectAllDomains();
      expect(cubit.state.selectedDomainIds.isEmpty, isTrue);
      expect(cubit.state.canGenerate, isFalse);

      cubit.toggleSelectAllDomains();
      expect(cubit.state.canGenerate, isTrue);

      // Questions count slider clamping
      cubit.setQuestionsCount(10);
      expect(cubit.state.questionsCount, 10);
      cubit.setQuestionsCount(2);
      expect(cubit.state.questionsCount, 5); // Clamped to min 5
      cubit.setQuestionsCount(40);
      expect(cubit.state.questionsCount, 25); // Clamped to max 25
    });

    test('Step 3 & 4 (Generate & Review): calls generate with subject key, polls until done, transitions to review', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      when(() => repo.generate(
            subject: 'physics',
            domainIds: any(named: 'domainIds'),
            questionsCount: 10,
          )).thenAnswer((_) async => const Right(TahsiliJob(id: 88, status: 'pending')));

      when(() => repo.getJob(88)).thenAnswer(
        (_) async => const Right(
          TahsiliJob(
            id: 88,
            status: 'done',
            domains: [sampleDomain],
          ),
        ),
      );

      await cubit.generate();

      expect(cubit.state.step, TahsiliStep.review);
      expect(cubit.state.title, contains('اختبار تدريبي بأسلوب التحصيلي — الفيزياء'));
      expect(cubit.state.domains.length, 1);
      expect(cubit.state.totalQuestionsCount, 1);
      expect(cubit.state.domains.first.questions.first.check, contains('القوة = الكتلة × التسارع'));
      expect(cubit.state.allComplete, isTrue);
    });

    test('Step 4: edit domain, add question, remove question in review', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      when(() => repo.generate(
            subject: any(named: 'subject'),
            domainIds: any(named: 'domainIds'),
            questionsCount: any(named: 'questionsCount'),
          )).thenAnswer((_) async => const Right(TahsiliJob(id: 88, status: 'done', domains: [sampleDomain])));

      await cubit.generate();

      // Rename domain
      cubit.renameDomain(0, 'الميكانيكا الكلاسيكية');
      expect(cubit.state.domains.first.name, 'الميكانيكا الكلاسيكية');

      // Add question
      cubit.addQuestion(0);
      expect(cubit.state.totalQuestionsCount, 2);
      expect(cubit.state.allComplete, isFalse);

      // Remove added question
      cubit.removeQuestion(0, 1);
      expect(cubit.state.totalQuestionsCount, 1);
      expect(cubit.state.allComplete, isTrue);
    });

    test('Step 5 (Save): incomplete question blocks saving; valid exam saves and returns id', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      when(() => repo.generate(
            subject: any(named: 'subject'),
            domainIds: any(named: 'domainIds'),
            questionsCount: any(named: 'questionsCount'),
          )).thenAnswer((_) async => const Right(TahsiliJob(id: 88, status: 'done', domains: [sampleDomain])));

      await cubit.generate();

      // Incomplete question blocks saving
      cubit.updateQuestion(0, 0, sampleQuestion.copyWith(answer: ''));
      await cubit.save();

      expect(cubit.state.error, 'tahsili_missing_answers');
      verifyNever(() => repo.save(
            subject: any(named: 'subject'),
            title: any(named: 'title'),
            domains: any(named: 'domains'),
          ));

      // Restore complete question and save successfully
      cubit.updateQuestion(0, 0, sampleQuestion);
      when(() => repo.save(
            subject: 'physics',
            title: any(named: 'title'),
            domains: any(named: 'domains'),
          )).thenAnswer((_) async => const Right(200));

      await cubit.save();

      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.savedExamId, 200);
    });

    test('Step 5: handles 422 ValidationFailure with question and domain paths', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      when(() => repo.generate(
            subject: any(named: 'subject'),
            domainIds: any(named: 'domainIds'),
            questionsCount: any(named: 'questionsCount'),
          )).thenAnswer((_) async => const Right(TahsiliJob(id: 88, status: 'done', domains: [sampleDomain])));

      await cubit.generate();

      // Server returns 422 with field errors
      when(() => repo.save(
            subject: any(named: 'subject'),
            title: any(named: 'title'),
            domains: any(named: 'domains'),
          )).thenAnswer((_) async => const Left(ValidationFailure('فشل التحقق من صحة البيانات', {
            'skills.0.questions.0.text': ['نص السؤال مطلوب'],
            'title': ['عنوان الاختبار مطلوب'],
          })));

      await cubit.save();

      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.hasFieldError('skills.0.questions.0.text'), isTrue);
      expect(cubit.state.fieldError('skills.0.questions.0.text'), 'نص السؤال مطلوب');
      expect(cubit.state.hasFieldError('title'), isTrue);
      expect(cubit.state.fieldError('title'), 'عنوان الاختبار مطلوب');
    });

    test('Error handling: failed generation job returns to choose step with retry error', () async {
      when(() => repo.getOptions()).thenAnswer((_) async => const Right(defaultOptions));
      await cubit.loadOptions();

      when(() => repo.generate(
            subject: any(named: 'subject'),
            domainIds: any(named: 'domainIds'),
            questionsCount: any(named: 'questionsCount'),
          )).thenAnswer((_) async => const Left(_TestFailure('تعذر الاتصال بالخادم')));

      await cubit.generate();

      expect(cubit.state.step, TahsiliStep.choose);
      expect(cubit.state.error, 'تعذر الاتصال بالخادم');
    });
  });
}
