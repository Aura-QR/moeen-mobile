import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';

/// «محتوى الاستراتيجية»: the definition and four editable lists.
class StrategyContentSection extends StatelessWidget {
  const StrategyContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = StrategyDocumentationCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.article_outlined,
      title: appTranslation().get('strategy_section_content'),
      child: BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
        buildWhen: (previous, current) =>
            previous.lists != current.lists ||
            previous.strategy != current.strategy ||
            previous.strategyKey != current.strategyKey,
        builder: (context, state) {
          if (state.strategyKey == null) {
            return Text(
              appTranslation().get('strategy_content_empty'),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            );
          }
          final canReset = state.strategy != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appTranslation().get('strategy_definition'),
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                  if (canReset)
                    IconButton(
                      tooltip: appTranslation().get('document_reset_original'),
                      onPressed: cubit.resetDefinition,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.restart_alt_rounded, size: 20, color: ColorsManager.secondaryText),
                    ),
                ],
              ),
              verticalSpace8,
              PrimaryTextField(
                controller: cubit.definitionController,
                hint: appTranslation().get('strategy_definition_hint'),
                maxLines: 5,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
              for (final section in StrategyListSection.values) ...[
                verticalSpace20,
                PrimaryEditableList(
                  title: appTranslation().get(section.titleKey),
                  items: state.listOf(section),
                  maxItems: section.maxItems,
                  maxLength: StrategyListSection.maxItemLength,
                  onAdd: (text) => cubit.addListItem(section, text),
                  onEdit: (index, text) => cubit.editListItem(section, index, text),
                  onRemove: (index) => cubit.removeListItem(section, index),
                  onReorder: (oldIndex, newIndex) => cubit.reorderListItem(section, oldIndex, newIndex),
                  onReset: canReset ? () => cubit.resetList(section) : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
