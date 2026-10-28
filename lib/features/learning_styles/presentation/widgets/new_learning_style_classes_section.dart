import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_field_label.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/cubit/new_learning_style_cubit.dart';

/// Picks the survey's classes, from «فصولي» or by typing a name (1–10).
class NewLearningStyleClassesSection extends StatefulWidget {
  const NewLearningStyleClassesSection({super.key});

  @override
  State<NewLearningStyleClassesSection> createState() => _NewLearningStyleClassesSectionState();
}

class _NewLearningStyleClassesSectionState extends State<NewLearningStyleClassesSection> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NewLearningStyleCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.groups_2_outlined,
      title: appTranslation().get('learning_styles_classes_section'),
      child: BlocBuilder<NewLearningStyleCubit, NewLearningStyleState>(
        builder: (context, state) {
          final usedClassIds = state.groups.map((g) => g.classId).whereType<int>().toSet();
          final available = state.classes.where((c) => c.id != null && !usedClassIds.contains(c.id)).toList();
          final canAddMore = state.groups.length < state.maxGroups;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.groups.isEmpty)
                Text(appTranslation().get('learning_styles_classes_empty'),
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < state.groups.length; i++)
                      Chip(
                        label: Text(state.groups[i].name, style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
                        backgroundColor: ColorsManager.background,
                        onDeleted: () => cubit.removeGroup(i),
                      ),
                  ],
                ),
              verticalSpace16,
              PrimaryFieldLabel(textKey: 'learning_styles_add_typed'),
              verticalSpace8,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      maxLength: LearningStylesLimits.maxGroupNameLength,
                      enabled: canAddMore,
                      style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                      decoration: InputDecoration(
                        hintText: appTranslation().get('learning_styles_class_name_hint'),
                        isDense: true,
                        counterText: '',
                        filled: true,
                        fillColor: ColorsManager.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  horizontalSpace8,
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: canAddMore
                        ? () {
                            cubit.addGroup(_name.text);
                            _name.clear();
                          }
                        : null,
                  ),
                ],
              ),
              if (available.isNotEmpty) ...[
                verticalSpace12,
                PrimaryFieldLabel(textKey: 'learning_styles_pick_class'),
                verticalSpace8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final schoolClass in available)
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: Text(schoolClass.name, style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
                        backgroundColor: ColorsManager.background,
                        onPressed: canAddMore ? () => cubit.addGroup(schoolClass.name, classId: schoolClass.id) : null,
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
