import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/forgot_password_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForgotPasswordCubit', () {
    late ForgotPasswordCubit cubit;

    setUp(() {
      cubit = ForgotPasswordCubit();
    });

    tearDown(() {
      if (!cubit.isClosed) {
        cubit.close();
      }
    });

    test('initial state should be ForgotPasswordInitialState', () {
      expect(cubit.state, isA<ForgotPasswordInitialState>());
      expect(cubit.cooldownSeconds, 0);
      expect(cubit.isSent, isFalse);
      expect(cubit.isLoading, isFalse);
    });

    test('startCooldown should emit ForgotPasswordCooldownTickState', () async {
      cubit.startCooldown(5);
      expect(cubit.cooldownSeconds, 5);
      expect(cubit.state, isA<ForgotPasswordCooldownTickState>());
      final tickState = cubit.state as ForgotPasswordCooldownTickState;
      expect(tickState.cooldownSeconds, 5);
    });

    test('close should dispose properly without throwing', () async {
      await cubit.close();
      expect(cubit.isClosed, isTrue);
    });
  });
}
