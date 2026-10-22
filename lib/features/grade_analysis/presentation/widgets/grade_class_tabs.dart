import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// One tab per class, named as typed, and «+ فصل للمقارنة».
class GradeClassTabs extends StatelessWidget {
  const GradeClassTabs({super.key});

  static List<int> _ids(GradeAnalysisState state) => [for (final layout in state.classes) layout.id];

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
      buildWhen: (previous, current) =>
          !listEquals(_ids(previous), _ids(current)) || previous.activeClass != current.activeClass,
      builder: (context, state) => ListenableBuilder(
        listenable: Listenable.merge([for (final layout in state.classes) cubit.editor.classFields(layout.id).name]),
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryChoiceChips<int>(
              options: [for (var i = 0; i < state.classes.length; i++) i],
              labelOf: (i) {
                final name = cubit.editor.className(state.classes[i]);
                return name.isEmpty ? appTranslation().get('grades_class_n').replaceAll('{n}', '${i + 1}') : name;
              },
              isSelected: (i) => i == state.activeClass,
              onTap: cubit.selectClass,
            ),
            if (state.canAddClass) ...[
              verticalSpace4,
              TextButton.icon(
                onPressed: cubit.addClass,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(appTranslation().get('grades_add_class')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
