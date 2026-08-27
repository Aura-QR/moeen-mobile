import 'package:equatable/equatable.dart';

/// One lesson option a teacher can pick for a slot, mirroring an `<option>` in
/// the dropdown content.js renders.
class HaderLessonOption extends Equatable {
  const HaderLessonOption({required this.value, required this.text});

  /// Madrasati's composite lesson id — passed back verbatim, never parsed.
  final String value;
  final String text;

  factory HaderLessonOption.fromJson(Map<dynamic, dynamic> json) {
    return HaderLessonOption(
      value: json['value'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [value, text];
}

/// A slot in the teacher's week, harvested from the hidden WebView.
class HaderLessonSlot extends Equatable {
  const HaderLessonSlot({
    required this.token,
    required this.subject,
    required this.detail,
    required this.day,
    required this.period,
    required this.subjectId,
    required this.selected,
    required this.options,
  });

  /// The card's `data-data` value. This is the key the automation matches on,
  /// so it is carried through untouched.
  final String token;

  final String subject;

  /// Whatever else the card showed — in practice the class name.
  final String detail;

  final String day;
  final String period;
  final String subjectId;

  /// Currently chosen lesson value, empty when nothing is picked yet.
  final String selected;

  final List<HaderLessonOption> options;

  bool get hasSelection => selected.isNotEmpty;

  String get title => subject.isNotEmpty ? subject : 'حصة';

  factory HaderLessonSlot.fromJson(Map<dynamic, dynamic> json) {
    final rawOptions = json['options'];
    return HaderLessonSlot(
      token: json['token'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      day: json['day'] as String? ?? '',
      period: json['period'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      selected: json['selected'] as String? ?? '',
      options: rawOptions is List
          ? rawOptions
              .whereType<Map<dynamic, dynamic>>()
              .map(HaderLessonOption.fromJson)
              .toList()
          : const <HaderLessonOption>[],
    );
  }

  HaderLessonSlot copyWith({String? selected}) {
    return HaderLessonSlot(
      token: token,
      subject: subject,
      detail: detail,
      day: day,
      period: period,
      subjectId: subjectId,
      selected: selected ?? this.selected,
      options: options,
    );
  }

  @override
  List<Object?> get props =>
      [token, subject, detail, day, period, subjectId, selected, options];
}

/// A snapshot of what the hidden WebView currently holds.
class HaderPrepSnapshot extends Equatable {
  const HaderPrepSnapshot({
    required this.slots,
    required this.counter,
    required this.status,
    required this.canPrepare,
    required this.panelPresent,
    required this.blockedMessage,
  });

  const HaderPrepSnapshot.empty()
      : slots = const <HaderLessonSlot>[],
        counter = '',
        status = '',
        canPrepare = false,
        panelPresent = false,
        blockedMessage = '';

  final List<HaderLessonSlot> slots;

  /// content.js's own "N من M" counter, shown as-is so the two views never
  /// disagree about how much is selected.
  final String counter;

  final String status;
  final bool canPrepare;
  final bool panelPresent;

  /// Set when content.js blocked itself — an expired subscription, say. The
  /// native UI surfaces this instead of an empty schedule.
  final String blockedMessage;

  bool get isBlocked => blockedMessage.isNotEmpty;

  int get selectedCount => slots.where((s) => s.hasSelection).length;

  /// Slots grouped by day, preserving the order they appear in the week.
  Map<String, List<HaderLessonSlot>> get byDay {
    final grouped = <String, List<HaderLessonSlot>>{};
    for (final slot in slots) {
      final key = slot.day.isNotEmpty ? slot.day : 'الحصص';
      grouped.putIfAbsent(key, () => <HaderLessonSlot>[]).add(slot);
    }
    return grouped;
  }

  factory HaderPrepSnapshot.fromJson(Map<dynamic, dynamic> json) {
    final rawLessons = json['lessons'];
    return HaderPrepSnapshot(
      slots: rawLessons is List
          ? rawLessons
              .whereType<Map<dynamic, dynamic>>()
              .map(HaderLessonSlot.fromJson)
              .where((slot) => slot.token.isNotEmpty)
              .toList()
          : const <HaderLessonSlot>[],
      counter: json['counter'] as String? ?? '',
      status: json['status'] as String? ?? '',
      canPrepare: json['canPrepare'] == true,
      panelPresent: json['panelPresent'] == true,
      blockedMessage: json['blockedMessage'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [slots, counter, status, canPrepare, panelPresent, blockedMessage];
}
