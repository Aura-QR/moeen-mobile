import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';

/// Bottom actions bar: «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز».
class OutcomesMapActionsBar extends StatelessWidget {
  const OutcomesMapActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isAiBusy != current.isAiBusy,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == OutcomesMapEditorStatus.success &&
            !state.isSaving &&
            !state.isAiBusy,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
