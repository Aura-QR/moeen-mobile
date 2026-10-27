import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

/// Arguments accepted by `Routes.readingComprehensionEditor`.
/// A raw `int` (from «مستنداتي») and `null` (a blank worksheet) also work.
class ReadingEditorArgs {
  final int? documentId;
  final ReadingComprehensionInput? initialInput;

  const ReadingEditorArgs({this.documentId, this.initialInput});
}
