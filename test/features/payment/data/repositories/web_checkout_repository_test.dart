import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/payment/data/repositories/web_checkout_repository.dart';

void main() {
  group('checkoutPath', () {
    test('carries the chosen plan', () {
      expect(WebCheckoutRepository.checkoutPath(serviceId: 7),
          '/checkout?service_id=7');
    });

    test('leaves the plan out when none was chosen', () {
      expect(WebCheckoutRepository.checkoutPath(), '/checkout');
    });
  });

  group('handoffUrlFrom', () {
    test('reads data.url', () {
      expect(
        WebCheckoutRepository.handoffUrlFrom({
          'data': {'url': 'https://haderedu.com/h?c=1', 'expires_in': 120},
        }),
        'https://haderedu.com/h?c=1',
      );
    });

    test('reads a JSON string body', () {
      expect(
        WebCheckoutRepository.handoffUrlFrom(
            '{"data":{"url":"https://haderedu.com/h","expires_in":120}}'),
        'https://haderedu.com/h',
      );
    });

    test('is null when the url is missing or empty', () {
      expect(WebCheckoutRepository.handoffUrlFrom(null), isNull);
      expect(WebCheckoutRepository.handoffUrlFrom('not json'), isNull);
      expect(WebCheckoutRepository.handoffUrlFrom({'data': {}}), isNull);
      expect(
          WebCheckoutRepository.handoffUrlFrom({
            'data': {'url': ''}
          }),
          isNull);
    });
  });
}
