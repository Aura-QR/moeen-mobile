import 'dart:async';
import 'package:flutter/foundation.dart';

/// Represents the current status of the Madrasati school session.
enum MadrasatiSessionStatus {
  /// Status not yet determined (app just started).
  unknown,

  /// Session is valid and active.
  active,

  /// Session has expired (detected from API error response).
  expired,
}

/// Application-level service that monitors the Madrasati school session.
///
/// Any screen or widget can listen to [onSessionExpired] to react when
/// the backend reports a session expiry (code: madrasati_session_expired).
///
/// Usage:
/// ```dart
/// sl<MadrasatiSessionService>().onSessionExpired.listen((_) {
///   // show dialog
/// });
/// ```
class MadrasatiSessionService {
  MadrasatiSessionService();

  // ─── State ─────────────────────────────────────────────────────

  MadrasatiSessionStatus _status = MadrasatiSessionStatus.unknown;

  MadrasatiSessionStatus get status => _status;

  bool get isExpired => _status == MadrasatiSessionStatus.expired;

  // ─── Stream ────────────────────────────────────────────────────

  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  final StreamController<void> _sessionActiveController =
      StreamController<void>.broadcast();

  /// Fires whenever the Madrasati session is detected as expired.
  /// The [SessionMonitorWrapper] listens to this to show the dialog.
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  /// Fires whenever the Madrasati session is successfully refreshed.
  Stream<void> get onSessionActive => _sessionActiveController.stream;

  // ─── Public API ────────────────────────────────────────────────

  /// Called by [DioHelper] when it detects session-expired error codes.
  /// Only fires the event once per expiry cycle (prevents multiple dialogs).
  void notifySessionExpired() {
    if (_status == MadrasatiSessionStatus.expired) return; // already notified
    _status = MadrasatiSessionStatus.expired;
    debugPrint('🔴 MadrasatiSessionService: session expired detected');
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  /// Called after a successful session refresh or fresh connect.
  void notifySessionActive() {
    _status = MadrasatiSessionStatus.active;
    debugPrint('🟢 MadrasatiSessionService: session is active');
    if (!_sessionActiveController.isClosed) {
      _sessionActiveController.add(null);
    }
  }

  /// Reset to unknown (e.g., on logout).
  void reset() {
    _status = MadrasatiSessionStatus.unknown;
    debugPrint('⚪ MadrasatiSessionService: reset');
  }

  void dispose() {
    _sessionExpiredController.close();
    _sessionActiveController.close();
  }
}
