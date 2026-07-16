import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/lesson_selection_cubit.dart';

class LessonSelectionScreen extends StatefulWidget {
  const LessonSelectionScreen({super.key});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final selectedUnit = context.read<ExamInfoCubit>().selectedUnit;
    if (selectedUnit != null) {
      context.read<LessonSelectionCubit>().loadLessonsForSubjectId(selectedUnit.subjectId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context, LessonSelectionState state, LessonSelectionCubit cubit) {
    if (state is LessonSelectionLoading) {
      return Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
    }
    
    if (state is LessonSelectionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: TextStylesManager.bold14.copyWith(color: ColorsManager.errorColor)),
            verticalSpace16,
            PrimaryElevatedButton(
              text: 'إعادة المحاولة',
              onPressed: () => cubit.retry(),
            )
          ],
        ),
      );
    }

    if (state is LessonSelectionUpdated) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('الخطوة 1 من 3: اختيار الدروس', style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor)),
                verticalSpace16,
                PrimaryTextField(
                  controller: _searchController,
                  hint: 'ابحث عن درس...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (val) => cubit.search(val),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (val) => cubit.search(val),
                ),
                verticalSpace16,
                Text(
                  'دروس محددة ${state.selectedLessons.length}',
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                ),
                if (state.selectedLessons.isNotEmpty) ...[
                  verticalSpace8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.selectedLessons.map((lesson) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                lesson['name'],
                                style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => cubit.removeLesson(lesson['id']),
                              child: const Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.filteredLessons.length,
              itemBuilder: (context, index) {
                final lesson = state.filteredLessons[index];
                final isSelected = state.selectedLessons.any((l) => l['id'] == lesson['id']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorsManager.primaryColor.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? ColorsManager.primaryColor : Colors.grey.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    activeColor: ColorsManager.primaryColor,
                    title: Text(
                      lesson['name'],
                      style: isSelected ? TextStylesManager.bold14 : TextStylesManager.regular14,
                    ),
                    onChanged: (_) => cubit.toggleLesson(lesson),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: const EdgeInsets.all(20),
              child: PrimaryElevatedButton(
                text: appTranslation().get('continue'),
                onPressed: cubit.hasSelection ? () {
                  context.push(Routes.examGenerationCounts);
                } : null,
              ),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox();
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
          appTranslation().get('exam_lesson_selection'),
          style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
        ),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<LessonSelectionCubit, LessonSelectionState>(
        builder: (context, state) {
          final cubit = context.read<LessonSelectionCubit>();
          return _buildBody(context, state, cubit);
        },
      ),
    );
  }
}
