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
  late final TextEditingController _examTitleController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExamInfoCubit>();
    _examTitleController = TextEditingController(text: cubit.examTitle);
  }

  @override
  void dispose() {
    _examTitleController.dispose();
    super.dispose();
  }
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
      return SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }
    
    if (state is ExamInfoError) {
      return SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Center(
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
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header UI
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      Text(
                        'الخطوة الأولى',
                        style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                      ),
                    ],
                  ),
                  verticalSpace8,
                  Text(
                    'اختيار بيانات الاختبار',
                    textAlign: TextAlign.center,
                    style: TextStylesManager.bold24.copyWith(color: ColorsManager.mainText),
                  ),
                  verticalSpace8,
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ColorsManager.primaryColor, width: 2),
                      ),
                      child: Icon(Icons.tune, color: ColorsManager.primaryColor),
                    ),
                  ),
                  verticalSpace8,
                  Text(
                    'اختار المرحلة والصف والمادة\nثم اختار الفصل والدروس من الشاشة التالية.',
                    textAlign: TextAlign.center,
                    style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                  ),
                  verticalSpace24,
          
                  _buildChipsSelection<CurriculumStageModel>(
                    label: 'اختر المرحلة الدراسية',
                    items: List.of(cubit.stages)..sort((a, b) {
                      int getWeight(String name) {
                        if (name.contains('الابتدائية')) return 1;
                        if (name.contains('المتوسطة')) return 2;
                        if (name.contains('الثانوية')) return 3;
                        return 4;
                      }
                      return getWeight(a.name).compareTo(getWeight(b.name));
                    }),
                    selectedValue: cubit.selectedStage,
                    onSelected: (v) => cubit.updateInfo(stage: v),
                    itemLabelBuilder: (item) => item.name,
                  ),
                  
                  if (cubit.selectedStage != null) ...[
                    verticalSpace24,
                    _buildChipsSelection<String>(
                      label: 'اختر الفصل الدراسي',
                      items: ['1', '2'],
                      selectedValue: cubit.selectedSemester,
                      onSelected: (v) => cubit.updateInfo(semester: v),
                      itemLabelBuilder: (item) => 'الفصل الدراسى $item',
                    ),
                  ],
                  
                  if (cubit.availableTracks.isNotEmpty) ...[
                    verticalSpace24,
                    _buildChipsSelection<String>(
                      label: 'المسار',
                      items: cubit.availableTracks,
                      selectedValue: cubit.selectedTrack,
                      onSelected: (v) => cubit.updateInfo(track: v),
                      itemLabelBuilder: (item) => item,
                    ),
                  ],

                  if (cubit.selectedStage != null && (cubit.availableTracks.isEmpty || cubit.selectedTrack != null)) ...[
                    verticalSpace24,
                    _buildChipsSelection<CurriculumGradeModel>(
                      label: 'الصف الدراسي',
                      items: cubit.availableGrades,
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

                  if (cubit.selectedSubject != null) ...[
                    verticalSpace24,
                    cubit.isUnitsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdownField(
                            label: 'الوحدة',
                            value: cubit.unitName ?? '',
                            onTap: () {
                              if (cubit.availableUnits.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('لا توجد وحدات متاحة لهذه المادة')),
                                );
                                return;
                              }
                              _showSelector(
                                'اختر الوحدة',
                                cubit.availableUnits,
                                (v) => cubit.updateInfo(unitName: v),
                              );
                            },
                          ),
                    verticalSpace24,
                    _buildTextField(
                      label: 'عنوان الاختبار',
                      hint: 'مثال: اختبار الوحدة الثانية',
                      controller: _examTitleController,
                      onChanged: (v) => cubit.updateInfo(examTitle: v),
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
            color: ColorsManager.surfacePrimary,
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
      body: BlocConsumer<ExamInfoCubit, ExamInfoState>(
        listener: (context, state) {
          if (state is ExamInfoUpdated) {
            if (state.examTitle == null && _examTitleController.text.isNotEmpty) {
              _examTitleController.clear();
            }
          }
        },
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
            Text(label, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
          ],
        ),
        verticalSpace12,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: ColorsManager.borderLightGray),
              borderRadius: BorderRadius.circular(12),
              color: ColorsManager.surfacePrimary,
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool showDropdownIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(label, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
          ],
        ),
        verticalSpace12,
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
            filled: true,
            fillColor: ColorsManager.surfacePrimary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: showDropdownIcon ? Icon(Icons.keyboard_arrow_down, color: ColorsManager.mainText) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.borderLightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.borderLightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.primaryColor),
            ),
          ),
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
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
            Text(label, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
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
                  color: isSelected ? ColorsManager.primaryColor : ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStylesManager.bold14.copyWith(
                    color: isSelected ? Colors.white : ColorsManager.mainText,
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
