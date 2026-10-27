import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';

/// Arguments accepted by `Routes.outcomesMapEditor`.
/// A raw `int` (from «مستنداتي») and `null` (blank map) are also supported.
class OutcomesMapEditorArgs {
  final int? documentId;
  final OutcomesMapInput? initialInput;

  const OutcomesMapEditorArgs({this.documentId, this.initialInput});
}
