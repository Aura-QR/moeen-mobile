import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_cubit.dart';
import 'package:moean/features/verify_email/presentation/cubit/verify_email_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VerifyEmailCubit', () {
    late VerifyEmailCubit cubit;

    setUp(() {
      cubit = VerifyEmailCubit(email: 'test@example.com');
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be VerifyEmailInitialState', () {
      expect(cubit.state, isA<VerifyEmailInitialState>());
      expect(cubit.email, 'test@example.com');
      expect(cubit.cooldownSeconds, 0);
      expect(cubit.isResending, isFalse);
    });

    test('startCooldown should emit VerifyEmailCooldownTickState', () async {
      cubit.startCooldown(5);
      expect(cubit.cooldownSeconds, 5);
      expect(cubit.state, isA<VerifyEmailCooldownTickState>());
      final tickState = cubit.state as VerifyEmailCooldownTickState;
      expect(tickState.cooldownSeconds, 5);
    });

    test('close should dispose properly without throwing', () async {
      await cubit.close();
      expect(cubit.isClosed, isTrue);
    });
  });
}
