import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/update/checkout_mode.dart';
import 'package:moean/features/payment/data/models/subscription_current_model.dart';
import 'package:moean/features/payment/data/repositories/web_checkout_repository.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_state.dart';

/// Opens a URL outside the app; true when it opened.
typedef ExternalUrlOpener = Future<bool> Function(Uri uri);

/// The app takes no payments itself. A subscribe tap opens the website's
/// checkout in the phone's browser, already signed in, and the subscription is
/// checked again when the teacher comes back.
class WebCheckoutCubit extends Cubit<WebCheckoutState> {
  WebCheckoutCubit({
    required WebCheckoutRepository repository,
    required ExternalUrlOpener openUrl,
    required Future<void> Function() refreshAccount,
    required SubscriptionCurrentModel? Function() readSubscription,
  })  : _repository = repository,
        _openUrl = openUrl,
        _refreshAccount = refreshAccount,
        _readSubscription = readSubscription,
        // Paying stays hidden until the server says otherwise.
        super(const WebCheckoutIdle(CheckoutMode.off));

  static WebCheckoutCubit get(BuildContext context) => BlocProvider.of(context);

  final WebCheckoutRepository _repository;
  final ExternalUrlOpener _openUrl;
  final Future<void> Function() _refreshAccount;
  final SubscriptionCurrentModel? Function() _readSubscription;

  /// Set once the browser opens and kept until the subscription turns active,
  /// so a teacher who glances back at the app mid-payment is still caught
  /// when they return after paying.
  bool _awaitingReturn = false;
  bool _wasActive = false;
  DateTime? _endsAtBefore;

  void setMode(CheckoutMode mode) {
    if (mode == state.mode) return;
    if (mode == CheckoutMode.off) _awaitingReturn = false;
    if (!isClosed) emit(WebCheckoutIdle(mode));
  }

  /// [serviceId] is the chosen plan, or null to choose it on the website.
  Future<void> openCheckout({int? serviceId}) async {
    final mode = state.mode;
    if (mode != CheckoutMode.web || state is WebCheckoutOpening) return;

    final before = _readSubscription();
    _wasActive = _isActive(before);
    _endsAtBefore = before?.subscriptionEndsAt;

    emit(WebCheckoutOpening(mode));
    // A fresh link on every tap: each one works once, for two minutes.
    final result = await _repository.createHandoffUrl(serviceId: serviceId);
    if (isClosed) return;

    final url = result.fold((failure) {
      emit(WebCheckoutFailed(mode, failure.message));
      return null;
    }, (url) => url);
    if (url == null) return;

    final uri = Uri.tryParse(url);
    final opened = uri != null && await _tryOpen(uri);
    if (isClosed) return;
    if (!opened) {
      emit(WebCheckoutFailed(mode, 'web_checkout_open_failed'));
      return;
    }
    _awaitingReturn = true;
    emit(WebCheckoutLaunched(mode));
  }

  /// Called when the app returns from the background.
  Future<void> onAppResumed() async {
    if (!_awaitingReturn) return;
    await _refreshAccount();
    if (isClosed) return;

    final now = _readSubscription();
    final renewed = now?.subscriptionEndsAt != _endsAtBefore;
    if (_isActive(now) && (!_wasActive || renewed)) {
      _awaitingReturn = false;
      emit(WebCheckoutActivated(state.mode));
    }
  }

  Future<bool> _tryOpen(Uri uri) async {
    try {
      return await _openUrl(uri);
    } catch (_) {
      return false;
    }
  }

  static bool _isActive(SubscriptionCurrentModel? subscription) =>
      subscription != null &&
      subscription.isSubscribed &&
      !subscription.isSubscriptionExpired;
}
