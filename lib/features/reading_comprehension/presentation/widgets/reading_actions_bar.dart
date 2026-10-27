import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';

/// Bottom bar: «شارك إلكترونيًا», then «حفظ» / «تصدير» / «إضافة إلى ملف الإنجاز».
class ReadingActionsBar extends StatelessWidget {
  const ReadingActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
      buildWhen: (p, c) => p.status != c.status || p.isSaving != c.isSaving || p.isSharing != c.isSharing,
      builder: (context, state) {
        final enabled = state.status == ReadingEditorStatus.success && !state.isSaving && !state.isSharing;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: ColorsManager.surfacePrimary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: enabled ? cubit.share : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(color: ColorsManager.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: state.isSharing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.qr_code_2_outlined, size: 20, color: ColorsManager.primaryColor),
                  label: Text(
                    appTranslation().get('reading_share_online'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
              ),
            ),
            DocumentActionsBar(
              enabled: enabled,
              isSaving: state.isSaving,
              onSave: cubit.save,
              onExport: cubit.saveAndExport,
              onAttach: cubit.saveAndAttach,
            ),
          ],
        );
      },
    );
  }
}
