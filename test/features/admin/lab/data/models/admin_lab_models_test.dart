import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';

void main() {
  group('AdminLabExperimentModel', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 10,
        'key': 'c_test123',
        'name': 'تجربة الضغط',
        'status': 'published',
        'source': 'community',
        'approved': true,
        'approved_at': '2026-11-01',
        'featured': true,
        'open_reports_count': 3,
        'author_name': 'الأستاذ خالد',
        'plays': 150,
        'lessons_count': 4,
        'area': 'فيزياء',
        'approximate': true,
      };

      final model = AdminLabExperimentModel.fromJson(json);

      expect(model.id, 10);
      expect(model.key, 'c_test123');
      expect(model.name, 'تجربة الضغط');
      expect(model.isPublished, isTrue);
      expect(model.isCommunity, isTrue);
      expect(model.approved, isTrue);
      expect(model.featured, isTrue);
      expect(model.openReportsCount, 3);
      expect(model.authorName, 'الأستاذ خالد');
      expect(model.plays, 150);
      expect(model.lessonsCount, 4);
    });

    test('copyWith updates properties properly', () {
      const model = AdminLabExperimentModel(
        key: 'c_test',
        name: 'تجربة',
        status: 'hidden',
        approved: false,
      );

      final updated = model.copyWith(
        status: 'published',
        approved: true,
        featured: true,
        openReportsCount: 1,
      );

      expect(updated.isPublished, isTrue);
      expect(updated.approved, isTrue);
      expect(updated.featured, isTrue);
      expect(updated.openReportsCount, 1);
    });
  });

  group('AdminLabMistakeReportModel', () {
    test('parses nested experiment and user JSON', () {
      final json = {
        'id': 5,
        'message': 'قيمة الجهد غير دقيقة في المنحنى',
        'status': 'open',
        'experiment': {
          'key': 'ohm',
          'name': 'قانون أوم',
        },
        'user': {
          'name': 'المعلم محمد',
          'email': 'mohamed@test.com',
        },
        'created_at': '2026-11-02 10:00:00',
      };

      final model = AdminLabMistakeReportModel.fromJson(json);

      expect(model.id, 5);
      expect(model.message, 'قيمة الجهد غير دقيقة في المنحنى');
      expect(model.isOpen, isTrue);
      expect(model.experimentKey, 'ohm');
      expect(model.experimentName, 'قانون أوم');
      expect(model.teacherName, 'المعلم محمد');
      expect(model.teacherEmail, 'mohamed@test.com');
    });

    test('copyWith updates status', () {
      const model = AdminLabMistakeReportModel(
        id: 1,
        message: 'خطأ',
        status: 'open',
      );

      final updated = model.copyWith(status: 'done');

      expect(updated.isOpen, isFalse);
      expect(updated.status, 'done');
    });
  });

  group('AdminLabRequestModel', () {
    test('parses nested lesson and user JSON', () {
      final json = {
        'id': 8,
        'message': 'نرجو إضافة تجربة للانعكاس الكلي',
        'status': 'open',
        'lesson': {
          'id': 120,
          'title': 'الانعكاس والانكسار',
        },
        'user': {
          'name': 'المعلمة نورة',
          'email': 'noura@test.com',
        },
        'created_at': '2026-11-03 08:30:00',
      };

      final model = AdminLabRequestModel.fromJson(json);

      expect(model.id, 8);
      expect(model.message, 'نرجو إضافة تجربة للانعكاس الكلي');
      expect(model.isOpen, isTrue);
      expect(model.lessonId, 120);
      expect(model.lessonTitle, 'الانعكاس والانكسار');
      expect(model.teacherName, 'المعلمة نورة');
      expect(model.teacherEmail, 'noura@test.com');
    });

    test('copyWith updates status', () {
      const model = AdminLabRequestModel(
        id: 2,
        message: 'طلب',
        status: 'open',
      );

      final updated = model.copyWith(status: 'done');

      expect(updated.isOpen, isFalse);
      expect(updated.status, 'done');
    });
  });
}
