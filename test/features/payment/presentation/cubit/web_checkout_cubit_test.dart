import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/update/checkout_mode.dart';
import 'package:moean/features/payment/data/models/subscription_current_model.dart';
import 'package:moean/features/payment/data/repositories/web_checkout_repository.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_state.dart';

class _MockRepository extends Mock implements WebCheckoutRepository {}

SubscriptionCurrentModel _subscription({
  required bool subscribed,
  DateTime? endsAt,
}) =>
    SubscriptionCurrentModel(
      isInTrial: !subscribed,
      isSubscribed: subscribed,
      subscriptionEndsAt: endsAt,
      trialDaysRemaining: 0,
      usage: SubscriptionUsageModel.fromJson(const {}),
    );

void main() {
  late _MockRepository repository;
  late List<Uri> opened;
  late bool openResult;
  late int refreshes;
  late SubscriptionCurrentModel? subscription;
  late WebCheckoutCubit cubit;

  const url = 'https://haderedu.com/auth/handoff?code=secret';

  setUp(() {
    repository = _MockRepository();
    opened = [];
    openResult = true;
    refreshes = 0;
    subscription = _subscription(subscribed: false);
    cubit = WebCheckoutCubit(
      repository: repository,
      openUrl: (uri) async {
        opened.add(uri);
        return openResult;
      },
      refreshAccount: () async => refreshes++,
      readSubscription: () => subscription,
    );
    when(() => repository.createHandoffUrl(serviceId: any(named: 'serviceId')))
        .thenAnswer((_) async => const Right(url));
  });

  tearDown(() => cubit.close());

  test('starts with paying off', () {
    expect(cubit.state.mode, CheckoutMode.off);
    expect(cubit.state.canPay, isFalse);
  });

  test('does nothing while paying is off', () async {
    await cubit.openCheckout();

    verifyNever(() => repository.createHandoffUrl(serviceId: any(named: 'serviceId')));
    expect(opened, isEmpty);
  });

  test('opens the link in the browser', () async {
    cubit.setMode(CheckoutMode.web);
    final states = <WebCheckoutState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.openCheckout();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    verify(() => repository.createHandoffUrl(serviceId: null)).called(1);
    expect(opened, [Uri.parse(url)]);
    expect(states.map((s) => s.runtimeType),
        [WebCheckoutOpening, WebCheckoutLaunched]);
  });

  test('asks for a fresh link on every tap', () async {
    cubit.setMode(CheckoutMode.web);

    await cubit.openCheckout();
    await cubit.openCheckout();

    verify(() => repository.createHandoffUrl(serviceId: null)).called(2);
    expect(opened, hasLength(2));
  });

  test('shows the server message when the link cannot be made', () async {
    when(() => repository.createHandoffUrl(serviceId: any(named: 'serviceId')))
        .thenAnswer((_) async => const Left(ServerFailure('الخدمة غير متاحة')));
    cubit.setMode(CheckoutMode.web);

    await cubit.openCheckout();

    expect((cubit.state as WebCheckoutFailed).message, 'الخدمة غير متاحة');
    expect(opened, isEmpty);
  });

  test('fails when the browser does not open', () async {
    openResult = false;
    cubit.setMode(CheckoutMode.web);

    await cubit.openCheckout();

    expect((cubit.state as WebCheckoutFailed).message, 'web_checkout_open_failed');
  });

  test('a resume without a tap does not refresh', () async {
    await cubit.onAppResumed();

    expect(refreshes, 0);
  });

  test('reports activation when the teacher comes back subscribed', () async {
    cubit.setMode(CheckoutMode.web);
    await cubit.openCheckout();

    subscription = _subscription(
      subscribed: true,
      endsAt: DateTime.now().add(const Duration(days: 30)),
    );
    await cubit.onAppResumed();

    expect(refreshes, 1);
    expect(cubit.state, isA<WebCheckoutActivated>());

    // Reported once: later resumes do not refresh again.
    await cubit.onAppResumed();
    expect(refreshes, 1);
  });

  test('keeps waiting when the teacher comes back without paying', () async {
    cubit.setMode(CheckoutMode.web);
    await cubit.openCheckout();

    await cubit.onAppResumed();
    expect(cubit.state, isA<WebCheckoutLaunched>());

    subscription = _subscription(
      subscribed: true,
      endsAt: DateTime.now().add(const Duration(days: 30)),
    );
    await cubit.onAppResumed();

    expect(refreshes, 2);
    expect(cubit.state, isA<WebCheckoutActivated>());
  });

  test('a renewal counts once the end date moves', () async {
    final endsAt = DateTime.now().add(const Duration(days: 3));
    subscription = _subscription(subscribed: true, endsAt: endsAt);
    cubit.setMode(CheckoutMode.web);
    await cubit.openCheckout();

    await cubit.onAppResumed();
    expect(cubit.state, isA<WebCheckoutLaunched>());

    subscription = _subscription(
      subscribed: true,
      endsAt: endsAt.add(const Duration(days: 120)),
    );
    await cubit.onAppResumed();
    expect(cubit.state, isA<WebCheckoutActivated>());
  });
}
