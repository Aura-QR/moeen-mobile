import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// The report's «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز». Each saves first.
class GradeAnalysisActionsBar extends StatelessWidget {
  const GradeAnalysisActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isBusy != current.isBusy,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == GradeAnalysisStatus.success && !state.isBusy,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
