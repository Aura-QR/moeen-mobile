import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_band_tile.dart';

/// «مستويات الأداء», folded by default: the levels a grade's percentage falls in.
class GradeBandsSection extends StatelessWidget {
  const GradeBandsSection({super.key});

  Future<List<String>?> _ask(BuildContext context, String titleKey, GradeBand? band) => PrimaryInputDialog.show(
    context,
    titleKey: titleKey,
    fields: [
      PrimaryInputField(hintKey: 'grades_band_label_hint', initialValue: band?.label ?? '', maxLength: 40),
      PrimaryInputField(
        hintKey: 'grades_band_min_hint',
        initialValue: band == null ? '' : formatGrade(band.min),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    ],
  );

  Future<void> _edit(BuildContext context, int index, GradeBand band) async {
    final cubit = GradeAnalysisCubit.get(context);
    final values = await _ask(context, 'grades_band_edit', band);
    if (values != null) cubit.setBand(index, values[0], values[1]);
  }

  Future<void> _add(BuildContext context) async {
    final cubit = GradeAnalysisCubit.get(context);
    final values = await _ask(context, 'grades_band_add', null);
    if (values != null) cubit.addBand(values[0], values[1]);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: ExpansionTile(
        // No divider lines of its own; the container draws the border.
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.stacked_bar_chart_rounded, color: ColorsManager.primaryColor),
        title: Text(
          appTranslation().get('grades_section_bands'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        subtitle: Text(
          appTranslation().get('grades_bands_subtitle'),
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
            buildWhen: (previous, current) => previous.bands != current.bands,
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < state.bands.length; i++)
                  GradeBandTile(
                    key: ValueKey('${state.bands[i].label}-$i'),
                    band: state.bands[i],
                    onEdit: () => _edit(context, i, state.bands[i]),
                    onRemove: state.bands.length > GradeLimits.minBands ? () => cubit.removeBand(i) : null,
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (state.bands.length < state.options.limits.bands)
                      TextButton.icon(
                        onPressed: () => _add(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text(appTranslation().get('grades_band_add')),
                      ),
                    TextButton.icon(
                      onPressed: cubit.resetBands,
                      icon: const Icon(Icons.restart_alt_rounded, size: 20),
                      label: Text(appTranslation().get('grades_bands_reset')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
