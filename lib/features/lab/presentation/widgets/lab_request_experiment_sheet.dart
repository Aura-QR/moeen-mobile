import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lab_lesson_actions_cubit.dart';

/// Bottom sheet for «اطلب تجربة» (`POST /lab/requests`).
class LabRequestExperimentSheet extends StatefulWidget {
  final int? lessonId;
  final String? lessonTitle;

  const LabRequestExperimentSheet({
    super.key,
    this.lessonId,
    this.lessonTitle,
  });

  static Future<bool?> show(
    BuildContext context, {
    int? lessonId,
    String? lessonTitle,
    LabRepository? repository,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => LabLessonActionsCubit(
          labRepository: repository ?? LabRepository(),
        ),
        child: LabRequestExperimentSheet(
          lessonId: lessonId,
          lessonTitle: lessonTitle,
        ),
      ),
    );
  }

  @override
  State<LabRequestExperimentSheet> createState() =>
      _LabRequestExperimentSheetState();
}

class _LabRequestExperimentSheetState extends State<LabRequestExperimentSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = LabLessonActionsCubit.get(context);
    final success = await cubit.submitRequest(
      lessonId: widget.lessonId,
      message: _controller.text,
    );
    if (success && context.mounted) {
      AppRouter.pop(true, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lessonTitle?.trim() ?? '';

    return BlocConsumer<LabLessonActionsCubit, LabLessonActionsState>(
      listenWhen: (prev, curr) => prev.feedback != curr.feedback && curr.feedback != null,
      listener: (context, state) {
        final fb = state.feedback!;
        showPrimarySnackBar(
          context,
          appTranslation().get(fb.message),
          isError: fb.isError,
        );
      },
      buildWhen: (prev, curr) => prev.isSubmitting != curr.isSubmitting,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: ColorsManager.primaryColor,
                    size: 22,
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Text(
                      appTranslation().get('lab_request_experiment'),
                      style: TextStylesManager.bold16.copyWith(
                        color: ColorsManager.mainText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: ColorsManager.secondaryText,
                    onPressed: () => AppRouter.pop(false, context),
                  ),
                ],
              ),
              if (title.isNotEmpty) ...[
                verticalSpace8,
                Text(
                  title,
                  style: TextStylesManager.medium13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ],
              verticalSpace12,
              PrimaryTextField(
                controller: _controller,
                hint: appTranslation().get('lab_request_hint'),
                maxLines: 4,
                maxLength: 500,
              ),
              verticalSpace16,
              PrimaryElevatedButton(
                text: appTranslation().get('lab_request_submit'),
                isLoading: state.isSubmitting,
                onPressed: state.isSubmitting ? null : () => _submit(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
