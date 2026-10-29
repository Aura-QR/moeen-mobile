import 'dart:async';
import 'package:flutter/foundation.dart';

/// The two account states the backend can report for a free trial whose email
/// is a problem: a bounced address, or one still unverified after 2 days.
enum EmailBlockKind { bounced, unverified }

/// A single `email_bounced` / `email_unverified` 403 the backend returned.
///
/// [message] is written for the user and shown as-is. [email] comes from the
/// response `details` and is used to re-send the confirmation message.
class EmailBlockEvent {
  final EmailBlockKind kind;
  final String message;
  final String? email;

  const EmailBlockEvent({
    required this.kind,
    required this.message,
    this.email,
  });
}

/// Application-level service that surfaces `email_bounced` / `email_unverified`
/// 403 responses globally, so any AI tool or preparation call refused for these
/// reasons shows the same actionable dialog regardless of the current screen.
///
/// [DioHelper] calls [notify] when it parses one of these codes; the
/// [EmailBlockMonitorWrapper] listens to [onBlocked] to show the dialog.
///
/// Unlike the Madrasati session, this status is not latched: a teacher can fix
/// the address and retry, so every refusal is broadcast and the wrapper guards
/// against stacking dialogs.
class EmailBlockService {
  EmailBlockService();

  final StreamController<EmailBlockEvent> _controller =
      StreamController<EmailBlockEvent>.broadcast();

  Stream<EmailBlockEvent> get onBlocked => _controller.stream;

  void notify(EmailBlockEvent event) {
    if (_controller.isClosed) return;
    debugPrint('🔴 EmailBlockService: ${event.kind} (${event.email})');
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
