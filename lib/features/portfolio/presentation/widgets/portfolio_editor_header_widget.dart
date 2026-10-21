import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_completion_ring_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_confirm_dialog.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_header_action_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_input_dialog.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_missing_chips_widget.dart';

class PortfolioEditorHeaderWidget extends StatelessWidget {
  final ValueChanged<String> onMissingTap;
  final VoidCallback onShareTap;

  const PortfolioEditorHeaderWidget({super.key, required this.onMissingTap, required this.onShareTap});

  Future<void> _rename(BuildContext context, String current) async {
    final cubit = PortfolioEditorCubit.get(context);
    final values = await PortfolioInputDialog.show(
      context,
      titleKey: 'portfolio_rename',
      fields: [PortfolioInputField(hintKey: 'portfolio_title_hint', initialValue: current)],
    );
    if (values != null) cubit.rename(values.first);
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final confirmed = await showPortfolioConfirmDialog(
      context,
      titleKey: 'portfolio_delete',
      messageKey: 'portfolio_delete_confirm',
    );
    if (confirmed) cubit.deletePortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
      buildWhen: (previous, current) =>
          previous.portfolio != current.portfolio || previous.isExporting != current.isExporting,
      builder: (context, state) {
        final portfolio = state.portfolio!;
        final completion = portfolio.completion;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PortfolioCompletionRingWidget(percent: completion.percent, size: 72),
                  horizontalSpace16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _rename(context, portfolio.title),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  portfolio.title,
                                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                                ),
                              ),
                              horizontalSpace6,
                              Icon(Icons.edit_outlined, size: 16, color: ColorsManager.secondaryText),
                            ],
                          ),
                        ),
                        verticalSpace4,
                        Text(
                          completion.missing.isEmpty
                              ? appTranslation().get('portfolio_complete')
                              : appTranslation()
                                  .get('portfolio_add_evidence_to')
                                  .replaceAll('{n}', '${completion.missing.length}'),
                          style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (completion.missing.isNotEmpty) ...[
                verticalSpace14,
                PortfolioMissingChipsWidget(missing: completion.missing, onTap: onMissingTap),
              ],
              verticalSpace16,
              Row(
                children: [
                  PortfolioHeaderActionWidget(
                    icon: Icons.picture_as_pdf_outlined,
                    label: appTranslation().get('portfolio_pdf'),
                    isLoading: state.isExporting,
                    onTap: PortfolioEditorCubit.get(context).exportPdf,
                  ),
                  horizontalSpace8,
                  PortfolioHeaderActionWidget(
                    icon: Icons.share_outlined,
                    label: appTranslation().get('portfolio_share'),
                    onTap: onShareTap,
                  ),
                  horizontalSpace8,
                  PortfolioHeaderActionWidget(
                    icon: Icons.delete_outline_rounded,
                    label: appTranslation().get('portfolio_delete'),
                    color: ColorsManager.errorColor,
                    onTap: () => _delete(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
