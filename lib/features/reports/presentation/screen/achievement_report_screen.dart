import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/achievement_report_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_period_selector_widget.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_range_navigator_widget.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_report_content_widget.dart';
import 'package:printing/printing.dart';

class AchievementReportScreen extends StatelessWidget {
  const AchievementReportScreen({super.key});

  void _onEvent(BuildContext context, AchievementReportState state) {
    if (state.pdfBytes != null) {
      final bytes = state.pdfBytes!;
      Printing.sharePdf(bytes: bytes, filename: '${appTranslation().get('achievement_report_title')}.pdf');
    } else if (state.feedback != null) {
      showPrimarySnackBar(context, state.feedback!);
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
          appTranslation().get('achievement_report_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocListener<AchievementReportCubit, AchievementReportState>(
        listenWhen: (_, current) => current.pdfBytes != null || current.feedback != null,
        listener: _onEvent,
        child: RefreshIndicator(
          onRefresh: AchievementReportCubit.get(context).load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const AchievementPeriodSelectorWidget(),
              verticalSpace12,
              const AchievementRangeNavigatorWidget(),
              verticalSpace16,
              BlocBuilder<AchievementReportCubit, AchievementReportState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status || previous.report != current.report,
                builder: (context, state) => ConditionalBuilder(
                  loadingState: state.status == AchievementReportStatus.loading,
                  errorState: state.status == AchievementReportStatus.failure || state.report == null,
                  loadingBuilder: (_) => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorBuilder: (_) => Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: PrimaryErrorView(
                      message: state.errorMessage ?? 'generic_error',
                      onRetry: AchievementReportCubit.get(context).load,
                    ),
                  ),
                  successBuilder: (_) => AchievementReportContentWidget(report: state.report!),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BlocBuilder<AchievementReportCubit, AchievementReportState>(
          buildWhen: (previous, current) =>
              previous.isExporting != current.isExporting || previous.report != current.report,
          builder: (context, state) => PrimaryElevatedButton(
            text: appTranslation().get('achievement_share_pdf'),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
            isLoading: state.isExporting,
            onPressed: state.report == null ? null : AchievementReportCubit.get(context).exportPdf,
          ),
        ),
      ),
    );
  }
}
