import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_cubit.dart';

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

void main() {
  late MockDeviceFilePicker mockFilePicker;
  late LinkQrCubit cubit;

  setUp(() {
    mockFilePicker = MockDeviceFilePicker();
    cubit = LinkQrCubit(filePicker: mockFilePicker);
  });

  tearDown(() {
    cubit.close();
  });

  group('LinkQrCubit', () {
    test('initial state has empty URL and isValid false', () {
      expect(cubit.state.url, isEmpty);
      expect(cubit.state.isValid, isFalse);
    });

    test('validates and prepends https:// to valid host', () async {
      cubit.setUrl('haderedu.com/path');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(cubit.state.isValid, isTrue);
      expect(cubit.state.url, 'https://haderedu.com/path');
    });

    test('marks invalid URL as not valid', () async {
      cubit.setUrl('not_a_valid_url');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(cubit.state.isValid, isFalse);
    });

    test('setCaption trims to 60 characters', () {
      final longCaption = 'A' * 80;
      cubit.setCaption(longCaption);

      expect(cubit.state.caption.length, 60);
    });

    test('removeLogo clears logo and logoBytes', () {
      cubit.removeLogo();
      expect(cubit.state.logo, isNull);
      expect(cubit.state.logoBytes, isNull);
    });
  });
}
