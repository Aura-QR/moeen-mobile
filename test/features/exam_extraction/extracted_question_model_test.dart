import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';

void main() {
  group('ExtractedQuestionModel', () {
    test('fromJson handles MCQ with list options', () {
      final json = {
        'type': 'mcq',
        'question_text': 'ما عاصمة المملكة؟',
        'options': ['الرياض', 'جدة', 'الدمام'],
        'correct_answer': 'الرياض',
        'difficulty': 'easy',
        'needs_answer': false,
        'suggested': true,
        'points': 2.0,
      };

      final model = ExtractedQuestionModel.fromJson(json);

      expect(model.type, QuestionType.mcq);
      expect(model.questionText, 'ما عاصمة المملكة؟');
      expect(model.options, ['الرياض', 'جدة', 'الدمام']);
      expect(model.correctAnswer, 'الرياض');
      expect(model.difficulty, 'easy');
      expect(model.needsAnswer, isFalse);
      expect(model.suggested, isTrue);
      expect(model.points, 2.0);
      expect(model.isValid, isTrue);
      expect(model.mcqAnswerMismatch, isFalse);
    });

    test('fromJson handles True/False with empty options', () {
      final json = {
        'type': 'true_false',
        'question_text': 'الشمس كوكب',
        'options': [],
        'correct_answer': 'خطأ',
        'difficulty': 'easy',
        'needs_answer': false,
      };

      final model = ExtractedQuestionModel.fromJson(json);

      expect(model.type, QuestionType.trueFalse);
      expect(model.correctAnswer, 'خطأ');
      expect(model.options, isEmpty);
      expect(model.isValid, isTrue);
    });

    test('fromJson handles Matching with map options (column_a, column_b)', () {
      final json = {
        'type': 'matching',
        'question_text': 'صل الكلمة بمعناها',
        'options': {
          'column_a': ['الجذر', 'الساق'],
          'column_b': ['امتصاص الماء', 'نقل الغذاء'],
        },
        'correct_answer': '1-أ، 2-ب',
        'difficulty': 'medium',
        'needs_answer': false,
      };

      final model = ExtractedQuestionModel.fromJson(json);

      expect(model.type, QuestionType.matching);
      expect(model.columnA, ['الجذر', 'الساق']);
      expect(model.columnB, ['امتصاص الماء', 'نقل الغذاء']);
      expect(model.correctAnswer, '1-أ، 2-ب');
      expect(model.isValid, isTrue);
    });

    test('fromJson parses defensively when options have wrong shape', () {
      final json = {
        'type': 'fill_blank',
        'question_text': 'تنقل ... الماء',
        'options': 'invalid_string',
        'correct_answer': 'الساق',
      };

      final model = ExtractedQuestionModel.fromJson(json);

      expect(model.type, QuestionType.fillBlank);
      expect(model.options, isEmpty);
      expect(model.columnA, isEmpty);
      expect(model.columnB, isEmpty);
      expect(model.isValid, isTrue);
    });

    test('mcqAnswerMismatch is true when answer is not in options', () {
      const model = ExtractedQuestionModel(
        type: QuestionType.mcq,
        questionText: 'سؤال',
        options: ['أ', 'ب'],
        correctAnswer: 'ج',
      );

      expect(model.mcqAnswerMismatch, isTrue);
      expect(model.isValid, isFalse);
      expect(model.isHighlighted, isTrue);
    });

    test('isHighlighted is true when needsAnswer is true and correctAnswer is empty', () {
      const model = ExtractedQuestionModel(
        type: QuestionType.fillBlank,
        questionText: 'سؤال',
        correctAnswer: '',
        needsAnswer: true,
      );

      expect(model.hasAnswer, isFalse);
      expect(model.isHighlighted, isTrue);
      expect(model.isValid, isFalse);
    });

    test('toSaveJson outputs expected format for MCQ', () {
      const model = ExtractedQuestionModel(
        type: QuestionType.mcq,
        questionText: 'سؤال',
        options: ['1', '2'],
        correctAnswer: '1',
        difficulty: 'easy',
        points: 2.0,
      );

      final saveJson = model.toSaveJson();

      expect(saveJson['type'], 'mcq');
      expect(saveJson['question_text'], 'سؤال');
      expect(saveJson['options'], ['1', '2']);
      expect(saveJson['correct_answer'], '1');
      expect(saveJson['difficulty'], 'easy');
      expect(saveJson['points'], 2.0);
    });

    test('toSaveJson outputs map for Matching', () {
      const model = ExtractedQuestionModel(
        type: QuestionType.matching,
        questionText: 'صل',
        columnA: ['أ'],
        columnB: ['ب'],
        correctAnswer: '1-أ',
      );

      final saveJson = model.toSaveJson();

      expect(saveJson['options'], {
        'column_a': ['أ'],
        'column_b': ['ب'],
      });
    });
  });
}
