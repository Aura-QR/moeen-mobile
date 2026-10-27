/// Parses a `422` validation field key such as `units.1.lessons.2.outcomes`,
/// `units.0.name`, or `title` (DOCUMENTS_API.md § 16).
class OutcomesMapFieldError {
  final bool isTitle;
  final int? unitIndex;
  final int? lessonIndex;
  final String message;

  const OutcomesMapFieldError({
    required this.message,
    this.isTitle = false,
    this.unitIndex,
    this.lessonIndex,
  });

  bool get isLesson => unitIndex != null && lessonIndex != null;

  static OutcomesMapFieldError? parse(String key, dynamic messages) {
    final message = messages is List && messages.isNotEmpty
        ? messages.first.toString()
        : messages?.toString() ?? '';
    final clean = key.startsWith('input.') ? key.substring('input.'.length) : key;

    if (clean == 'title') {
      return OutcomesMapFieldError(message: message, isTitle: true);
    }

    final lessonMatch = RegExp(r'^units\.(\d+)\.lessons\.(\d+)(\.|$)').firstMatch(clean);
    if (lessonMatch != null) {
      return OutcomesMapFieldError(
        message: message,
        unitIndex: int.parse(lessonMatch.group(1)!),
        lessonIndex: int.parse(lessonMatch.group(2)!),
      );
    }

    final unitMatch = RegExp(r'^units\.(\d+)(\.|$)').firstMatch(clean);
    if (unitMatch != null) {
      return OutcomesMapFieldError(
        message: message,
        unitIndex: int.parse(unitMatch.group(1)!),
      );
    }
    return null;
  }
}
