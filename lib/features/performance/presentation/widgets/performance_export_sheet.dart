import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_picker.dart';
import 'package:moean/features/performance/presentation/cubit/performance_export_cubit.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

/// The export options. Pops with the refreshed file's id, then the usual
/// PDF / Word sheet opens for it.
class PerformanceExportSheet extends StatelessWidget {
  const PerformanceExportSheet({super.key});

  static Future<void> show(BuildContext context, {required int portfolioId}) async {
    final documentId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => PerformanceExportCubit(portfolioId: portfolioId, repository: PortfolioRepository()),
        child: const PerformanceExportSheet(),
      ),
    );
    if (documentId == null || !context.mounted) return;
    await DocumentExportSheet.show(context, documentId: documentId, withElement: false);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PerformanceExportCubit.get(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: BlocConsumer<PerformanceExportCubit, PerformanceExportState>(
          listenWhen: (_, current) => current.documentId != null || current.errorMessage != null,
          listener: (context, state) {
            if (state.documentId != null) {
              Navigator.pop(context, state.documentId);
            } else {
              showPrimarySnackBar(context, state.errorMessage!);
            }
          },
          buildWhen: (previous, current) =>
              previous.includeRatings != current.includeRatings ||
              previous.theme != current.theme ||
              previous.isExporting != current.isExporting,
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('performance_export'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace12,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.includeRatings,
                activeThumbColor: ColorsManager.primaryColor,
                onChanged: cubit.setIncludeRatings,
                title: Text(
                  appTranslation().get('performance_export_include_ratings'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
              ),
              verticalSpace8,
              DocumentThemePicker(selected: state.theme, onChanged: cubit.setTheme),
              verticalSpace16,
              PrimaryElevatedButton(
                text: appTranslation().get('performance_export_button'),
                isLoading: state.isExporting,
                onPressed: cubit.export,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
