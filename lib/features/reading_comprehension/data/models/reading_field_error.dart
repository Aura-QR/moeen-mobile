/// Which part of a reading worksheet a `422` points at.
enum ReadingErrorTarget { title, passage, vocabulary, question, other }

/// Parses a `422` validation key such as `passage.2`, `vocabulary.1.word`,
/// `questions.3.level` or `title` (optionally prefixed with `input.`).
class ReadingFieldError {
  final ReadingErrorTarget target;

  /// The index inside its array, when the key carries one.
  final int? index;
  final String message;

  const ReadingFieldError({required this.target, required this.message, this.index});

  static ReadingFieldError? parse(String key, dynamic messages) {
    final message = messages is List && messages.isNotEmpty
        ? messages.first.toString()
        : messages?.toString() ?? '';
    final clean = key.startsWith('input.') ? key.substring('input.'.length) : key;

    if (clean == 'title') {
      return ReadingFieldError(target: ReadingErrorTarget.title, message: message);
    }
    if (clean == 'passage' || clean == 'lesson_id') {
      return ReadingFieldError(target: ReadingErrorTarget.passage, message: message);
    }

    final match = RegExp(r'^(passage|vocabulary|questions)\.(\d+)').firstMatch(clean);
    if (match == null) {
      return ReadingFieldError(target: ReadingErrorTarget.other, message: message);
    }
    final index = int.parse(match.group(2)!);
    switch (match.group(1)) {
      case 'passage':
        return ReadingFieldError(target: ReadingErrorTarget.passage, message: message, index: index);
      case 'vocabulary':
        return ReadingFieldError(target: ReadingErrorTarget.vocabulary, message: message, index: index);
      default:
        return ReadingFieldError(target: ReadingErrorTarget.question, message: message, index: index);
    }
  }
}
