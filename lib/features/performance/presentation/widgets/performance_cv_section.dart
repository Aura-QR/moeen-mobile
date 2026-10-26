import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_expandable_card_widget.dart';

/// «السيرة الذاتية»: the CV fields of the performance file. Holds only the
/// text controllers; saving goes through [PerformanceCubit].
class PerformanceCvSection extends StatefulWidget {
  final Map<String, String> cv;

  const PerformanceCvSection({super.key, required this.cv});

  @override
  State<PerformanceCvSection> createState() => _PerformanceCvSectionState();
}

class _PerformanceCvSectionState extends State<PerformanceCvSection> {
  late final Map<String, TextEditingController> _controllers = {
    for (final field in PerformanceCvFields.all) field: TextEditingController(text: widget.cv[field] ?? ''),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PortfolioExpandableCardWidget(
      leading: Icon(Icons.badge_outlined, color: ColorsManager.primaryColor),
      title: Text(
        appTranslation().get('performance_cv'),
        style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
      ),
      children: [
        for (final field in PerformanceCvFields.all) ...[
          PrimaryTextField(
            controller: _controllers[field]!,
            label: appTranslation().get(PerformanceCvFields.labelKey(field)),
            hint: appTranslation().get(PerformanceCvFields.labelKey(field)),
          ),
          verticalSpace10,
        ],
        Text(
          appTranslation().get('performance_cv_hint'),
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace12,
        BlocSelector<PerformanceCubit, PerformanceState, bool>(
          selector: (state) => state.isSavingCv,
          builder: (context, isSaving) => PrimaryElevatedButton(
            text: appTranslation().get('save'),
            isLoading: isSaving,
            onPressed: () => PerformanceCubit.get(context).saveCv({
              for (final entry in _controllers.entries) entry.key: entry.value.text,
            }),
          ),
        ),
      ],
    );
  }
}
