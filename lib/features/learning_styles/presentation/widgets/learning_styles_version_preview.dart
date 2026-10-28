import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/presentation/cubit/new_learning_style_cubit.dart';

/// A collapsible preview of the selected version's scale and statements.
class LearningStylesVersionPreview extends StatelessWidget {
  const LearningStylesVersionPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewLearningStyleCubit, NewLearningStyleState>(
      buildWhen: (a, b) => a.options != b.options || a.version != b.version,
      builder: (context, state) {
        final version = state.options?.version(state.version);
        if (version == null) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Icon(Icons.quiz_outlined, color: ColorsManager.primaryColor),
              title: Text(appTranslation().get('learning_styles_preview_title'),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
              subtitle: Text(
                '${version.statements.length} ${appTranslation().get('learning_styles_statements')}',
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in version.scale)
                        Chip(
                          label: Text(
                            '${option.emoji != null ? '${option.emoji} ' : ''}${option.label}',
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
                          ),
                          backgroundColor: ColorsManager.background,
                        ),
                    ],
                  ),
                ),
                verticalSpace12,
                for (var i = 0; i < version.statements.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${i + 1}. ${version.statements[i].emoji != null ? '${version.statements[i].emoji} ' : ''}${version.statements[i].text}',
                      style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
