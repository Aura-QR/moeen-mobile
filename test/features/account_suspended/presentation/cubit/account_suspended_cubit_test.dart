import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountSuspendedCubit', () {
    late AccountSuspendedCubit cubit;

    setUp(() {
      cubit = AccountSuspendedCubit();
    });

    tearDown(() {
      if (!cubit.isClosed) {
        cubit.close();
      }
    });

    test('initial state should be AccountSuspendedInitialState', () {
      expect(cubit.state, isA<AccountSuspendedInitialState>());
      expect(cubit.selectedType, 'technical_support');
      expect(cubit.contactTypes.isNotEmpty, isTrue);
    });

    test('selectType should update selectedType and emit AccountSuspendedTypeSelectedState', () {
      cubit.selectType('billing');
      expect(cubit.selectedType, 'billing');
      expect(cubit.state, isA<AccountSuspendedTypeSelectedState>());
      final state = cubit.state as AccountSuspendedTypeSelectedState;
      expect(state.selectedType, 'billing');
    });

    test('close should dispose controllers properly', () async {
      await cubit.close();
      expect(cubit.isClosed, isTrue);
    });
  });
}
