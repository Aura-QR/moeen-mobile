import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_field_label.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/new_learning_style_cubit.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_styles_version_preview.dart';
import 'package:moean/features/learning_styles/presentation/widgets/new_learning_style_classes_section.dart';

/// «استبانة جديدة»: title, version, classes, and a statements preview.
class NewLearningStyleScreen extends StatefulWidget {
  const NewLearningStyleScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => NewLearningStyleCubit(
          repository: LearningStylesRepository(),
          classes: ClassesRepository(),
        )
          ..loadOptions()
          ..loadClasses(),
        child: const NewLearningStyleScreen(),
      );

  @override
  State<NewLearningStyleScreen> createState() => _NewLearningStyleScreenState();
}

class _NewLearningStyleScreenState extends State<NewLearningStyleScreen> {
  final TextEditingController _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _listen(BuildContext context, NewLearningStyleState state) {
    if (state.error != null) {
      showPrimarySnackBar(context, state.error!);
      NewLearningStyleCubit.get(context).clearError();
    }
    if (state.createdId != null) {
      Navigator.pushReplacementNamed(context, Routes.learningStyle, arguments: state.createdId);
    }
  }

  String _versionLabel(NewLearningStyleState state, String key) =>
      state.options?.version(key)?.label ?? appTranslation().get('learning_styles_version_$key');

  @override
  Widget build(BuildContext context) {
    final cubit = NewLearningStyleCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('learning_styles_new'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<NewLearningStyleCubit, NewLearningStyleState>(
        listenWhen: (a, b) => a.error != b.error || a.createdId != b.createdId,
        listener: _listen,
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PrimarySectionCard(
              icon: Icons.edit_outlined,
              title: appTranslation().get('learning_styles_details'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryTextField(
                    controller: _title,
                    hint: appTranslation().get('learning_styles_title_hint'),
                    maxLength: LearningStylesLimits.maxTitleLength,
                  ),
                  verticalSpace16,
                  PrimaryFieldLabel(textKey: 'learning_styles_version'),
                  verticalSpace8,
                  PrimaryChoiceChips<String>(
                    options: LearningStyleVersions.all,
                    labelOf: (v) => _versionLabel(state, v),
                    isSelected: (v) => v == state.version,
                    onTap: cubit.setVersion,
                  ),
                ],
              ),
            ),
            verticalSpace12,
            const NewLearningStyleClassesSection(),
            verticalSpace12,
            const LearningStylesVersionPreview(),
            verticalSpace24,
            PrimaryElevatedButton(
              text: appTranslation().get('learning_styles_create'),
              isLoading: state.isSaving,
              onPressed: state.canStart ? () => cubit.submit(_title.text) : null,
            ),
            verticalSpace32,
          ],
        ),
      ),
    );
  }
}
