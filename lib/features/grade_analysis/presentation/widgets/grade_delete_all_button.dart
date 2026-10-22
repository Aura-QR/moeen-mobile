import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// «حذف كل بيانات التحليل», after a confirmation: every saved report and its grades.
class GradeDeleteAllButton extends StatelessWidget {
  const GradeDeleteAllButton({super.key});

  Future<void> _confirm(BuildContext context) async {
    final cubit = GradeAnalysisCubit.get(context);
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'grades_delete_all',
      messageKey: 'grades_delete_all_confirm',
    );
    if (confirmed) cubit.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GradeAnalysisCubit, GradeAnalysisState, bool>(
      selector: (state) => state.isDeletingAll,
      builder: (context, isDeleting) => IconButton(
        tooltip: appTranslation().get('grades_delete_all'),
        onPressed: isDeleting ? null : () => _confirm(context),
        icon: isDeleting
            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.delete_sweep_outlined, color: ColorsManager.errorColor),
      ),
    );
  }
}
