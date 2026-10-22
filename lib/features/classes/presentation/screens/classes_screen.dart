import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/presentation/cubit/classes_cubit.dart';
import 'package:moean/features/classes/presentation/widgets/madrasati_import_sheet.dart';
import 'package:moean/features/classes/presentation/widgets/classes_list.dart';

/// F7 «فصولي».
class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  /// Opens the editor ([classId] null for a new class) and reloads after a save.
  Future<void> _openEditor(BuildContext context, {int? classId}) async {
    final cubit = ClassesCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.classEditor, arguments: classId);
    if (saved == true) cubit.load();
  }

  void _add(BuildContext context, ClassesState state) {
    if (state.isFull) {
      showPrimarySnackBar(context, 'classes_limit');
      return;
    }
    _openEditor(context);
  }

  Future<void> _importFromMadrasati(BuildContext context) async {
    final cubit = ClassesCubit.get(context);
    final saved = await MadrasatiImportSheet.show(context, ClassesRepository());
    if (saved) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClassesCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('classes_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        actions: [
          IconButton(
            tooltip: appTranslation().get('classes_madrasati_title'),
            icon: Icon(Icons.cloud_download_outlined, color: ColorsManager.primaryColor),
            onPressed: () => _importFromMadrasati(context),
          ),
        ],
      ),
      body: BlocConsumer<ClassesCubit, ClassesState>(
        listenWhen: (_, current) => current.feedback != null,
        listener: (context, state) =>
            showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError),
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.classes.isEmpty != current.classes.isEmpty,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == ClassesStatus.loading,
          errorState: state.status == ClassesStatus.failure,
          emptyState: state.classes.isEmpty,
          errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
          emptyBuilder: (_) => NoDataWidget(
            icon: Icons.groups_2_outlined,
            title: appTranslation().get('classes_empty_title'),
            subtitle: appTranslation().get('classes_empty_subtitle'),
          ),
          successBuilder: (_) => ClassesList(
            onOpen: (schoolClass) => _openEditor(context, classId: schoolClass.id),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BlocBuilder<ClassesCubit, ClassesState>(
          buildWhen: (previous, current) => previous.isFull != current.isFull,
          builder: (context, state) => PrimaryElevatedButton(
            text: appTranslation().get('class_add'),
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _add(context, state),
          ),
        ),
      ),
    );
  }
}
