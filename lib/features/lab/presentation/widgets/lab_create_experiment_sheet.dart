import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lab_lesson_actions_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_create_experiment_form_fields.dart';
import 'package:moean/features/lab/presentation/widgets/lab_create_experiment_success_view.dart';
import 'package:moean/features/lab/presentation/widgets/lab_reading_card_widget.dart';
import 'package:moean/features/lab/presentation/widgets/lab_variable_card_widget.dart';

/// Bottom sheet for «أنشئ تجربتك» (`POST /lab/experiments`).
class LabCreateExperimentSheet extends StatefulWidget {
  final int? lessonId;
  final String? lessonTitle;

  const LabCreateExperimentSheet({super.key, this.lessonId, this.lessonTitle});

  static Future<LabExperimentModel?> show(
    BuildContext context, {
    int? lessonId,
    String? lessonTitle,
    LabRepository? repository,
  }) =>
      showModalBottomSheet<LabExperimentModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: ColorsManager.surfacePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => BlocProvider(
          create: (_) => LabLessonActionsCubit(labRepository: repository ?? LabRepository()),
          child: LabCreateExperimentSheet(lessonId: lessonId, lessonTitle: lessonTitle),
        ),
      );

  @override
  State<LabCreateExperimentSheet> createState() => _LabCreateExperimentSheetState();
}

class _LabCreateExperimentSheetState extends State<LabCreateExperimentSheet> {
  final _nameCtrl = TextEditingController();
  final _observeCtrl = TextEditingController();
  final _variables = <LabVariableFormControllers>[LabVariableFormControllers()];
  final _readings = <LabReadingFormControllers>[LabReadingFormControllers()];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _observeCtrl.dispose();
    for (final v in _variables) {
      v.dispose();
    }
    for (final r in _readings) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context, String displayMode) =>
      LabLessonActionsCubit.get(context).submitCreateExperiment(
        LabCreateExperimentInput(
          name: _nameCtrl.text,
          display: displayMode,
          observe: _observeCtrl.text,
          lessonId: widget.lessonId,
          variables: [
            for (var i = 0; i < _variables.length; i++)
              _variables[i].toInput(kLabVariableSymbols[i]),
          ],
          readings: [for (final r in _readings) r.toInput()],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = widget.lessonTitle?.trim() ?? '';
    return BlocConsumer<LabLessonActionsCubit, LabLessonActionsState>(
      listenWhen: (p, c) => p.feedback != c.feedback && c.feedback != null && c.feedback!.isError,
      listener: (context, state) => showPrimarySnackBar(
        context,
        appTranslation().get(state.feedback!.message),
        isError: true,
      ),
      buildWhen: (p, c) =>
          p.isSubmitting != c.isSubmitting ||
          p.displayMode != c.displayMode ||
          p.variablesCount != c.variablesCount ||
          p.readingsCount != c.readingsCount ||
          p.createdExperiment != c.createdExperiment,
      builder: (context, state) {
        final cubit = LabLessonActionsCubit.get(context);
        final created = state.createdExperiment;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: created != null
                ? LabCreateExperimentSuccessView(experiment: created)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: ColorsManager.primaryColor),
                          horizontalSpace8,
                          Expanded(
                            child: Text(
                              appTranslation().get('lab_create_experiment'),
                              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: ColorsManager.secondaryText,
                            onPressed: () => AppRouter.pop(null, context),
                          ),
                        ],
                      ),
                      if (title.isNotEmpty) ...[
                        verticalSpace4,
                        Text(title, style: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor)),
                      ],
                      verticalSpace12,
                      LabCreateExperimentFormFields(
                        nameController: _nameCtrl,
                        observeController: _observeCtrl,
                        variables: _variables,
                        readings: _readings,
                        displayMode: state.displayMode,
                        onDisplayModeChanged: cubit.selectDisplayMode,
                        onAddVariable: () => cubit.setVariablesCount((_variables..add(LabVariableFormControllers())).length),
                        onRemoveVariable: (i) => cubit.setVariablesCount((_variables..removeAt(i).dispose()).length),
                        onAddReading: () => cubit.setReadingsCount((_readings..add(LabReadingFormControllers())).length),
                        onRemoveReading: (i) => cubit.setReadingsCount((_readings..removeAt(i).dispose()).length),
                      ),
                      verticalSpace16,
                      PrimaryElevatedButton(
                        text: appTranslation().get('lab_create_submit'),
                        isLoading: state.isSubmitting,
                        onPressed: state.isSubmitting ? null : () => _submit(context, state.displayMode),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
