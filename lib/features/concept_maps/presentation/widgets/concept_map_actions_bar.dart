import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';

/// Bottom actions bar: «حفظ», «تصدير» (PDF / Word / Image / Print), «إضافة إلى ملف الإنجاز».
class ConceptMapActionsBar extends StatelessWidget {
  const ConceptMapActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving,
      builder: (context, state) => DocumentActionsBar(
        enabled:
            state.status == ConceptMapEditorStatus.success && !state.isSaving,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
