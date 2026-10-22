import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/presentation/cubit/document_defaults_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_defaults_body.dart';

/// F2 «بيانات الترويسة». Pops with true after a save.
class DocumentDefaultsScreen extends StatelessWidget {
  const DocumentDefaultsScreen({super.key});

  void _onEvent(BuildContext context, DocumentDefaultsState state) {
    if (state.saved) {
      showPrimarySnackBar(context, 'document_defaults_saved', isError: false);
      Navigator.pop(context, true);
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
          appTranslation().get('document_defaults_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<DocumentDefaultsCubit, DocumentDefaultsState>(
        listenWhen: (_, current) => current.saved || current.feedback != null,
        listener: _onEvent,
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == DocumentDefaultsStatus.loading,
          errorState: state.status == DocumentDefaultsStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: DocumentDefaultsCubit.get(context).load,
          ),
          successBuilder: (_) => const DocumentDefaultsBody(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BlocBuilder<DocumentDefaultsCubit, DocumentDefaultsState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.isSaving != current.isSaving ||
              previous.uploadingSlot != current.uploadingSlot,
          builder: (context, state) => PrimaryElevatedButton(
            text: appTranslation().get('save'),
            icon: const Icon(Icons.check_rounded),
            isLoading: state.isSaving,
            onPressed: state.status == DocumentDefaultsStatus.success && state.uploadingSlot == null
                ? DocumentDefaultsCubit.get(context).save
                : null,
          ),
        ),
      ),
    );
  }
}
