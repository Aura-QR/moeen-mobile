import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/email_block_service.dart';
import 'package:moean/features/email_block/presentation/widgets/email_block_dialog.dart';
import 'package:moean/main.dart';

/// Sits at the top of the widget tree (inside [MaterialApp.builder]) and listens
/// globally for `email_bounced` / `email_unverified` refusals.
///
/// When [EmailBlockService.onBlocked] fires it shows [EmailBlockDialog] via the
/// [navigatorKey], so the message and its action appear on whatever AI tool or
/// preparation screen the teacher was on. Mirrors [SessionMonitorWrapper].
class EmailBlockMonitorWrapper extends StatefulWidget {
  final Widget child;

  const EmailBlockMonitorWrapper({super.key, required this.child});

  @override
  State<EmailBlockMonitorWrapper> createState() =>
      _EmailBlockMonitorWrapperState();
}

class _EmailBlockMonitorWrapperState extends State<EmailBlockMonitorWrapper> {
  StreamSubscription<EmailBlockEvent>? _subscription;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    try {
      _subscription = sl<EmailBlockService>().onBlocked.listen(_showDialog);
    } catch (e) {
      debugPrint('EmailBlockMonitorWrapper: could not subscribe: $e');
    }
  }

  Future<void> _showDialog(EmailBlockEvent event) async {
    if (_dialogShowing) return; // Prevent stacking multiple dialogs
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _dialogShowing = true;
    await EmailBlockDialog.show(context, event);
    _dialogShowing = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
