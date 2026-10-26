import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/errors/failures.dart';

void main() {
  group('failureFromApiError', () {
    test('keeps an API message for the user', () {
      expect(failureFromApiError('لديك 5 ملفات إنجاز بالفعل').message, 'لديك 5 ملفات إنجاز بالفعل');
    });

    test('maps a missing response to the network key', () {
      expect(failureFromApiError('No response from server').message, 'network_error');
    });

    test('maps status-line errors to the generic key', () {
      expect(failureFromApiError('Error 500: Internal Server Error').message, 'generic_error');
      expect(failureFromApiError('something went wrong').message, 'generic_error');
    });

    test('takes the message out of coded errors', () {
      expect(failureFromApiError('__402__:quota_exceeded:ترقية الحساب').message, 'ترقية الحساب');
    });

    test('marks 402 as PaymentRequiredFailure with its code', () {
      final failure = failureFromApiError('__402__:subscription_required:ترقية الحساب');
      expect(failure, isA<PaymentRequiredFailure>());
      expect((failure as PaymentRequiredFailure).code, 'subscription_required');
    });

    test('turns a kept 422 into ValidationFailure with its field keys', () {
      final failure = failureFromApiError(
        '__422__:{"message":"الرابط غير صالح","errors":{"input.blocks.2.url":["الرابط غير صالح"]}}',
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'الرابط غير صالح');
      expect((failure as ValidationFailure).errors.keys, ['input.blocks.2.url']);
    });

    test('a broken kept 422 falls back to the generic key', () {
      expect(failureFromApiError('__422__:{oops').message, 'generic_error');
    });

    test('marks Unauthenticated as UnauthorizedFailure', () {
      expect(failureFromApiError('Unauthenticated'), isA<UnauthorizedFailure>());
    });
  });
}
