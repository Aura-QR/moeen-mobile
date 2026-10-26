import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// The report's «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز». Each saves first.
class ReportActionsBar extends StatelessWidget {
  const ReportActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isUploadingImage != current.isUploadingImage,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == ReportEditorStatus.success && !state.isUploadingImage,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
