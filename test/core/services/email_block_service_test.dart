import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/services/email_block_service.dart';

void main() {
  group('EmailBlockService', () {
    late EmailBlockService service;

    setUp(() {
      service = EmailBlockService();
    });

    tearDown(() {
      service.dispose();
    });

    test('onBlocked broadcasts the event passed to notify', () async {
      const event = EmailBlockEvent(
        kind: EmailBlockKind.bounced,
        message: 'bounced message',
        email: 'typo@estg.mow.gov.sa',
      );

      expectLater(service.onBlocked, emits(event));

      service.notify(event);
    });

    test('is a broadcast stream (supports multiple listeners)', () async {
      const event = EmailBlockEvent(
        kind: EmailBlockKind.unverified,
        message: 'verify message',
        email: 'teacher@moe.gov.sa',
      );

      final first = service.onBlocked.first;
      final second = service.onBlocked.first;

      service.notify(event);

      expect(await first, event);
      expect(await second, event);
    });

    test('notify after dispose does not throw', () {
      service.dispose();
      expect(
        () => service.notify(
          const EmailBlockEvent(
            kind: EmailBlockKind.bounced,
            message: 'late',
          ),
        ),
        returnsNormally,
      );
    });
  });
}
