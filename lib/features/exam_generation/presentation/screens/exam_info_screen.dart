import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/selection_bottom_sheet.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class ExamInfoScreen extends StatefulWidget {
  const ExamInfoScreen({super.key});

  @override
  State<ExamInfoScreen> createState() => _ExamInfoScreenState();
}

class _ExamInfoScreenState extends State<ExamInfoScreen> {
  void _showSelector(String title, List<String> items, Function(String) onSelected) {
    SelectionBottomSheet.show(
      context: context,
      title: title,
      items: items,
      initialSelectedItems: [],
      isMultiSelect: false,
      onSelectionConfirmed: (selected) {
        if (selected.isNotEmpty) {
          onSelected(selected.first);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, ExamInfoState state, ExamInfoCubit cubit) {
    if (state is ExamInfoLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is ExamInfoError) {
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

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header UI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('الخطوة الأولى', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                      verticalSpace4,
                      Text('اختيار بيانات الاختبار', style: TextStylesManager.bold24.copyWith(color: ColorsManager.primaryColor)),
                       verticalSpace8,
                      
                      Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: ColorsManager.primaryColor, width: 2),
                         ),
                         child:  Icon(Icons.tune, color: ColorsManager.primaryColor),
                      ),
                     verticalSpace8,
                      Text(
                        'اختاري المرحلة والصف والمادة\nثم اختاري الفصل والدروس من الشاشة التالية.',
                        textAlign: TextAlign.center,
                        style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                      ),
                    ],
                  ),
                  verticalSpace24,
          
                  _buildChipsSelection<CurriculumStageModel>(
                    label: 'اختر المرحلة الدراسية',
                    items: cubit.stages,
                    selectedValue: cubit.selectedStage,
                    onSelected: (v) => cubit.updateInfo(stage: v),
                    itemLabelBuilder: (item) => item.name,
                  ),
                  
                  if (cubit.selectedStage != null) ...[
                    verticalSpace24,
                    _buildChipsSelection<CurriculumGradeModel>(
                      label: 'اختر الصف',
                      items: cubit.selectedStage!.grades,
                      selectedValue: cubit.selectedGrade,
                      onSelected: (v) => cubit.updateInfo(grade: v),
                      itemLabelBuilder: (item) => item.name,
                    ),
                  ],

                  if (cubit.selectedGrade != null) ...[
                    verticalSpace24,
                    _buildDropdownField(
                      label: 'اختر المادة',
                      value: cubit.selectedSubject?.name ?? '',
                      onTap: () {
                        final subjects = cubit.selectedGrade!.subjects;
                        _showSelector(
                          'اختر المادة',
                          subjects.map((e) => e.name).toSet().toList(),
                          (v) {
                            final selectedSub = subjects.firstWhere((e) => e.name == v);
                            cubit.updateInfo(subject: selectedSub);
                          }
                        );
                      },
                    ),
                  ],
                  
                  verticalSpace24,
                  _buildChipsSelection<String>(
                    label: 'مستوى الاختبار',
                    items: ['easy', 'medium', 'hard'],
                    selectedValue: cubit.difficulty,
                    onSelected: (v) => cubit.updateInfo(difficulty: v),
                    itemLabelBuilder: (item) {
                      switch (item) {
                        case 'easy': return 'سهل';
                        case 'medium': return 'متوسط';
                        case 'hard': return 'صعب';
                        default: return item;
                      }
                    },
                  ),
                  
                 ],
              ),
            ),
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
              text: 'متابعة لاختيار الدروس',
              onPressed: cubit.isValid ? () {
                context.push(Routes.examGenerationLessons);
              } : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ExamInfoCubit, ExamInfoState>(
        builder: (context, state) {
          final cubit = context.read<ExamInfoCubit>();
          return _buildBody(context, state, cubit);
        },
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(label, style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor)),
          ],
        ),
        verticalSpace12,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'اختر...' : value,
                    style: value.isEmpty 
                      ? TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText)
                      : TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
                 Icon(Icons.keyboard_arrow_down, color: ColorsManager.mainText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsSelection<T>({
    required String label, 
    required List<T> items, 
    required T? selectedValue, 
    required Function(T) onSelected,
    required String Function(T) itemLabelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(label, style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor)),
          ],
        ),
        verticalSpace12,
        Wrap(
          spacing: 8.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: items.map((item) {
            final isSelected = selectedValue == item;
            final displayText = itemLabelBuilder(item);
            return InkWell(
              onTap: () => onSelected(item),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? ColorsManager.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? ColorsManager.primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStylesManager.bold14.copyWith(
                    color: isSelected ? Colors.white : ColorsManager.secondaryText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
