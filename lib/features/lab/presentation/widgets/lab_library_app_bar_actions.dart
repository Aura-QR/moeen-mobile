import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_create_experiment_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lab_request_experiment_sheet.dart';

/// «أنشئ تجربة» and «اطلب تجربة» entries of the library app bar.
class LabLibraryAppBarActions extends StatelessWidget {
  const LabLibraryAppBarActions({super.key});

  Future<void> _openCreateSheet(
    BuildContext context,
    LabLibraryCubit cubit,
  ) async {
    final created = await LabCreateExperimentSheet.show(
      context,
      lessonId: cubit.state.lessonId,
      lessonTitle: cubit.state.lessonTitle,
    );
    if (created != null && context.mounted) {
      cubit.load();
    }
  }

  void _openRequestSheet(BuildContext context, LabLibraryCubit cubit) {
    LabRequestExperimentSheet.show(
      context,
      lessonId: cubit.state.lessonId,
      lessonTitle: cubit.state.lessonTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = LabLibraryCubit.get(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: appTranslation().get('lab_create_experiment'),
          icon: Icon(
            Icons.add_circle_outline_rounded,
            color: ColorsManager.primaryColor,
          ),
          onPressed: () => _openCreateSheet(context, cubit),
        ),
        IconButton(
          tooltip: appTranslation().get('lab_request_experiment'),
          icon: Icon(
            Icons.lightbulb_outline_rounded,
            color: ColorsManager.primaryColor,
          ),
          onPressed: () => _openRequestSheet(context, cubit),
        ),
      ],
    );
  }
}
