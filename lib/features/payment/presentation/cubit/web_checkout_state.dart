import 'package:moean/core/update/checkout_mode.dart';

/// Every state carries [mode], so a widget can hide paying from any of them.
sealed class WebCheckoutState {
  const WebCheckoutState(this.mode);

  final CheckoutMode mode;

  bool get canPay => mode == CheckoutMode.web;
}

class WebCheckoutIdle extends WebCheckoutState {
  const WebCheckoutIdle(super.mode);
}

/// Asking the server for the sign-in link; the tapped button shows a loader.
class WebCheckoutOpening extends WebCheckoutState {
  const WebCheckoutOpening(super.mode);
}

/// The browser is open on the site's checkout.
class WebCheckoutLaunched extends WebCheckoutState {
  const WebCheckoutLaunched(super.mode);
}

/// [message] is the server's message or a translation key.
class WebCheckoutFailed extends WebCheckoutState {
  const WebCheckoutFailed(super.mode, this.message);

  final String message;
}

/// The teacher came back from the browser and the subscription is now active.
class WebCheckoutActivated extends WebCheckoutState {
  const WebCheckoutActivated(super.mode);
}
