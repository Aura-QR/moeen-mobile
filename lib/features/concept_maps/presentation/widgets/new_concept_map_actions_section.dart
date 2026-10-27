import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/cubit/new_concept_map_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_ai_error_banner.dart';

/// Action buttons on [NewConceptMapScreen]: «✨ اقترح الخريطة» and «ابدأ بخريطة فارغة».
class NewConceptMapActionsSection extends StatelessWidget {
  final NewConceptMapState state;
  final VoidCallback onStartBlank;

  const NewConceptMapActionsSection({
    super.key,
    required this.state,
    required this.onStartBlank,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NewConceptMapCubit.get(context);
    final isGenerating = state.isGeneratingAi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isGenerating) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              horizontalSpace10,
              Flexible(
                child: Text(
                  appTranslation().get('concept_map_ai_generating'),
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace12,
        ],
        if (state.aiErrorMessage != null && !isGenerating) ...[
          ConceptMapAiErrorBanner(
            message: state.aiErrorMessage!,
            onRetry: cubit.suggestMap,
          ),
          verticalSpace12,
        ],
        PrimaryElevatedButton(
          text: appTranslation().get('concept_map_suggest_ai'),
          isLoading: isGenerating,
          onPressed: state.canSuggestAi ? cubit.suggestMap : null,
        ),
        verticalSpace10,
        OutlinedButton.icon(
          onPressed: isGenerating ? null : onStartBlank,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: ColorsManager.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(
            Icons.edit_note_rounded,
            size: 20,
            color: ColorsManager.primaryColor,
          ),
          label: Text(
            appTranslation().get('concept_map_start_blank'),
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
