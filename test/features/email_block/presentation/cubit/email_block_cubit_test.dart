import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/email_block/presentation/cubit/email_block_cubit.dart';
import 'package:moean/features/email_block/presentation/cubit/email_block_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmailBlockCubit', () {
    late EmailBlockCubit cubit;

    setUp(() {
      cubit = EmailBlockCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is EmailBlockInitial', () {
      expect(cubit.state, isA<EmailBlockInitial>());
    });

    test('close disposes without throwing', () async {
      await cubit.close();
      expect(cubit.isClosed, isTrue);
    });
  });
}
