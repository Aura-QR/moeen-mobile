import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';

/// «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز». Each saves first.
class StrategyActionsBar extends StatelessWidget {
  const StrategyActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = StrategyDocumentationCubit.get(context);
    return BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isUploadingImage != current.isUploadingImage,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == StrategyDocumentationStatus.success && !state.isSaving && !state.isUploadingImage,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
