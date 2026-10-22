import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _portfolioId = 7;

PortfolioModel _portfolio({bool isPublic = false}) => PortfolioModel.fromJson({
      'id': _portfolioId,
      'title': 'ملف الإنجاز 1448',
      'role': 'teacher',
      'role_label': 'معلم',
      'is_public': isPublic,
      'share_url': isPublic ? 'https://haderedu.com/portfolio/abc' : null,
      'completion': {'included': 1, 'complete': 1, 'percent': 100, 'missing': []},
      'profile': {'name': 'أ. سارة'},
      'items': [
        {
          'id': 31,
          'item_key': 'duties',
          'title': 'أداء الواجبات الوظيفية',
          'included': true,
          'sort_order': 1,
          'files': [
            {'id': 90, 'kind': 'file', 'mime': 'image/png', 'url': 'https://r2/a.png', 'sort_order': 1},
            {'id': 91, 'kind': 'link', 'url': 'https://youtu.be/x', 'sort_order': 2},
            {'id': 92, 'kind': 'file', 'mime': 'application/pdf', 'url': 'https://r2/b.pdf', 'sort_order': 3},
          ],
        },
      ],
    });

void main() {
  late MockPortfolioRepository repo;
  late MockDeviceFilePicker picker;
  late PortfolioEditorCubit cubit;
  Map<int, Uint8List>? builtWithImages;

  setUpAll(() {
    registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: 'x', mime: null));
  });

  setUp(() {
    repo = MockPortfolioRepository();
    picker = MockDeviceFilePicker();
    builtWithImages = null;
    cubit = PortfolioEditorCubit(
      portfolioId: _portfolioId,
      repository: repo,
      filePicker: picker,
      pdfBuilder: (_, images) async {
        builtWithImages = images;
        return Uint8List.fromList([1]);
      },
    );
    when(() => repo.getPortfolio(_portfolioId)).thenAnswer((_) async => Right(_portfolio()));
    when(() => repo.getRoles()).thenAnswer((_) async => const Right(PortfolioRolesModel(roles: [])));
  });

  tearDown(() => cubit.close());

  test('load fetches the portfolio and the roles', () async {
    await cubit.load();

    expect(cubit.state.status, PortfolioEditorStatus.success);
    expect(cubit.state.portfolio!.items.single.files.length, 3);
    expect(cubit.state.roles, isNotNull);
  });

  test('load failure with nothing shown switches to the error state', () async {
    when(() => repo.getPortfolio(_portfolioId)).thenAnswer((_) async => const Left(NotFoundFailure('portfolio_not_found')));
    await cubit.load();

    expect(cubit.state.status, PortfolioEditorStatus.failure);
    expect(cubit.state.errorMessage, 'portfolio_not_found');
  });

  test('setIncluded flips the checkbox before the request returns', () async {
    await cubit.load();
    final item = cubit.state.portfolio!.items.single;
    when(() => repo.updateItem(_portfolioId, 31, included: false)).thenAnswer((_) async => const Right(unit));

    final pending = cubit.setIncluded(item, false);
    expect(cubit.state.portfolio!.items.single.included, isFalse);
    await pending;
    verify(() => repo.updateItem(_portfolioId, 31, included: false)).called(1);
  });

  test('reorderFiles sends every id in the new order', () async {
    await cubit.load();
    when(() => repo.reorderFiles(_portfolioId, 31, [92, 90, 91])).thenAnswer((_) async => const Right(unit));

    await cubit.reorderFiles(cubit.state.portfolio!.items.single, 2, 0);
    verify(() => repo.reorderFiles(_portfolioId, 31, [92, 90, 91])).called(1);
  });

  group('pickAndUpload', () {
    setUp(() async => cubit.load());

    test('does nothing when the teacher cancels', () async {
      when(() => picker.pick(DeviceFileSource.gallery)).thenAnswer((_) async => null);
      await cubit.pickAndUpload(31, DeviceFileSource.gallery);

      verifyNever(() => repo.uploadFile(
            portfolioId: any(named: 'portfolioId'),
            itemId: any(named: 'itemId'),
            file: any(named: 'file'),
            onProgress: any(named: 'onProgress'),
          ));
    });

    test('rejects an unsupported type before uploading', () async {
      when(() => picker.pick(DeviceFileSource.gallery))
          .thenAnswer((_) async => DevicePickedFile(bytes: Uint8List(10), name: 'a.heic', mime: null));
      final feedback = cubit.stream.firstWhere((s) => s.feedback != null);
      await cubit.pickAndUpload(31, DeviceFileSource.gallery);

      expect((await feedback).feedback!.message, 'portfolio_unsupported_file');
    });

    test('rejects a file over 10 MB before uploading', () async {
      when(() => picker.pick(DeviceFileSource.pdf)).thenAnswer((_) async =>
          DevicePickedFile(bytes: Uint8List(10 * 1024 * 1024 + 1), name: 'big.pdf', mime: 'application/pdf'));
      final feedback = cubit.stream.firstWhere((s) => s.feedback != null);
      await cubit.pickAndUpload(31, DeviceFileSource.pdf);

      expect((await feedback).feedback!.message, 'portfolio_file_too_large');
    });

    test('uploads with progress, then reloads the portfolio', () async {
      final file = DevicePickedFile(bytes: Uint8List(100), name: 'plan.png', mime: 'image/png');
      when(() => picker.pick(DeviceFileSource.camera)).thenAnswer((_) async => file);
      when(() => repo.uploadFile(
            portfolioId: _portfolioId,
            itemId: 31,
            file: file,
            onProgress: any(named: 'onProgress'),
          )).thenAnswer((invocation) async {
        (invocation.namedArguments[#onProgress] as void Function(double))(0.5);
        return const Right(unit);
      });
      final progress = cubit.stream.firstWhere((s) => s.uploadProgress == 0.5);

      await cubit.pickAndUpload(31, DeviceFileSource.camera);

      expect((await progress).uploadingItemId, 31);
      expect(cubit.state.uploadingItemId, isNull);
      verify(() => repo.getPortfolio(_portfolioId)).called(2);
    });
  });

  test('addLink refuses links that are not https', () async {
    await cubit.load();
    final feedback = cubit.stream.firstWhere((s) => s.feedback != null);
    await cubit.addLink(31, 'http://example.com', '');

    expect((await feedback).feedback!.message, 'portfolio_link_https_only');
    verifyNever(() => repo.addLink(
          portfolioId: any(named: 'portfolioId'),
          itemId: any(named: 'itemId'),
          url: any(named: 'url'),
          title: any(named: 'title'),
        ));
  });

  test('enableShare then disableShare toggles the link', () async {
    await cubit.load();
    when(() => repo.enableShare(_portfolioId)).thenAnswer((_) async => const Right('https://haderedu.com/portfolio/abc'));
    when(() => repo.disableShare(_portfolioId)).thenAnswer((_) async => const Right(unit));

    await cubit.enableShare();
    expect(cubit.state.portfolio!.isPublic, isTrue);
    expect(cubit.state.portfolio!.shareUrl, 'https://haderedu.com/portfolio/abc');

    await cubit.disableShare();
    expect(cubit.state.portfolio!.isPublic, isFalse);
    expect(cubit.state.portfolio!.shareUrl, isNull);
  });

  test('deleteItem skips standard items', () async {
    await cubit.load();
    await cubit.deleteItem(cubit.state.portfolio!.items.single);
    verifyNever(() => repo.deleteItem(any(), any()));
  });

  test('exportPdf refetches and downloads only the images', () async {
    await cubit.load();
    when(() => repo.downloadBytes('https://r2/a.png')).thenAnswer((_) async => Right(Uint8List.fromList([9])));

    await cubit.exportPdf();

    verify(() => repo.getPortfolio(_portfolioId)).called(2);
    verify(() => repo.downloadBytes('https://r2/a.png')).called(1);
    expect(builtWithImages!.keys, [90]);
    expect(cubit.state.isExporting, isFalse);
  });
}
