import 'dart:convert';
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

      // 7. Verify both w:bidi (for Arabic) and no w:bidi (for English) are present in paragraphs
      expect(documentXml, contains('<w:bidi w:val="1"/>'));
      expect(documentXml, contains('<w:jc w:val="left"/>'));
      expect(documentXml, contains('<w:jc w:val="right"/>'));
    });
  });
}
