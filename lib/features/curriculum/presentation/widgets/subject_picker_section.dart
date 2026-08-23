import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class SubjectPickerSection extends StatelessWidget {
  final List<CurriculumStageModel> stages;
  final List<CurriculumGradeModel> grades;
  final List<CurriculumSubjectModel> subjects;
  final CurriculumStageModel? selectedStage;
  final CurriculumGradeModel? selectedGrade;
  final CurriculumSubjectModel? selectedSubject;
  final int selectedSemester;
  final bool loading;
  final String? error;
  final void Function(CurriculumStageModel) onStageSelected;
  final void Function(CurriculumGradeModel) onGradeSelected;
  final void Function(CurriculumSubjectModel) onSubjectSelected;
  final void Function(int) onSemesterChanged;

  const SubjectPickerSection({
    super.key,
    required this.stages,
    required this.grades,
    required this.subjects,
    required this.selectedStage,
    required this.selectedGrade,
    required this.selectedSubject,
    required this.selectedSemester,
    required this.loading,
    required this.error,
    required this.onStageSelected,
    required this.onGradeSelected,
    required this.onSubjectSelected,
    required this.onSemesterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (error != null)
            Text(error!,
                style:
                    TextStylesManager.regular12.copyWith(color: Colors.red))
          else ...[
            PickerDropdown(
              label: 'المرحلة الدراسية',
              icon: Icons.school_outlined,
              value: selectedStage?.name,
              onTap: () => _showPicker<CurriculumStageModel>(
                context,
                title: 'اختر المرحلة',
                items: stages,
                getName: (e) => e.name,
                onSelect: onStageSelected,
              ),
            ),
            if (selectedStage != null) ...[
              verticalSpace8,
              PickerDropdown(
                label: 'الصف الدراسي',
                icon: Icons.class_outlined,
                value: selectedGrade?.name,
                onTap: () => _showPicker<CurriculumGradeModel>(
                  context,
                  title: 'اختر الصف',
                  items: grades,
                  getName: (e) => e.name,
                  onSelect: onGradeSelected,
                ),
              ),
            ],
            if (selectedGrade != null) ...[
              verticalSpace8,
              PickerDropdown(
                label: 'المادة',
                icon: Icons.book_outlined,
                value: selectedSubject?.name,
                onTap: () => _showPicker<CurriculumSubjectModel>(
                  context,
                  title: 'اختر المادة',
                  items: subjects,
                  getName: (e) => e.name,
                  onSelect: onSubjectSelected,
                ),
              ),
            ],
          ],
          if (selectedSubject != null) ...[
            verticalSpace10,
            Row(
              children: [
                Text('توزيع المنهج',
                    style: TextStylesManager.bold14
                        .copyWith(color: ColorsManager.mainText)),
                const Spacer(),
                SemesterChip(
                  label: 'الفصل الأول',
                  selected: selectedSemester == 1,
                  onTap: () => onSemesterChanged(1),
                ),
                horizontalSpace8,
                SemesterChip(
                  label: 'الفصل الثاني',
                  selected: selectedSemester == 2,
                  onTap: () => onSemesterChanged(2),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) getName,
    required void Function(T) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStylesManager.bold16),
            const SizedBox(height: 8),
            const Divider(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  title: Text(getName(items[i]),
                      style: TextStylesManager.regular14),
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(items[i]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PickerDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;

  const PickerDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorsManager.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorsManager.primaryColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStylesManager.regular14.copyWith(
                  color: value != null
                      ? ColorsManager.mainText
                      : ColorsManager.secondaryText,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: ColorsManager.secondaryText),
          ],
        ),
      ),
    );
  }
}

class SemesterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SemesterChip(
      {super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ColorsManager.primaryColor : ColorsManager.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorsManager.primaryColor,
            width: selected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStylesManager.bold12.copyWith(
            color: selected ? Colors.white : ColorsManager.primaryColor,
          ),
        ),
      ),
    );
  }
}
