import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/features/hader_webview/data/hader_prep_models.dart';

enum HaderPrepPhase {
  /// The hidden WebView is loading Madrasati and content.js has not reported yet.
  loading,

  /// Lessons are on screen and the teacher can choose.
  ready,

  /// content.js is working through the batch.
  preparing,

  /// content.js stopped itself — expired subscription, no sign-in, and so on.
  blocked,
}

class HaderPrepState extends Equatable {
  const HaderPrepState({
    this.phase = HaderPrepPhase.loading,
    this.snapshot = const HaderPrepSnapshot.empty(),
    this.pending = const <String, String>{},
    this.message = '',
  });

  final HaderPrepPhase phase;
  final HaderPrepSnapshot snapshot;

  /// Choices made natively that have not been written into the WebView yet.
  /// Keyed by lesson token.
  final Map<String, String> pending;

  final String message;

  /// Slots with the teacher's pending choice merged over what the WebView holds,
  /// so the UI reflects a tap immediately instead of waiting for the round trip.
  List<HaderLessonSlot> get slots {
    return snapshot.slots.map((slot) {
      final override = pending[slot.token];
      return override == null ? slot : slot.copyWith(selected: override);
    }).toList();
  }

  int get selectedCount => slots.where((s) => s.hasSelection).length;

  bool get canPrepare =>
      phase == HaderPrepPhase.ready && selectedCount > 0;

  HaderPrepState copyWith({
    HaderPrepPhase? phase,
    HaderPrepSnapshot? snapshot,
    Map<String, String>? pending,
    String? message,
  }) {
    return HaderPrepState(
      phase: phase ?? this.phase,
      snapshot: snapshot ?? this.snapshot,
      pending: pending ?? this.pending,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [phase, snapshot, pending, message];
}

/// Drives lesson preparation from a native UI backed by a hidden WebView.
///
/// The WebView still runs the automation — `handleDashboardSave()` in
/// content.js reads the live Madrasati DOM for the ids it needs, so the work
/// has to happen there. This cubit owns the other half: it holds what the page
/// reported, records what the teacher picked, and pushes those choices back
/// before telling the page to start.
class HaderPrepCubit extends Cubit<HaderPrepState> {
  HaderPrepCubit() : super(const HaderPrepState());

  InAppWebViewController? _controller;

  void attach(InAppWebViewController controller) {
    _controller = controller;
  }

  /// Called whenever the injected remote control reports a change.
  void onSnapshot(Map<dynamic, dynamic> json) {
    if (isClosed) return;
    final snapshot = HaderPrepSnapshot.fromJson(json);

    if (snapshot.isBlocked) {
      emit(state.copyWith(
        phase: HaderPrepPhase.blocked,
        snapshot: snapshot,
        message: snapshot.blockedMessage,
      ));
      return;
    }

    // Once the batch is running, content.js's own status line is the most
    // accurate thing on screen, so it is surfaced verbatim.
    if (state.phase == HaderPrepPhase.preparing) {
      emit(state.copyWith(snapshot: snapshot, message: snapshot.status));
      return;
    }

    emit(state.copyWith(
      phase: snapshot.slots.isEmpty ? HaderPrepPhase.loading : HaderPrepPhase.ready,
      snapshot: snapshot,
      message: snapshot.status,
    ));
  }

  /// Records a choice locally and mirrors it into the hidden page.
  ///
  /// Writing straight through keeps content.js's AI prefetch warming while the
  /// teacher is still picking, which is what makes the batch fast later.
  Future<void> select(String token, String value) async {
    if (isClosed) return;
    final pending = Map<String, String>.from(state.pending)..[token] = value;
    emit(state.copyWith(pending: pending));
    await _push({token: value});
  }

  Future<void> clear(String token) => select(token, '');

  Future<void> _push(Map<String, String> selections) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.evaluateJavascript(
        source: 'window.__haderApplySelections(${jsonEncode(selections)})',
      );
    } catch (error) {
      debugPrint('[HaderPrep] failed to push selections: $error');
    }
  }

  /// Pushes every choice once more, then clicks the panel's own save button.
  ///
  /// The re-push is deliberate: a slot can be re-rendered by content.js's card
  /// scan after it was chosen, which resets the dropdown it was written to.
  Future<void> startPreparation() async {
    final controller = _controller;
    if (controller == null || !state.canPrepare) return;

    emit(state.copyWith(
      phase: HaderPrepPhase.preparing,
      message: 'جارٍ تحضير الحصص المختارة…',
    ));

    await _push(state.pending);

    try {
      final raw = await controller.evaluateJavascript(
        source: 'window.__haderStartPreparation()',
      );
      final result = raw is Map ? raw : const <String, dynamic>{};
      if (result['started'] != true) {
        emit(state.copyWith(
          phase: HaderPrepPhase.ready,
          message: result['reason'] == 'disabled'
              ? 'تأكد من اختيار درس واحد على الأقل.'
              : 'تعذّر بدء التحضير. حاول مرة أخرى.',
        ));
      }
    } catch (error) {
      debugPrint('[HaderPrep] failed to start preparation: $error');
      emit(state.copyWith(
        phase: HaderPrepPhase.ready,
        message: 'تعذّر بدء التحضير. حاول مرة أخرى.',
      ));
    }
  }

  /// Called when the automation reports a terminal status through the bridge.
  void onAutomationStatus(String status) {
    if (isClosed) return;
    if (status == 'DONE') {
      emit(state.copyWith(
        phase: HaderPrepPhase.ready,
        pending: const <String, String>{},
        message: 'تم تحضير الحصص بنجاح ✅',
      ));
    } else if (status == 'ERROR') {
      emit(state.copyWith(
        phase: HaderPrepPhase.ready,
        message: 'تعذّر إكمال التحضير. راجع الحصص وحاول مرة أخرى.',
      ));
    }
  }
}
