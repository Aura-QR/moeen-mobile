import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_plan_actions_bar.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_plan_body.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

/// T5 «خطة النشاط الطلابي».
class ActivitiesPlanScreen extends StatelessWidget {
  const ActivitiesPlanScreen({super.key});

  Future<void> _onEvent(BuildContext context, ActivitiesPlanState state) async {
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final documentId = state.documentId;
    if (documentId == null) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      portfolioItemKey: ActivitiesPlanCubit.portfolioItemKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(DocumentTypes.labelKey(DocumentTypes.activitiesPlan)),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<ActivitiesPlanCubit, ActivitiesPlanState>(
        listenWhen: (_, current) => current.feedback != null || current.followUp != null,
        listener: _onEvent,
        // Sections rebuild their own parts; this only switches load states.
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == ActivitiesPlanStatus.loading,
          errorState: state.status == ActivitiesPlanStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
          successBuilder: (_) => const ActivitiesPlanBody(),
        ),
      ),
      bottomNavigationBar: const ActivitiesPlanActionsBar(),
    );
  }
}
