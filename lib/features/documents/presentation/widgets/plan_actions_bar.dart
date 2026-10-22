import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';

/// The plan's «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز». Each saves first.
class PlanActionsBar extends StatelessWidget {
  const PlanActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isUploadingImage != current.isUploadingImage,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == PlanFormStatus.success && !state.isSaving && !state.isUploadingImage,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
