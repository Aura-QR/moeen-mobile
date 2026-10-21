import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_editor_body.dart';
import 'package:printing/printing.dart';

class PortfolioEditorScreen extends StatelessWidget {
  const PortfolioEditorScreen({super.key});

  void _onEvent(BuildContext context, PortfolioEditorState state) {
    if (state.deleted) {
      Navigator.pop(context);
    } else if (state.pdfBytes != null) {
      final bytes = state.pdfBytes!;
      Printing.layoutPdf(onLayout: (_) async => bytes, name: '${state.portfolio?.title ?? 'portfolio'}.pdf');
    } else if (state.feedback != null) {
      showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('portfolio_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<PortfolioEditorCubit, PortfolioEditorState>(
        listenWhen: (_, current) => current.deleted || current.pdfBytes != null || current.feedback != null,
        listener: _onEvent,
        // The body rebuilds its own parts; this only switches load states.
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == PortfolioEditorStatus.loading,
          errorState: state.status == PortfolioEditorStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: PortfolioEditorCubit.get(context).load,
          ),
          successBuilder: (_) => const PortfolioEditorBody(),
        ),
      ),
    );
  }
}
