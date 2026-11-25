import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/update/checkout_mode.dart';

void main() {
  group('CheckoutMode.fromServer', () {
    test('"web" opens the website', () {
      expect(CheckoutMode.fromServer('web'), CheckoutMode.web);
    });

    test('"off", a missing field or anything else means off', () {
      expect(CheckoutMode.fromServer('off'), CheckoutMode.off);
      expect(CheckoutMode.fromServer(null), CheckoutMode.off);
      expect(CheckoutMode.fromServer('WEB'), CheckoutMode.off);
      expect(CheckoutMode.fromServer(true), CheckoutMode.off);
    });
  });
}
