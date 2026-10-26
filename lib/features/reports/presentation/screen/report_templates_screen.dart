import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/reports/presentation/cubit/report_templates_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_template_card.dart';

/// T8: pick a template («تقرير فارغ» first), or reopen a saved report.
/// Needs a [ReportTemplatesCubit] above it.
class ReportTemplatesScreen extends StatelessWidget {
  const ReportTemplatesScreen({super.key});

  /// [argument] is a template key (String) or a saved report's id (int).
  Future<void> _open(BuildContext context, Object argument) async {
    final cubit = ReportTemplatesCubit.get(context);
    await Navigator.pushNamed(context, Routes.reportEditor, arguments: argument);
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportTemplatesCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(DocumentTypes.labelKey(DocumentTypes.report)),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocBuilder<ReportTemplatesCubit, ReportTemplatesState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.catalogue != current.catalogue || previous.saved != current.saved,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == ReportTemplatesStatus.loading,
          errorState: state.status == ReportTemplatesStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
          successBuilder: (_) => RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  appTranslation().get('report_templates'),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace10,
                for (final template in state.catalogue?.templates ?? const [])
                  ReportTemplateCard(
                    icon: Icons.description_outlined,
                    title: template.label,
                    subtitle: template.description,
                    onTap: () => _open(context, template.key),
                  ),
                if (state.saved.isNotEmpty) ...[
                  verticalSpace14,
                  Text(
                    appTranslation().get('report_saved'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                  ),
                  verticalSpace10,
                  for (final document in state.saved)
                    ReportTemplateCard(
                      icon: Icons.summarize_outlined,
                      title: document.title,
                      subtitle: document.updatedAt == null
                          ? ''
                          : appTranslation()
                              .get('document_last_edited')
                              .replaceAll('{date}', isoDate(document.updatedAt!.toLocal())),
                      onTap: () => _open(context, document.id),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
