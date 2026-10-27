/// Parses a `422` validation field key such as `nodes.3.text` or `title`.
class ConceptMapFieldError {
  final int? nodeIndex;
  final bool isTitle;
  final String message;

  const ConceptMapFieldError({
    required this.message,
    this.nodeIndex,
    this.isTitle = false,
  });

  static ConceptMapFieldError? parse(String key, dynamic messages) {
    final message = messages is List && messages.isNotEmpty
        ? messages.first.toString()
        : messages?.toString() ?? '';
    final clean = key.startsWith('input.')
        ? key.substring('input.'.length)
        : key;
    if (clean == 'title') {
      return ConceptMapFieldError(message: message, isTitle: true);
    }
    final match = RegExp(r'^nodes\.(\d+)(\.|$)').firstMatch(clean);
    if (match == null) return null;
    return ConceptMapFieldError(
      message: message,
      nodeIndex: int.parse(match.group(1)!),
    );
  }
}
