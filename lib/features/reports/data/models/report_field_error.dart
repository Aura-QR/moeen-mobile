/// A `422` key such as `blocks.3.items.0`: which block failed, or the title.
class ReportFieldError {
  /// Null when the error isn't inside a block.
  final int? blockIndex;
  final bool isTitle;
  final String message;

  const ReportFieldError({required this.message, this.blockIndex, this.isTitle = false});

  /// Null for keys the editor can't point at.
  static ReportFieldError? parse(String key, dynamic messages) {
    final message = messages is List && messages.isNotEmpty ? messages.first.toString() : messages?.toString() ?? '';
    final clean = key.startsWith('input.') ? key.substring('input.'.length) : key;
    if (clean == 'title') return ReportFieldError(message: message, isTitle: true);
    final match = RegExp(r'^blocks\.(\d+)(\.|$)').firstMatch(clean);
    if (match == null) return null;
    return ReportFieldError(message: message, blockIndex: int.parse(match.group(1)!));
  }
}
