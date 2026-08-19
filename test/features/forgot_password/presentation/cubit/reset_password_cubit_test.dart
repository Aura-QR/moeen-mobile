import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_cubit.dart';
import 'package:moean/features/forgot_password/presentation/cubit/reset_password_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResetPasswordCubit', () {
    late ResetPasswordCubit cubit;

    setUp(() {
      cubit = ResetPasswordCubit(
        email: 'teacher@moe.edu.sa',
        token: 'sample-token-123',
      );
    });

    tearDown(() {
      if (!cubit.isClosed) {
        cubit.close();
      }
    });

    test('initial state should be ResetPasswordInitialState', () {
      expect(cubit.state, isA<ResetPasswordInitialState>());
      expect(cubit.email, 'teacher@moe.edu.sa');
      expect(cubit.token, 'sample-token-123');
      expect(cubit.obscurePassword, isTrue);
      expect(cubit.obscureConfirmPassword, isTrue);
      expect(cubit.isLoading, isFalse);
      expect(cubit.isSuccess, isFalse);
    });

    test('togglePasswordVisibility should flip obscurePassword and emit state', () {
      cubit.togglePasswordVisibility();
      expect(cubit.obscurePassword, isFalse);
      expect(cubit.state, isA<ResetPasswordObscureToggledState>());
      final state = cubit.state as ResetPasswordObscureToggledState;
      expect(state.obscurePassword, isFalse);
      expect(state.obscureConfirmPassword, isTrue);
    });

    test('toggleConfirmPasswordVisibility should flip obscureConfirmPassword and emit state', () {
      cubit.toggleConfirmPasswordVisibility();
      expect(cubit.obscureConfirmPassword, isFalse);
      expect(cubit.state, isA<ResetPasswordObscureToggledState>());
      final state = cubit.state as ResetPasswordObscureToggledState;
      expect(state.obscurePassword, isTrue);
      expect(state.obscureConfirmPassword, isFalse);
    });

    test('close should dispose properly without throwing', () async {
      await cubit.close();
      expect(cubit.isClosed, isTrue);
    });
  });
}
