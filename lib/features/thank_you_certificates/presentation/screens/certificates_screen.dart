import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_actions_bar.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificates_body.dart';
import 'package:moean/features/classes/presentation/widgets/class_import_review_sheet.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

/// T3 «شهادات شكر». Needs a [CertificatesCubit] and a [DocumentPreviewCubit] above it.
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  Future<void> _onEvent(BuildContext context, CertificatesState state) async {
    final cubit = CertificatesCubit.get(context);
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final imported = state.importedNames;
    if (imported != null) {
      final confirmed = await ClassImportReviewSheet.show(context, imported);
      if (confirmed) cubit.addImportedNames(imported);
      return;
    }

    final documentId = state.documentId;
    if (documentId == null || !context.mounted) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: DocumentTypes.certificates,
      portfolioItemKey: cubit.portfolioItemKey,
    );
  }

  void _refreshPreview(BuildContext context) {
    final input = CertificatesCubit.get(
      context,
    ).previewInput(fallbackName: appTranslation().get('certificates_sample_name'));
    if (input != null) DocumentPreviewCubit.get(context).schedule(input);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(DocumentTypes.labelKey(DocumentTypes.certificates)),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocListener<CertificatesCubit, CertificatesState>(
        listenWhen: (previous, current) => previous.revision != current.revision,
        listener: (context, _) => _refreshPreview(context),
        child: BlocConsumer<CertificatesCubit, CertificatesState>(
          listenWhen: (_, current) =>
              current.feedback != null || current.followUp != null || current.importedNames != null,
          listener: _onEvent,
          // Sections rebuild their own parts; this only switches load states.
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => ConditionalBuilder(
            loadingState: state.status == CertificatesStatus.loading,
            errorState: state.status == CertificatesStatus.failure,
            errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
            successBuilder: (_) => const CertificatesBody(),
          ),
        ),
      ),
      bottomNavigationBar: const CertificatesActionsBar(),
    );
  }
}
