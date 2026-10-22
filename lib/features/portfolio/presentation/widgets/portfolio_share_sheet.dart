import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_share_link_widget.dart';

class PortfolioShareSheet extends StatelessWidget {
  const PortfolioShareSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = PortfolioEditorCubit.get(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(value: cubit, child: const PortfolioShareSheet()),
    );
  }

  /// Stopping retires the token, so the current link stops working for good.
  Future<void> _stop(BuildContext context) async {
    final cubit = PortfolioEditorCubit.get(context);
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'portfolio_stop_sharing',
      messageKey: 'portfolio_stop_sharing_warning',
      confirmKey: 'portfolio_stop_sharing',
    );
    if (confirmed) cubit.disableShare();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
          buildWhen: (previous, current) =>
              previous.portfolio?.shareUrl != current.portfolio?.shareUrl ||
              previous.isSharing != current.isSharing,
          builder: (context, state) {
            final url = state.portfolio?.isPublic == true ? state.portfolio?.shareUrl : null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('portfolio_share'),
                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace16,
                if (url == null || url.isEmpty)
                  PrimaryElevatedButton(
                    text: appTranslation().get('portfolio_create_share_link'),
                    icon: const Icon(Icons.link_rounded, size: 20),
                    isLoading: state.isSharing,
                    onPressed: PortfolioEditorCubit.get(context).enableShare,
                  )
                else ...[
                  PortfolioShareLinkWidget(url: url),
                  verticalSpace8,
                  TextButton.icon(
                    onPressed: state.isSharing ? null : () => _stop(context),
                    style: TextButton.styleFrom(foregroundColor: ColorsManager.errorColor),
                    icon: const Icon(Icons.link_off_rounded),
                    label: Text(appTranslation().get('portfolio_stop_sharing')),
                  ),
                ],
                verticalSpace12,
                Text(
                  appTranslation().get('portfolio_share_note'),
                  textAlign: TextAlign.center,
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
