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
import 'package:moean/features/exam_generation/data/datasources/local_curriculum_provider.dart';

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
                        'اختاري المرحلة والصف والمادة والوحدة\nثم اختاري أكثر من درس من نفس الشاشة.',
                        textAlign: TextAlign.center,
                        style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                      ),
                    ],
                  ),
                  verticalSpace24,
          
                  _buildChipsSelection(
                    label: 'اختر المرحلة الدراسية',
                    items: LocalCurriculumProvider.gradeStages,
                    selectedValue: cubit.gradeStage,
                    onSelected: (v) => cubit.updateInfo(gradeStage: v, grade: ''),
                  ),
                  
                  if (cubit.gradeStage.isNotEmpty) ...[
                    verticalSpace24,
                    _buildChipsSelection(
                      label: 'اختر الصف',
                      items: LocalCurriculumProvider.gradesByStage[cubit.gradeStage] ?? [],
                      selectedValue: cubit.grade,
                      onSelected: (v) => cubit.updateInfo(grade: v),
                    ),
                  ],
                  verticalSpace24,
           _buildChipsSelection(
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
                
                verticalSpace24,
                  _buildDropdownField(
                    label: 'اختر المادة',
                    value: cubit.subject,
                    onTap: () => _showSelector(
                      'اختر المادة',
                      cubit.subjectsData.map((e) => e.name).toSet().toList(),
                      (v) => cubit.updateInfo(subject: v),
                    ),
                  ),
                  verticalSpace16,
          
                  _buildDropdownField(
                    label: 'اختر الوحدة',
                    value: cubit.selectedUnit?.name ?? '',
                    onTap: () {
                      if (cubit.subject.isEmpty) return;
                      final subjectModel = cubit.subjectsData.firstWhere((e) => e.name == cubit.subject);
                      _showSelector(
                        'اختر الوحدة',
                        subjectModel.units.map((e) => e.name).toSet().toList(),
                        (v) {
                          final selectedUnit = subjectModel.units.firstWhere((e) => e.name == v);
                          cubit.updateInfo(selectedUnit: selectedUnit);
                        }
                      );
                    },
                  ),
                  
                 ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: PrimaryElevatedButton(
            text: 'متابعة لتحديد عدد الأسئلة',
            onPressed: cubit.isValid ? () {
              context.push(Routes.examGenerationLessons);
            } : null,
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

  Widget _buildChipsSelection({
    required String label, 
    required List<String> items, 
    required String selectedValue, 
    required Function(String) onSelected,
    String Function(String)? itemLabelBuilder,
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
            final displayText = itemLabelBuilder != null ? itemLabelBuilder(item) : item;
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
