import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/reports/data/models/role_report_editor_args.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_documents_cubit.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_documents_body.dart';
import 'package:moean/features/thank_you_certificates/data/models/role_certificate_prefill.dart';

/// L1 `/tools/roles/{role}`: shows categories, filter/search, and opens documents in T8 or T3.
class RoleDocumentsScreen extends StatelessWidget {
  const RoleDocumentsScreen({super.key});

  void _onEvent(BuildContext context, RoleDocumentsState state) {
    final feedback = state.feedback;
    if (feedback != null) {
      showPrimarySnackBar(context, feedback.message, isError: feedback.isError);
    }
    final opened = state.openedTemplate;
    if (opened == null) return;
    if (opened.type == DocumentTypes.certificates) {
      AppRouter.push(
        AppRouter.thankYouCertificates,
        arguments: RoleCertificatePrefill(input: opened.input, element: opened.element),
        context: context,
      );
      return;
    }
    AppRouter.push(
      AppRouter.reportEditor,
      arguments: RoleReportEditorArgs.fromTemplate(opened),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = RoleDocumentsCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: BlocBuilder<RoleDocumentsCubit, RoleDocumentsState>(
          buildWhen: (previous, current) => previous.roleLabel != current.roleLabel,
          builder: (_, state) => Text(
            state.roleLabel.isNotEmpty
                ? state.roleLabel
                : appTranslation().get('role_suites_title'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ),
      body: BlocConsumer<RoleDocumentsCubit, RoleDocumentsState>(
        listenWhen: (_, current) => current.feedback != null || current.openedTemplate != null,
        listener: _onEvent,
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == RoleDocumentsStatus.loading,
          errorState: state.status == RoleDocumentsStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: cubit.load,
          ),
          successBuilder: (_) => const RoleDocumentsBody(),
        ),
      ),
    );
  }
}
