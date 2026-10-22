import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';

/// The certificates' «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز». Each saves first.
class CertificatesActionsBar extends StatelessWidget {
  const CertificatesActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSaving != current.isSaving ||
          previous.isImporting != current.isImporting,
      builder: (context, state) => DocumentActionsBar(
        enabled: state.status == CertificatesStatus.success && !state.isSaving && !state.isImporting,
        isSaving: state.isSaving,
        onSave: cubit.save,
        onExport: cubit.saveAndExport,
        onAttach: cubit.saveAndAttach,
      ),
    );
  }
}
