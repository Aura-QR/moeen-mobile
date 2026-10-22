import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/presentation/cubit/classes_cubit.dart';
import 'package:moean/features/classes/presentation/widgets/class_card_widget.dart';

/// The saved classes. Swipe or use the menu to delete.
class ClassesList extends StatelessWidget {
  final ValueChanged<SchoolClassModel> onOpen;

  const ClassesList({super.key, required this.onOpen});

  Future<bool> _confirmDelete(BuildContext context) => showPrimaryConfirmDialog(
        context,
        titleKey: 'class_delete',
        messageKey: 'class_delete_confirm',
      );

  /// Deletes through the cubit and returns false: the row leaves when the
  /// list updates, and stays if the delete fails.
  Future<bool> _swipeDelete(BuildContext context, SchoolClassModel schoolClass) async {
    final cubit = ClassesCubit.get(context);
    if (await _confirmDelete(context)) await cubit.delete(schoolClass);
    return false;
  }

  Future<void> _onAction(BuildContext context, SchoolClassModel schoolClass, ClassCardAction action) async {
    final cubit = ClassesCubit.get(context);
    if (action == ClassCardAction.printSheet) {
      Navigator.pushNamed(context, Routes.classSheets, arguments: schoolClass);
    } else if (action == ClassCardAction.edit) {
      onOpen(schoolClass);
    } else if (await _confirmDelete(context)) {
      await cubit.delete(schoolClass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClassesCubit.get(context);
    return BlocBuilder<ClassesCubit, ClassesState>(
      buildWhen: (previous, current) => previous.classes != current.classes || previous.busyId != current.busyId,
      builder: (context, state) => RefreshIndicator(
        onRefresh: cubit.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          itemCount: state.classes.length,
          separatorBuilder: (_, _) => verticalSpace10,
          itemBuilder: (context, index) {
            final schoolClass = state.classes[index];
            return Dismissible(
              key: ValueKey(schoolClass.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _swipeDelete(context, schoolClass),
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: ColorsManager.errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: ColorsManager.errorColor),
              ),
              child: ClassCardWidget(
                schoolClass: schoolClass,
                isBusy: state.busyId == schoolClass.id,
                onTap: () => onOpen(schoolClass),
                onAction: (action) => _onAction(context, schoolClass, action),
              ),
            );
          },
        ),
      ),
    );
  }
}
