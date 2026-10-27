import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';

/// Text, link-words, and student-blank fields inside [ConceptNodeSheet].
class ConceptNodeFields extends StatelessWidget {
  final ConceptMapNode node;
  final TextEditingController textController;
  final TextEditingController linkController;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onLinkChanged;
  final ValueChanged<bool> onBlankChanged;

  const ConceptNodeFields({
    super.key,
    required this.node,
    required this.textController,
    required this.linkController,
    required this.onTextChanged,
    required this.onLinkChanged,
    required this.onBlankChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryTextField(
          controller: textController,
          label: appTranslation().get('concept_map_node_text'),
          hint: appTranslation().get('concept_map_node_text_hint'),
          maxLength: ConceptMapLimits.maxTextLength,
          onChanged: onTextChanged,
        ),
        if (!node.isRoot) ...[
          verticalSpace10,
          PrimaryTextField(
            controller: linkController,
            label: appTranslation().get('concept_map_node_link'),
            hint: appTranslation().get('concept_map_node_link_hint'),
            maxLength: ConceptMapLimits.maxLinkLength,
            onChanged: onLinkChanged,
          ),
        ],
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: node.blank,
          activeThumbColor: ColorsManager.primaryColor,
          title: Text(
            appTranslation().get('concept_map_student_blank'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          subtitle: Text(
            appTranslation().get('concept_map_student_blank_hint'),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          onChanged: onBlankChanged,
        ),
      ],
    );
  }
}
