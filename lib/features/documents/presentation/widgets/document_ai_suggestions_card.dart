import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';

/// An AI suggestions card: its title, what it does or how far it got, and
/// the button. Needs an [AiSuggestionsCubit] above it.
class DocumentAiSuggestionsCard extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;
  final String actionKey;
  final String loadingKey;
  final String doneKey;
  final VoidCallback onSuggest;

  const DocumentAiSuggestionsCard({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.actionKey,
    required this.loadingKey,
    required this.doneKey,
    required this.onSuggest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorsManager.secondaryColor.withValues(alpha: 0.35)),
      ),
      child: BlocBuilder<AiSuggestionsCubit, AiSuggestionsState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.errorMessage != current.errorMessage,
        builder: (context, ai) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: ColorsManager.secondaryColor),
                horizontalSpace10,
                Expanded(
                  child: Text(
                    appTranslation().get(titleKey),
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
              ],
            ),
            verticalSpace6,
            Text(
              appTranslation().get(switch (ai.status) {
                AiSuggestionsStatus.loading => loadingKey,
                AiSuggestionsStatus.done => doneKey,
                _ => subtitleKey,
              }),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            ),
            if (ai.status == AiSuggestionsStatus.failed) ...[
              verticalSpace8,
              Text(
                appTranslation().get(ai.errorMessage ?? 'ai_suggestions_failed'),
                style: TextStylesManager.medium13.copyWith(color: ColorsManager.errorColor),
              ),
            ],
            verticalSpace12,
            if (ai.isLoading)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  color: ColorsManager.secondaryColor,
                  backgroundColor: ColorsManager.secondaryColor.withValues(alpha: 0.15),
                ),
              )
            else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorsManager.secondaryColor,
                    foregroundColor: ColorsManager.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onSuggest,
                  icon: Icon(
                    ai.status == AiSuggestionsStatus.failed ? Icons.refresh_rounded : Icons.auto_awesome_rounded,
                    size: 18,
                  ),
                  label: Text(
                    appTranslation().get(ai.status == AiSuggestionsStatus.failed ? 'retry' : actionKey),
                    style: TextStylesManager.bold13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
