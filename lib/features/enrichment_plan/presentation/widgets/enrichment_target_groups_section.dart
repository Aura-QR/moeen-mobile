import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';

/// «الفئة المستهدفة»: several of the catalogue's groups, plus «أخرى».
class EnrichmentTargetGroupsSection extends StatelessWidget {
  const EnrichmentTargetGroupsSection({super.key});

  static const String _key = PlanFormState.targetGroupsKey;

  Future<void> _addOther(BuildContext context) async {
    final cubit = PlanFormCubit.get(context);
    final values = await PrimaryInputDialog.show(context, titleKey: 'plan_target_group_other', fields: const [
      PrimaryInputField(hintKey: 'plan_target_group_hint', maxLength: PlanToolConfig.maxTargetGroupLength),
    ]);
    if (values != null) cubit.addCustomLine(_key, values.first);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.emoji_events_outlined,
      title: appTranslation().get('plan_section_target_groups'),
      child: BlocSelector<PlanFormCubit, PlanFormState, ChecklistSection>(
        selector: (state) => state.targetGroups,
        builder: (context, groups) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < groups.lines.length; i++)
              FilterChip(
                label: Text(groups.lines[i].text),
                selected: groups.lines[i].isChecked,
                onSelected: (_) => cubit.toggleLine(_key, i),
                onDeleted: groups.lines[i].isCustom ? () => cubit.removeCustomLine(_key, i) : null,
                showCheckmark: false,
                selectedColor: ColorsManager.primaryColor,
                backgroundColor: ColorsManager.background,
                deleteIconColor: groups.lines[i].isChecked ? ColorsManager.white : ColorsManager.secondaryText,
                side: BorderSide(
                  color: groups.lines[i].isChecked ? ColorsManager.primaryColor : ColorsManager.borderColor,
                ),
                labelStyle: TextStylesManager.medium13.copyWith(
                  color: groups.lines[i].isChecked ? ColorsManager.white : ColorsManager.mainText,
                ),
              ),
            if (!groups.isFull)
              ActionChip(
                avatar: Icon(Icons.add_rounded, size: 18, color: ColorsManager.primaryColor),
                label: Text(appTranslation().get('plan_target_group_other')),
                onPressed: () => _addOther(context),
                backgroundColor: ColorsManager.background,
                side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.4)),
                labelStyle: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
