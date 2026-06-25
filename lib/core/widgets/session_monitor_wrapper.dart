import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/core/widgets/session_expired_dialog.dart';
import 'package:moean/main.dart';

/// A transparent widget that sits at the top of the widget tree (inside
/// [MaterialApp.builder]) and listens globally for Madrasati session expiry.
///
/// When [MadrasatiSessionService.onSessionExpired] fires it shows
/// [SessionExpiredDialog] via the [navigatorKey], ensuring the dialog
/// appears regardless of which screen the user is currently on.
class SessionMonitorWrapper extends StatefulWidget {
  final Widget child;

  const SessionMonitorWrapper({super.key, required this.child});

  @override
  State<SessionMonitorWrapper> createState() => _SessionMonitorWrapperState();
}

class _SessionMonitorWrapperState extends State<SessionMonitorWrapper> {
  StreamSubscription<void>? _subscription;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    try {
      _subscription =
          sl<MadrasatiSessionService>().onSessionExpired.listen((_) {
        _showExpiredDialog();
      });
    } catch (e) {
      debugPrint('SessionMonitorWrapper: could not subscribe: $e');
    }
  }

  Future<void> _showExpiredDialog() async {
    if (_dialogShowing) return; // Prevent stacking multiple dialogs
    _dialogShowing = true;

    final context = navigatorKey.currentContext;
    if (context == null) {
      _dialogShowing = false;
      return;
    }

    debugPrint('🔔 SessionMonitorWrapper: showing session expired dialog');

    await SessionExpiredDialog.show(context);

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
