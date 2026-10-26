import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// Top notice shown when editing a sensitive role form (`sensitive: true`).
class ReportSensitiveBanner extends StatelessWidget {
  const ReportSensitiveBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) => previous.isSensitive != current.isSensitive,
      builder: (context, state) {
        if (!state.isSensitive) return const Offstage();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorsManager.statusWarning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.statusWarning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.print_outlined, color: ColorsManager.statusWarning, size: 22),
                horizontalSpace10,
                Expanded(
                  child: Text(
                    appTranslation().get('role_sensitive_banner'),
                    style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
