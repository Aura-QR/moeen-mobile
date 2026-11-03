import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lesson_experiments_chip_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_create_experiment_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lab_request_experiment_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lesson_experiments_chip.dart';
import 'package:moean/features/lab/presentation/widgets/lesson_lab_action_chip.dart';

/// Fetches `GET /lessons/{id}/experiments` when [lessonId] is selected and
/// displays lesson-level Virtual Lab actions:
/// - View lesson experiments ([LessonExperimentsChip] when count > 0, or action chip)
/// - «أنشئ تجربة» ([LabCreateExperimentSheet])
/// - «اطلب تجربة» ([LabRequestExperimentSheet])
class LessonExperimentsLoaderChip extends StatelessWidget {
  final int? lessonId;
  final String? lessonTitle;
  final EdgeInsetsGeometry? padding;
  final LabRepository? repository;

  const LessonExperimentsLoaderChip({
    super.key,
    required this.lessonId,
    this.lessonTitle,
    this.padding,
    this.repository,
  });

  Future<void> _onCreateTap(BuildContext context, int id) async {
    final created = await LabCreateExperimentSheet.show(
      context,
      lessonId: id,
      lessonTitle: lessonTitle,
      repository: repository,
    );
    if (created != null && context.mounted) {
      LessonExperimentsChipCubit.get(context).loadForLesson(id);
    }
  }

  void _onRequestTap(BuildContext context, int id) {
    LabRequestExperimentSheet.show(
      context,
      lessonId: id,
      lessonTitle: lessonTitle,
      repository: repository,
    );
  }

  void _onViewExperimentsTap(BuildContext context, int id) {
    AppRouter.push(
      Routes.labLibrary,
      arguments: LabLibraryArgs(lessonId: id, lessonTitle: lessonTitle),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = lessonId;
    if (id == null || id <= 0) return const SizedBox.shrink();

    return BlocProvider<LessonExperimentsChipCubit>(
      key: ValueKey<int>(id),
      create: (_) => LessonExperimentsChipCubit(
        labRepository: repository ?? LabRepository(),
      )..loadForLesson(id),
      child: BlocBuilder<LessonExperimentsChipCubit, LessonExperimentsChipState>(
        buildWhen: (prev, curr) =>
            prev.count != curr.count ||
            prev.lessonId != curr.lessonId ||
            prev.isLoading != curr.isLoading,
        builder: (context, state) {
          final content = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (state.count > 0)
                LessonExperimentsChip(
                  count: state.count,
                  lessonId: id,
                  lessonTitle: lessonTitle,
                )
              else if (!state.isLoading)
                LessonLabActionChip(
                  icon: Icons.science_outlined,
                  label: appTranslation().get('lab_view_lesson_experiments'),
                  isPrimary: true,
                  onTap: () => _onViewExperimentsTap(context, id),
                ),
              LessonLabActionChip(
                icon: Icons.add_circle_outline_rounded,
                label: appTranslation().get('lab_create_experiment'),
                onTap: () => _onCreateTap(context, id),
              ),
              LessonLabActionChip(
                icon: Icons.lightbulb_outline_rounded,
                label: appTranslation().get('lab_request_experiment'),
                onTap: () => _onRequestTap(context, id),
              ),
            ],
          );

          if (padding == null) return content;
          return Padding(padding: padding!, child: content);
        },
      ),
    );
  }
}
