import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_documents_cubit.dart';

class MockRoleSuitesRepository extends Mock implements RoleSuitesRepository {}

const _detail = RoleSuiteDetailModel(
  key: 'activity_leader',
  label: 'رائد النشاط',
  categories: [
    RoleCategoryModel(
      key: 'plans',
      label: 'الخطط',
      documents: [
        RoleDocumentSummary(key: 'weekly_plan', label: 'الخطة الأسبوعية للنشاط', ai: true),
      ],
    ),
    RoleCategoryModel(
      key: 'forms',
      label: 'النماذج والسجلات',
      documents: [
        RoleDocumentSummary(key: 'club_members', label: 'كشف أعضاء النادي', ai: false),
        RoleDocumentSummary(key: 'parent_consent', label: 'موافقة ولي الأمر', sensitive: true),
      ],
    ),
  ],
);

void main() {
  late MockRoleSuitesRepository repo;

  setUp(() {
    repo = MockRoleSuitesRepository();
    when(() => repo.getRole('activity_leader')).thenAnswer((_) async => const Right(_detail));
  });

  test('loads categories, filters by category tab and search query', () async {
    final cubit = RoleDocumentsCubit(roleKey: 'activity_leader', repository: repo);
    await cubit.load();

    expect(cubit.state.status, RoleDocumentsStatus.success);
    expect(cubit.state.roleLabel, 'رائد النشاط');
    expect(cubit.state.visibleCategories, hasLength(2));

    cubit.selectCategory(1);
    expect(cubit.state.visibleCategories.single.key, 'forms');

    cubit.selectCategory(null);
    cubit.onSearchChanged('موافقة');
    expect(cubit.state.visibleCategories, hasLength(1));
    expect(cubit.state.visibleCategories.single.documents.single.key, 'parent_consent');

    cubit.onSearchChanged('لا يوجد');
    expect(cubit.state.visibleCategories, isEmpty);
    await cubit.close();
  });

  test('openDocument emits openedTemplate on success and feedback on failure', () async {
    const template = RoleDocumentTemplateModel(
      role: 'activity_leader',
      doc: 'weekly_plan',
      type: 'report',
      label: 'الخطة الأسبوعية للنشاط',
      ai: true,
      term: 'first',
      region: 'makkah',
      input: {'title': 'الخطة الأسبوعية'},
    );
    when(() => repo.getDocument('activity_leader', 'weekly_plan'))
        .thenAnswer((_) async => const Right(template));
    when(() => repo.getDocument('activity_leader', 'broken'))
        .thenAnswer((_) async => const Left(ServerFailure('network_error')));

    final cubit = RoleDocumentsCubit(roleKey: 'activity_leader', repository: repo);
    await cubit.load();

    await cubit.openDocument('weekly_plan');
    expect(cubit.state.openedTemplate?.doc, 'weekly_plan');
    expect(cubit.state.openedTemplate?.term, 'first');
    expect(cubit.state.isOpening, isFalse);

    await cubit.openDocument('broken');
    expect(cubit.state.openedTemplate, isNull);
    expect(cubit.state.feedback?.message, 'network_error');
    await cubit.close();
  });
}
