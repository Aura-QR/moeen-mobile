import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';
import 'package:moean/features/online_tests/presentation/cubit/create_online_test_cubit.dart';

/// «شارك إلكترونيًا»: title, classes and settings, then one link and QR per class.
class CreateOnlineTestScreen extends StatefulWidget {
  final String examTitle;

  const CreateOnlineTestScreen({super.key, required this.examTitle});

  /// [args]: `{'exam_id': int, 'title': String}`.
  static Widget create(Map<String, dynamic> args) => BlocProvider(
        create: (_) => CreateOnlineTestCubit(
          examId: args['exam_id'] as int,
          repository: OnlineTestsRepository(),
          classes: ClassesRepository(),
        )..loadClasses(),
        child: CreateOnlineTestScreen(examTitle: args['title']?.toString() ?? ''),
      );

  @override
  State<CreateOnlineTestScreen> createState() => _CreateOnlineTestScreenState();
}

class _CreateOnlineTestScreenState extends State<CreateOnlineTestScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.examTitle);
  final TextEditingController _group = TextEditingController();
  final TextEditingController _field = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _group.dispose();
    _field.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hintKey) => InputDecoration(
        hintText: appTranslation().get(hintKey),
        filled: true,
        fillColor: ColorsManager.surfacePrimary,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _label(String key) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(appTranslation().get(key), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = CreateOnlineTestCubit.get(context);
    final textStyle = TextStylesManager.regular14.copyWith(color: ColorsManager.mainText);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('online_tests_share'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<CreateOnlineTestCubit, CreateOnlineTestState>(
        listenWhen: (a, b) => a.error != b.error || a.createdId != b.createdId,
        listener: (context, state) {
          if (state.error != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          }
          if (state.createdId != null) {
            Navigator.pushReplacementNamed(context, Routes.onlineTest, arguments: state.createdId);
          }
        },
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('online_tests_test_title'),
            TextField(controller: _title, maxLength: 200, style: textStyle, decoration: _decoration('online_tests_test_title')),
            _label('online_tests_classes_label'),
            Text(appTranslation().get('online_tests_classes_hint'), style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
            verticalSpace8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < state.groups.length; i++)
                  InputChip(label: Text(state.groups[i].name), onDeleted: () => cubit.removeGroup(i)),
              ],
            ),
            if (state.classes.isNotEmpty) ...[
              verticalSpace8,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in state.classes)
                    if (!state.groups.any((g) => g.classId == c.id))
                      ActionChip(avatar: const Icon(Icons.add, size: 16), label: Text(c.name), onPressed: () => cubit.addGroup(c.name, classId: c.id)),
                ],
              ),
            ],
            verticalSpace8,
            Row(
              children: [
                Expanded(child: TextField(controller: _group, maxLength: 60, style: textStyle, decoration: _decoration('online_tests_class_name'))),
                horizontalSpace8,
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    cubit.addGroup(_group.text);
                    _group.clear();
                  },
                ),
              ],
            ),
            _label('online_tests_settings'),
            SwitchListTile(value: state.showScore, onChanged: cubit.setShowScore, title: Text(appTranslation().get('online_tests_show_score'), style: textStyle), contentPadding: EdgeInsets.zero),
            SwitchListTile(value: state.shuffleQuestions, onChanged: cubit.setShuffleQuestions, title: Text(appTranslation().get('online_tests_shuffle_questions'), style: textStyle), contentPadding: EdgeInsets.zero),
            SwitchListTile(value: state.shuffleOptions, onChanged: cubit.setShuffleOptions, title: Text(appTranslation().get('online_tests_shuffle_options'), style: textStyle), contentPadding: EdgeInsets.zero),
            TextField(
              keyboardType: TextInputType.number,
              style: textStyle,
              decoration: _decoration('online_tests_time_limit'),
              onChanged: cubit.setTimeLimit,
            ),
            _label('online_tests_student_fields'),
            Text(appTranslation().get('online_tests_student_fields_hint'), style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
            verticalSpace8,
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < state.studentFields.length; i++)
                  InputChip(label: Text(state.studentFields[i]), onDeleted: () => cubit.removeField(i)),
              ],
            ),
            if (state.studentFields.length < CreateOnlineTestState.maxFields)
              Row(
                children: [
                  Expanded(child: TextField(controller: _field, maxLength: 40, style: textStyle, decoration: _decoration('online_tests_field_label'))),
                  horizontalSpace8,
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cubit.addField(_field.text);
                      _field.clear();
                    },
                  ),
                ],
              ),
            verticalSpace24,
            PrimaryElevatedButton(
              text: appTranslation().get('online_tests_create'),
              isLoading: state.isSaving,
              onPressed: () => cubit.submit(_title.text),
            ),
          ],
        ),
      ),
    );
  }
}
