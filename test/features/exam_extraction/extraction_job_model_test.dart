import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_job_model.dart';

void main() {
  group('ExtractionJobModel', () {
    test('fromJson parses pending job', () {
      final json = {
        'data': {
          'id': 123,
          'status': 'pending',
        }
      };

      final job = ExtractionJobModel.fromJson(json);

      expect(job.id, 123);
      expect(job.status, 'pending');
      expect(job.isPending, isTrue);
      expect(job.isDone, isFalse);
      expect(job.isFailed, isFalse);
      expect(job.questions, isEmpty);
    });

    test('fromJson parses done job with result and questions', () {
      final json = {
        'id': 456,
        'status': 'done',
        'result': {
          'source': 'questions',
          'questions': [
            {
              'type': 'mcq',
              'question_text': 'ما وظيفة الساق؟',
              'options': ['نقل الماء', 'التنفس'],
              'correct_answer': 'نقل الماء',
            }
          ]
        }
      };

      final job = ExtractionJobModel.fromJson(json);

      expect(job.id, 456);
      expect(job.status, 'done');
      expect(job.isDone, isTrue);
      expect(job.source, 'questions');
      expect(job.questions.length, 1);
      expect(job.questions.first.questionText, 'ما وظيفة الساق؟');
    });

    test('fromJson parses failed job with error', () {
      final json = {
        'id': 789,
        'status': 'failed',
        'error': 'تعذر استخراج الأسئلة من الصورة',
      };

      final job = ExtractionJobModel.fromJson(json);

      expect(job.id, 789);
      expect(job.status, 'failed');
      expect(job.isFailed, isTrue);
      expect(job.error, 'تعذر استخراج الأسئلة من الصورة');
    });
  });
}
