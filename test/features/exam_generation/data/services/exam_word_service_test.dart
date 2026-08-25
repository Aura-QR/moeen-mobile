import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/exam_generation/data/services/exam_word_service.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExamWordService - Language Detection Tests', () {
    test('Test 1: Arabic exam title + Arabic questions', () {
      expect(ExamWordService.isEnglishText('اختبار العلوم للصف الخامس'), isFalse);
      expect(ExamWordService.isEnglishText('ما هو أكبر كوكب في المجموعة الشمسية؟'), isFalse);
    });

    test('Test 2: English exam title + English questions', () {
      expect(ExamWordService.isEnglishText('Science Exam Grade 5'), isTrue);
      expect(ExamWordService.isEnglishText('What is the largest planet in the solar system?'), isTrue);
    });

    test('Test 3: Arabic question + English options', () {
      expect(ExamWordService.isEnglishText('اختر الإجابة الصحيحة:'), isFalse);
      expect(ExamWordService.isEnglishText('Jupiter'), isTrue);
      expect(ExamWordService.isEnglishText('Mars'), isTrue);
    });

    test('Test 4: English question + English options', () {
      expect(ExamWordService.isEnglishText('Select the correct answer:'), isTrue);
      expect(ExamWordService.isEnglishText('Paris'), isTrue);
    });

    test('Test 5: Arabic question containing English technical terms', () {
      expect(ExamWordService.isEnglishText('ما هو HTTP Request؟'), isFalse);
    });

    test('Test 6: English question containing Arabic', () {
      expect(ExamWordService.isEnglishText('What does كلمة "variable" mean?'), isTrue);
    });

    test('Test 7: Numbers', () {
      expect(ExamWordService.isEnglishText('ما هو الرقم 12345؟'), isFalse);
    });

    test('Test 8: URLs', () {
      expect(ExamWordService.isEnglishText('https://example.com'), isTrue);
    });

    test('Test 9: Email', () {
      expect(ExamWordService.isEnglishText('teacher@example.com'), isTrue);
    });

    test('Test 10: Mixed question', () {
      expect(ExamWordService.isEnglishText('ما الفرق بين GET و POST في HTTP؟'), isFalse);
    });

    test('Test 11: Matching with mixed languages', () {
      expect(ExamWordService.isEnglishText('HTTP'), isTrue);
      expect(ExamWordService.isEnglishText('بروتوكول نقل النص الفائق'), isFalse);
    });

    test('Test 12: Correct answers in Arabic and English', () {
      expect(ExamWordService.isEnglishText('الرياض'), isFalse);
      expect(ExamWordService.isEnglishText('Riyadh'), isTrue);
    });
  });

  group('ExamWordService - Document XML Generation Tests', () {
    late ExamEntity sampleExam;

    setUp(() {
      sampleExam = ExamEntity(
        id: 1,
        teacherId: 1,
        title: 'Mixed Language Exam - اختبار متعدد اللغات',
        status: 'completed',
        totalPoints: 12,
        createdAt: '2026-08-24T12:00:00Z',
        updatedAt: '2026-08-24T12:00:00Z',
        questions: [
          QuestionEntity(
            id: 1,
            lessonId: 1,
            questionOrder: 1,
            questionText: 'ما هو أكبر كوكب في المجموعة الشمسية؟',
            type: 'mcq',
            options: ['المشتري', 'الزهرة', 'المريخ', 'Saturn'],
            correctAnswer: 'المشتري',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 2,
            lessonId: 1,
            questionOrder: 2,
            questionText: 'What is the capital of Saudi Arabia?',
            type: 'mcq',
            options: ['Riyadh', 'Jeddah', 'Makkah', 'Dammam'],
            correctAnswer: 'Riyadh',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 3,
            lessonId: 1,
            questionOrder: 3,
            questionText: 'ما هو HTTP Request؟',
            type: 'true_false',
            options: null,
            correctAnswer: 'صح',
            points: 1,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 4,
            lessonId: 1,
            questionOrder: 4,
            questionText: 'What does كلمة "variable" mean?',
            type: 'true_false',
            options: null,
            correctAnswer: 'True',
            points: 1,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 5,
            lessonId: 1,
            questionOrder: 5,
            questionText: 'Match the terms - طابق المصطلحات',
            type: 'matching',
            options: {
              'column_a': ['HTTP', 'FTP'],
              'column_b': ['نقل صفحات الويب', 'نقل الملفات'],
            },
            correctAnswer: '',
            points: 4,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 6,
            lessonId: 1,
            questionOrder: 6,
            questionText: 'Define the term "Recursion":',
            type: 'short_answer',
            options: null,
            correctAnswer: 'A function calling itself',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
        ],
      );
    });

    test('generateWordBytes produces valid docx archive with proper WordprocessingML', () async {
      final Uint8List bytes = await ExamWordService.generateWordBytes(
        exam: sampleExam,
        showAnswers: true,
        teacherName: 'John Doe / أستاذ أحمد',
        schoolName: 'Moean School',
        educationOffice: 'الإدارة العامة للتعليم',
      );

      expect(bytes, isNotEmpty);

      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.findFile('word/document.xml');
      final stylesFile = archive.findFile('word/styles.xml');
      final settingsFile = archive.findFile('word/settings.xml');

      expect(documentFile, isNotNull);
      expect(stylesFile, isNotNull);
      expect(settingsFile, isNotNull);

      final documentXml = utf8.decode(documentFile!.content as List<int>);
      final stylesXml = utf8.decode(stylesFile!.content as List<int>);
      final settingsXml = utf8.decode(settingsFile!.content as List<int>);

      // 1. Check settings.xml: should NOT contain global forced <w:bidi w:val="1"/>
      expect(settingsXml, isNot(contains('<w:bidi w:val="1"/>')));

      // 2. Check styles.xml: docDefaults should be neutral and not force rtl="1" globally
      expect(stylesXml, contains('<w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Tajawal"/>'));
      expect(stylesXml, isNot(contains('<w:rtl w:val="1"/>')));

      // 3. Check document.xml for Arabic question (Question 1)
      expect(documentXml, contains('ما هو أكبر كوكب في المجموعة الشمسية؟'));
      expect(documentXml, contains('[2 درجة]'));

      // 4. Check document.xml for English question (Question 2 & Question 6)
      expect(documentXml, contains('What is the capital of Saudi Arabia?'));
      expect(documentXml, contains('[2 points]'));
      expect(documentXml, contains('Riyadh'));
      expect(documentXml, contains('Answer: A function calling itself'));

      // 5. Check True/False labels for English question (Question 4)
      expect(documentXml, contains('True'));
      expect(documentXml, contains('False'));

      // 6. Ensure no random \u200F prepended before English text or question numbers
      expect(documentXml, isNot(contains('\u200F2. ')));
      expect(documentXml, isNot(contains('\u200FWhat is the capital')));

      // 7. Verify w:bidi is present for Arabic and w:jc left is used (compensating for bidi flip)
      expect(documentXml, contains('<w:bidi w:val="1"/>'));
      expect(documentXml, contains('<w:jc w:val="left"/>'));
    });

    test('generateWordBytes for Arabic exam sets section bidi and styles bidi to RTL', () async {
      final arabicExam = ExamEntity(
        id: 2,
        teacherId: 1,
        title: 'اختبار العلوم النهائي',
        status: 'completed',
        totalPoints: 5,
        createdAt: '2026-08-25T10:00:00Z',
        updatedAt: '2026-08-25T10:00:00Z',
        questions: [
          QuestionEntity(
            id: 1,
            lessonId: 1,
            questionOrder: 1,
            questionText: 'ما هي عاصمة المملكة العربية السعودية؟',
            type: 'mcq',
            options: ['الرياض', 'جدة', 'مكة', 'Riyadh'],
            correctAnswer: 'الرياض',
            points: 5,
            source: 'ai',
            usageCount: 0,
          ),
        ],
      );

      final Uint8List bytes = await ExamWordService.generateWordBytes(
        exam: arabicExam,
        showAnswers: false,
        teacherName: 'أحمد',
        schoolName: 'مدرسة المواهب',
        educationOffice: 'الرياض',
      );

      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.findFile('word/document.xml')!;
      final stylesFile = archive.findFile('word/styles.xml')!;

      final documentXml = utf8.decode(documentFile.content as List<int>);
      final stylesXml = utf8.decode(stylesFile.content as List<int>);

      // Verify documentXml contains bidi paragraph settings for Arabic question (jc='left' with bidi for visual right alignment)
      expect(documentXml, contains('<w:bidi w:val="1"/>'));
      expect(documentXml, contains('<w:jc w:val="left"/>'));

      // Verify styles.xml schema ordering: bidi -> spacing -> jc
      final bidiIndex = stylesXml.indexOf('<w:bidi w:val="1"/>');
      final spacingIndex = stylesXml.indexOf('<w:spacing');
      final jcIndex = stylesXml.indexOf('<w:jc w:val="left"/>');

      expect(bidiIndex, isNonNegative);
      expect(spacingIndex, isNonNegative);
      expect(jcIndex, isNonNegative);
      expect(bidiIndex, lessThan(spacingIndex));
      expect(spacingIndex, lessThan(jcIndex));
    });

    test('CT_PPr schema element order in all pPr blocks (tabs -> bidi -> spacing -> ind -> jc)', () async {
      final sampleExam = ExamEntity(
        id: 3,
        teacherId: 1,
        title: 'اختبار تجريبي',
        status: 'completed',
        totalPoints: 10,
        createdAt: '2026-08-25T10:00:00Z',
        updatedAt: '2026-08-25T10:00:00Z',
        questions: [
          QuestionEntity(
            id: 1,
            lessonId: 1,
            questionOrder: 1,
            questionText: 'ما هي عاصمة مصر؟',
            type: 'mcq',
            options: ['القاهرة', 'الإسكندرية'],
            correctAnswer: 'القاهرة',
            points: 5,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 2,
            lessonId: 1,
            questionOrder: 2,
            questionText: 'What is photosynthesis?',
            type: 'short_answer',
            options: null,
            correctAnswer: 'Process of turning light into energy',
            points: 5,
            source: 'ai',
            usageCount: 0,
          ),
        ],
      );

      final Uint8List bytes = await ExamWordService.generateWordBytes(
        exam: sampleExam,
        showAnswers: true,
        teacherName: 'أحمد',
        schoolName: 'مدرسة المواهب',
        educationOffice: 'الرياض',
      );

      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.findFile('word/document.xml')!;
      final documentXml = utf8.decode(documentFile.content as List<int>);

      // Find all <w:pPr>...</w:pPr> blocks and verify schema ordering
      final pPrRegex = RegExp(r'<w:pPr>([\s\S]*?)<\/w:pPr>');
      final matches = pPrRegex.allMatches(documentXml);
      expect(matches, isNotEmpty);

      for (final match in matches) {
        final pPrContent = match.group(1)!;

        final tabsPos = pPrContent.indexOf('<w:tabs');
        final bidiPos = pPrContent.indexOf('<w:bidi');
        final spacingPos = pPrContent.indexOf('<w:spacing');
        final indPos = pPrContent.indexOf('<w:ind');
        final jcPos = pPrContent.indexOf('<w:jc');

        // tabs must come before bidi, spacing, ind, jc
        if (tabsPos != -1) {
          if (bidiPos != -1) expect(tabsPos, lessThan(bidiPos), reason: 'tabs must precede bidi in: $pPrContent');
          if (spacingPos != -1) expect(tabsPos, lessThan(spacingPos), reason: 'tabs must precede spacing in: $pPrContent');
          if (indPos != -1) expect(tabsPos, lessThan(indPos), reason: 'tabs must precede ind in: $pPrContent');
          if (jcPos != -1) expect(tabsPos, lessThan(jcPos), reason: 'tabs must precede jc in: $pPrContent');
        }

        // bidi must come before spacing, ind, jc
        if (bidiPos != -1) {
          if (spacingPos != -1) expect(bidiPos, lessThan(spacingPos), reason: 'bidi must precede spacing in: $pPrContent');
          if (indPos != -1) expect(bidiPos, lessThan(indPos), reason: 'bidi must precede ind in: $pPrContent');
          if (jcPos != -1) expect(bidiPos, lessThan(jcPos), reason: 'bidi must precede jc in: $pPrContent');
        }

        // spacing must come before ind, jc
        if (spacingPos != -1) {
          if (indPos != -1) expect(spacingPos, lessThan(indPos), reason: 'spacing must precede ind in: $pPrContent');
          if (jcPos != -1) expect(spacingPos, lessThan(jcPos), reason: 'spacing must precede jc in: $pPrContent');
        }

        // ind must come before jc
        if (indPos != -1 && jcPos != -1) {
          expect(indPos, lessThan(jcPos), reason: 'ind must precede jc in: $pPrContent');
        }
      }
    });

    test('Header table paragraphs emit w:bidi for Arabic header text and no w:bidi for English header text', () async {
      final arabicExam = ExamEntity(
        id: 4,
        teacherId: 1,
        title: 'اختبار العلوم',
        status: 'completed',
        totalPoints: 5,
        createdAt: '2026-08-25',
        updatedAt: '2026-08-25',
        questions: [],
      );

      final Uint8List arBytes = await ExamWordService.generateWordBytes(
        exam: arabicExam,
        showAnswers: false,
        teacherName: 'أحمد علي',
        schoolName: 'مدرسة المواهب',
        educationOffice: 'إدارة التعليم بالرياض',
      );

      final arArchive = ZipDecoder().decodeBytes(arBytes);
      final arDocXml = utf8.decode(arArchive.findFile('word/document.xml')!.content as List<int>);

      // Arabic header paragraphs must have <w:bidi w:val="1"/> and <w:jc w:val="left"/> (compensating for bidi flip)
      expect(arDocXml, matches(RegExp(r'<w:pPr>[\s\S]*?<w:bidi w:val="1"\/>[\s\S]*?<w:spacing w:after="40"\/>[\s\S]*?<w:jc w:val="left"\/>[\s\S]*?<\/w:pPr>')));
      expect(arDocXml, matches(RegExp(r'<w:pPr>[\s\S]*?<w:bidi w:val="1"\/>[\s\S]*?<w:spacing w:after="160"\/>[\s\S]*?<w:jc w:val="left"\/>[\s\S]*?<\/w:pPr>')));
      expect(arDocXml, contains('إدارة التعليم بالرياض'));
      expect(arDocXml, contains('مدرسة المواهب'));

      final englishExam = ExamEntity(
        id: 5,
        teacherId: 1,
        title: 'Science Exam',
        status: 'completed',
        totalPoints: 5,
        createdAt: '2026-08-25',
        updatedAt: '2026-08-25',
        questions: [],
      );

      final Uint8List enBytes = await ExamWordService.generateWordBytes(
        exam: englishExam,
        showAnswers: false,
        teacherName: 'John Doe',
        schoolName: 'Moean School',
        educationOffice: 'Department of Education',
      );

      final enArchive = ZipDecoder().decodeBytes(enBytes);
      final enDocXml = utf8.decode(enArchive.findFile('word/document.xml')!.content as List<int>);

      // English header paragraphs must NOT have <w:bidi w:val="1"/> and must be left-aligned
      expect(enDocXml, matches(RegExp(r'<w:pPr>[\s\S]*?<w:spacing w:after="40"\/>[\s\S]*?<w:jc w:val="left"\/>[\s\S]*?<\/w:pPr>')));
      expect(enDocXml, matches(RegExp(r'<w:pPr>[\s\S]*?<w:spacing w:after="160"\/>[\s\S]*?<w:jc w:val="left"\/>[\s\S]*?<\/w:pPr>')));
      expect(enDocXml, contains('Department of Education'));
      expect(enDocXml, contains('Moean School'));
    });

    test('generate sample Arabic and English .docx files to disk for verification', () async {
      final arabicExam = ExamEntity(
        id: 101,
        teacherId: 1,
        title: 'اختبار العلوم النهائي - الصف الخامس',
        status: 'completed',
        totalPoints: 10,
        createdAt: '2026-08-25',
        updatedAt: '2026-08-25',
        questions: [
          QuestionEntity(
            id: 1,
            lessonId: 1,
            questionOrder: 1,
            questionText: 'ما هو الكوكب الأقرب إلى الشمس؟',
            type: 'mcq',
            options: ['عطارد', 'الزهرة', 'الأرض', 'المريخ'],
            correctAnswer: 'عطارد',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 2,
            lessonId: 1,
            questionOrder: 2,
            questionText: 'الشمس نجم وليست كوكباً.',
            type: 'true_false',
            options: null,
            correctAnswer: 'صح',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 3,
            lessonId: 1,
            questionOrder: 3,
            questionText: 'صل الكلمة بما يناسبها:',
            type: 'matching',
            options: {
              'column_a': ['الأكسجين', 'الجاذبية'],
              'column_b': ['غاز ضروري للتنفس', 'قوة تجذب الأجسام نحو الأرض'],
            },
            correctAnswer: '',
            points: 4,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 4,
            lessonId: 1,
            questionOrder: 4,
            questionText: 'اشرح دورة الماء في الطبيعة باختصار:',
            type: 'essay',
            options: null,
            correctAnswer: '',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
        ],
      );

      final englishExam = ExamEntity(
        id: 102,
        teacherId: 1,
        title: 'Science Final Examination - Grade 5',
        status: 'completed',
        totalPoints: 10,
        createdAt: '2026-08-25',
        updatedAt: '2026-08-25',
        questions: [
          QuestionEntity(
            id: 1,
            lessonId: 1,
            questionOrder: 1,
            questionText: 'Which planet is closest to the Sun?',
            type: 'mcq',
            options: ['Mercury', 'Venus', 'Earth', 'Mars'],
            correctAnswer: 'Mercury',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 2,
            lessonId: 1,
            questionOrder: 2,
            questionText: 'The Sun is a star, not a planet.',
            type: 'true_false',
            options: null,
            correctAnswer: 'True',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 3,
            lessonId: 1,
            questionOrder: 3,
            questionText: 'Match each term with its definition:',
            type: 'matching',
            options: {
              'column_a': ['Oxygen', 'Gravity'],
              'column_b': ['Gas necessary for respiration', 'Force pulling objects towards Earth'],
            },
            correctAnswer: '',
            points: 4,
            source: 'ai',
            usageCount: 0,
          ),
          QuestionEntity(
            id: 4,
            lessonId: 1,
            questionOrder: 4,
            questionText: 'Briefly explain the water cycle in nature:',
            type: 'essay',
            options: null,
            correctAnswer: '',
            points: 2,
            source: 'ai',
            usageCount: 0,
          ),
        ],
      );

      final arBytes = await ExamWordService.generateWordBytes(
        exam: arabicExam,
        showAnswers: true,
        teacherName: 'أ. محمد الحربي',
        schoolName: 'مدرسة الفيصلية الابتدائية',
        educationOffice: 'الإدارة العامة للتعليم بمنطقة الرياض',
      );

      final enBytes = await ExamWordService.generateWordBytes(
        exam: englishExam,
        showAnswers: true,
        teacherName: 'Mr. John Smith',
        schoolName: 'International Academic School',
        educationOffice: 'Department of Education',
      );

      // Write sample docx files to build/test outputs
      final scratchDir = Directory('D:/flutter projects/moean/moean/build/test_outputs');
      if (!scratchDir.existsSync()) {
        scratchDir.createSync(recursive: true);
      }

      final arFile = File('${scratchDir.path}/sample_arabic_exam.docx');
      await arFile.writeAsBytes(arBytes);

      final enFile = File('${scratchDir.path}/sample_english_exam.docx');
      await enFile.writeAsBytes(enBytes);

      expect(arFile.existsSync(), isTrue);
      expect(enFile.existsSync(), isTrue);
      expect(arFile.lengthSync(), greaterThan(1000));
      expect(enFile.lengthSync(), greaterThan(1000));
    });
  });
}
