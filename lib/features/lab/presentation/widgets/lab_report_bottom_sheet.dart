import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/presentation/cubit/lab_experiment_cubit.dart';

class LabReportBottomSheet extends StatefulWidget {
  final LabExperimentCubit cubit;

  const LabReportBottomSheet({
    super.key,
    required this.cubit,
  });

  static Future<void> show(BuildContext context, LabExperimentCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LabReportBottomSheet(cubit: cubit),
    );
  }

  @override
  State<LabReportBottomSheet> createState() => _LabReportBottomSheetState();
}

class _LabReportBottomSheetState extends State<LabReportBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.cubit.reportMistake(_controller.text);
    if (success && mounted) {
      AppRouter.pop(null, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: ColorsManager.primaryColor,
                  size: 22,
                ),
                horizontalSpace8,
                Text(
                  appTranslation().get('lab_report_mistake'),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: ColorsManager.secondaryText,
                  onPressed: () => AppRouter.pop(null, context),
                ),
              ],
            ),
            verticalSpace12,
            PrimaryTextField(
              controller: _controller,
              hint: appTranslation().get('lab_report_hint'),
              maxLines: 4,
              maxLength: 500,
            ),
            verticalSpace16,
            BlocBuilder<LabExperimentCubit, LabExperimentState>(
              buildWhen: (previous, current) =>
                  previous.isReporting != current.isReporting,
              builder: (context, state) {
                return PrimaryElevatedButton(
                  text: appTranslation().get('lab_report_submit'),
                  isLoading: state.isReporting,
                  onPressed: state.isReporting ? null : _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
