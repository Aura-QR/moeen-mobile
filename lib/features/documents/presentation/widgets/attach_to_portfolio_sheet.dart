import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/attach_to_portfolio_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/attach_to_portfolio_body.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

/// «إضافة إلى ملف الإنجاز». Pops with true once attached.
class AttachToPortfolioSheet extends StatelessWidget {
  const AttachToPortfolioSheet({super.key});

  static Future<bool> show(
    BuildContext context, {
    required int documentId,
    String? suggestedItemKey,
  }) async {
    final attached = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => AttachToPortfolioCubit(
          documentId: documentId,
          suggestedItemKey: suggestedItemKey,
          repository: PortfolioRepository(),
        )..load(),
        child: const AttachToPortfolioSheet(),
      ),
    );
    return attached ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('document_attach_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace16,
              BlocConsumer<AttachToPortfolioCubit, AttachToPortfolioState>(
                listenWhen: (_, current) => current.attached || current.feedback != null,
                listener: (context, state) {
                  if (state.attached) {
                    Navigator.pop(context, true);
                  } else {
                    showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError);
                  }
                },
                buildWhen: (previous, current) => previous.status != current.status,
                builder: (context, state) => ConditionalBuilder(
                  loadingState: state.status == AttachToPortfolioStatus.loading,
                  errorState: state.status == AttachToPortfolioStatus.failure,
                  emptyState: state.portfolios.isEmpty,
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: AttachToPortfolioCubit.get(context).load,
                  ),
                  emptyBuilder: (_) => NoDataWidget(
                    icon: Icons.workspace_premium_outlined,
                    title: appTranslation().get('portfolio_empty_title'),
                    subtitle: appTranslation().get('document_attach_no_portfolio'),
                  ),
                  successBuilder: (_) => const AttachToPortfolioBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
