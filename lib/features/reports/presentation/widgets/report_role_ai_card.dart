import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_role_ai_optional_fields.dart';
import 'package:moean/features/reports/presentation/widgets/report_role_ai_status_banner.dart';

/// «✨ اكتب لي» box above the blocks on AI-enabled role documents (`ai: true`).
class ReportRoleAiCard extends StatelessWidget {
  const ReportRoleAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) =>
          previous.canUseAi != current.canUseAi ||
          previous.briefHint != current.briefHint ||
          previous.briefLength != current.briefLength ||
          previous.aiStatus != current.aiStatus ||
          previous.aiErrorMessage != current.aiErrorMessage ||
          previous.canUndoAi != current.canUndoAi,
      builder: (context, state) {
        if (!state.canUseAi) return const Offstage();
        final isWriting = state.isAiWriting;
        final canSubmit = !isWriting && cubit.briefController.text.trim().isNotEmpty;
        final hint = state.briefHint.isNotEmpty
            ? state.briefHint
            : appTranslation().get('role_ai_brief_hint');
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: PrimarySectionCard(
            icon: Icons.auto_awesome_outlined,
            title: appTranslation().get('role_ai_title'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryTextField(
                  controller: cubit.briefController,
                  hint: hint,
                  maxLines: 3,
                  maxLength: ReportEditorState.maxBriefChars,
                  enabled: !isWriting,
                ),
                verticalSpace6,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appTranslation().get('role_ai_privacy_note'),
                        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                      ),
                    ),
                    horizontalSpace8,
                    Text(
                      '${state.briefLength}/${ReportEditorState.maxBriefChars}',
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
                verticalSpace10,
                ReportRoleAiOptionalFields(enabled: !isWriting),
                verticalSpace12,
                PrimaryElevatedButton(
                  text: appTranslation().get(isWriting ? 'role_ai_writing' : 'role_ai_button'),
                  isLoading: isWriting,
                  onPressed: canSubmit ? cubit.writeWithAi : null,
                ),
                ReportRoleAiStatusBanner(
                  status: state.aiStatus,
                  errorMessage: state.aiErrorMessage,
                  canUndo: state.canUndoAi,
                  onUndo: cubit.undoAiMerge,
                  onRetry: cubit.retryWriteWithAi,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
