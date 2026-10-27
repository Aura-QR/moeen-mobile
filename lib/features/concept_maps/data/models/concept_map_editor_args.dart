import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';

/// Arguments accepted by `Routes.conceptMapsEditor`.
/// Raw `int` (from «مستنداتي») and `null` (blank map) are also supported.
class ConceptMapEditorArgs {
  final int? documentId;
  final ConceptMapInput? initialInput;

  const ConceptMapEditorArgs({this.documentId, this.initialInput});
}
