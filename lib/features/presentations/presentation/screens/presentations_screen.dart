import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

import 'package:moean/features/presentations/presentation/cubit/presentations_cubit.dart';
import 'package:moean/features/presentations/presentation/cubit/presentations_state.dart';
import 'package:moean/features/reports/presentation/widgets/selection_bottom_sheet.dart';

import 'presentation_preview_screen.dart';

class PresentationsScreen extends StatefulWidget {
  const PresentationsScreen({super.key});

  @override
  State<PresentationsScreen> createState() => _PresentationsScreenState();
}

class _PresentationsScreenState extends State<PresentationsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<PresentationsCubit, PresentationsState>(
        listener: (context, state) {
          if (state is PresentationsSuccess) {
            final cubit = context.read<PresentationsCubit>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresentationPreviewScreen(
                  presentation: state.presentation,
                  cubit: cubit,
                ),
              ),
            );
          } else if (state is PresentationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<PresentationsCubit>();
          final isWide = MediaQuery.of(context).size.width > 800;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                verticalSpace32,
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildForm(cubit),
                      ),
                      horizontalSpace24,
                      Expanded(
                        flex: 7,
                        child: _buildPreviewArea(state, cubit),
                      ),
                    ],
                  )
                else ...[
                  _buildForm(cubit),
                  verticalSpace32,
                  _buildPreviewArea(state, cubit),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.co_present_rounded, color: ColorsManager.primaryColor, size: 20),
              horizontalSpace8,
              Text(
                appTranslation().get('presentations_title'),
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
              ),
            ],
          ),
        ),
        verticalSpace16,
        Text(
          appTranslation().get('presentations_subtitle'),
          style: TextStylesManager.bold26.copyWith(color: ColorsManager.primaryColor),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Text(
          appTranslation().get('presentations_desc'),
          style: TextStylesManager.regular16.copyWith(color: ColorsManager.secondaryText),
          textAlign: TextAlign.center,
        ),
        verticalSpace24,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildStaticChip(Icons.download, appTranslation().get('presentations_download')),
            _buildStaticChip(Icons.palette_outlined, appTranslation().get('presentations_templates_ready')),
            _buildStaticChip(Icons.layers_outlined, appTranslation().get('presentations_slides_range')),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ColorsManager.primaryColor, size: 18),
          horizontalSpace8,
          Text(
            label,
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(PresentationsCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appTranslation().get('presentations_data'),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.secondaryText),
                  ),
                  Text(
                    appTranslation().get('presentations_choose_lesson_design'),
                    style: TextStylesManager.bold20.copyWith(color: ColorsManager.primaryColor),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tune, color: ColorsManager.primaryColor, size: 24),
              ),
            ],
          ),
          verticalSpace24,
          _buildDropdownField(
            label: appTranslation().get('presentations_stage'),
            value: cubit.selectedStage?.name,
            onTap: () {
              if (cubit.stages.isEmpty) return;
              _showSelector(
                appTranslation().get('presentations_stage'),
                cubit.stages.map((e) => e.name).toList(),
                (v) {
                  final selected = cubit.stages.firstWhere((e) => e.name == v);
                  cubit.updateSelection(stage: selected);
                },
              );
            },
          ),
          if (cubit.availableTracks.isNotEmpty) ...[
            verticalSpace16,
            _buildDropdownField(
              label: 'المسار',
              value: cubit.selectedTrack,
              onTap: () {
                _showSelector(
                  'المسار',
                  cubit.availableTracks,
                  (v) {
                    cubit.updateSelection(track: v);
                  },
                );
              },
            ),
          ],
          if (cubit.selectedStage != null && (cubit.availableTracks.isEmpty || cubit.selectedTrack != null)) ...[
            verticalSpace16,
            _buildDropdownField(
              label: appTranslation().get('presentations_grade'),
              value: cubit.selectedGrade?.name,
              onTap: () {
                if (cubit.selectedStage == null) return;
                _showSelector(
                  appTranslation().get('presentations_grade'),
                  cubit.availableGrades.map((e) => e.name).toList(),
                  (v) {
                    final selected = cubit.availableGrades.firstWhere((e) => e.name == v);
                    cubit.updateSelection(grade: selected);
                  },
                );
              },
            ),
          ],
          verticalSpace16,
          _buildDropdownField(
            label: appTranslation().get('presentations_subject'),
            value: cubit.selectedSubject?.name,
            onTap: () {
              if (cubit.selectedGrade == null) return;
              _showSelector(
                appTranslation().get('presentations_subject'),
                cubit.selectedGrade!.subjects.map((e) => e.name).toList(),
                (v) {
                  final selected = cubit.selectedGrade!.subjects.firstWhere((e) => e.name == v);
                  cubit.updateSelection(subject: selected);
                },
              );
            },
          ),
          verticalSpace16,
          _buildDropdownField(
            label: appTranslation().get('presentations_unit'),
            value: cubit.selectedUnit?.title,
            onTap: () {
              if (cubit.subjectDetails == null) return;
              _showSelector(
                appTranslation().get('presentations_unit'),
                cubit.subjectDetails!.chapters.map((e) => e.title).toList(),
                (v) {
                  final selected = cubit.subjectDetails!.chapters.firstWhere((e) => e.title == v);
                  cubit.updateSelection(unit: selected);
                },
              );
            },
          ),
          verticalSpace16,
          _buildDropdownField(
            label: appTranslation().get('presentations_lesson'),
            value: cubit.selectedLesson?.title,
            onTap: () {
              if (cubit.selectedUnit == null) return;
              _showSelector(
                appTranslation().get('presentations_lesson'),
                cubit.selectedUnit!.lessons.map((e) => e.title).toList(),
                (v) {
                  final selected = cubit.selectedUnit!.lessons.firstWhere((e) => e.title == v);
                  cubit.updateSelection(lesson: selected);
                },
              );
            },
          ),
          verticalSpace24,
          Text(
            appTranslation().get('presentations_template'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace12,
          _buildTemplateOption(
            cubit,
            title: appTranslation().get('presentations_classic'),
            desc: appTranslation().get('presentations_classic_desc'),
            color: Colors.teal,
            isSelected: cubit.selectedTemplate == 'emerald-green',
            onTap: () => cubit.updateSelection(template: 'emerald-green'),
          ),
          verticalSpace8,
          _buildTemplateOption(
            cubit,
            title: appTranslation().get('presentations_academic'),
            desc: appTranslation().get('presentations_academic_desc'),
            color: Colors.blue.shade700,
            isSelected: cubit.selectedTemplate == 'academic-blue',
            onTap: () => cubit.updateSelection(template: 'academic-blue'),
          ),
          verticalSpace8,
          _buildTemplateOption(
            cubit,
            title: appTranslation().get('presentations_warm'),
            desc: appTranslation().get('presentations_warm_desc'),
            color: Colors.orange.shade400,
            isSelected: cubit.selectedTemplate == 'warm-orange',
            onTap: () => cubit.updateSelection(template: 'warm-orange'),
          ),
          verticalSpace24,
          Text(
            appTranslation().get('presentations_slides_count'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace12,
          Row(
            children: [
              Expanded(
                child: _buildSlideCountOption(
                  cubit,
                  count: '10 شرائح',
                  isSelected: cubit.selectedSlidesCount == '10',
                  onTap: () => cubit.updateSelection(slidesCount: '10'),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: _buildSlideCountOption(
                  cubit,
                  count: '8 شرائح',
                  isSelected: cubit.selectedSlidesCount == '8',
                  onTap: () => cubit.updateSelection(slidesCount: '8'),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: _buildSlideCountOption(
                  cubit,
                  count: '6 شرائح',
                  isSelected: cubit.selectedSlidesCount == '6',
                  onTap: () => cubit.updateSelection(slidesCount: '6'),
                ),
              ),
            ],
          ),
          verticalSpace32,
          PrimaryElevatedButton(
            text: appTranslation().get('presentations_create'),
            onPressed: cubit.canCreate ? () => cubit.createPresentation() : null,
            icon: const Icon(Icons.auto_awesome),
            isLoading: cubit.state is PresentationsLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String? value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
        verticalSpace8,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: ColorsManager.borderColor),
              borderRadius: BorderRadius.circular(12),
              color: ColorsManager.surfacePrimary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? 'اختر...',
                    style: value == null
                        ? TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText)
                        : TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
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

  Widget _buildTemplateOption(PresentationsCubit cubit, {required String title, required String desc, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : ColorsManager.borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: color)
            else
              const SizedBox(width: 24, height: 24),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                  verticalSpace4,
                  Text(desc, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.horizontal_split, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideCountOption(PresentationsCubit cubit, {required String count, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.surfacePrimary,
          border: Border.all(color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          count,
          style: TextStylesManager.bold14.copyWith(color: isSelected ? Colors.white : ColorsManager.mainText),
        ),
      ),
    );
  }
  Widget _buildPreviewArea(PresentationsState state, PresentationsCubit cubit) {
    if (state is PresentationsSuccess) {
      return const SizedBox.shrink();
    } else if (state is PresentationsLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (state is PresentationsError) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  verticalSpace16,
                  Text(
                    'تعذر تجهيز العرض',
                    style: TextStylesManager.bold16.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace8,
                  Text(
                    state.message,
                    style: TextStylesManager.regular14.copyWith(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      final selectedTemplateName = cubit.selectedTemplate == 'academic-blue'
          ? appTranslation().get('presentations_academic')
          : cubit.selectedTemplate == 'warm-orange'
              ? appTranslation().get('presentations_warm')
              : appTranslation().get('presentations_classic');

      final details = [
        if (cubit.selectedSubject != null) cubit.selectedSubject!.name,
        if (cubit.selectedGrade != null) cubit.selectedGrade!.name,
        selectedTemplateName,
      ];
      final detailsText = details.isNotEmpty ? details.join(' • ') : 'الرياضيات • الصف الأول المتوسط • حضّر الكلاسيكي';

      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appTranslation().get('presentations_preview'),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.secondaryText),
                  ),
                  Text(
                    cubit.selectedLesson?.title ?? 'التهيئة',
                    style: TextStylesManager.bold24.copyWith(color: ColorsManager.primaryColor),
                  ),
                  Text(
                    detailsText,
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ],
              ),
            ),
            verticalSpace40,
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.co_present, color: ColorsManager.primaryColor, size: 40),
            ),
            verticalSpace24,
            Text(
              appTranslation().get('presentations_no_saved'),
              style: TextStylesManager.bold20.copyWith(color: ColorsManager.primaryColor),
              textAlign: TextAlign.center,
            ),
            verticalSpace12,
            Text(
              appTranslation().get('presentations_create_to_preview'),
              style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
              textAlign: TextAlign.center,
            ),
            verticalSpace40,
          ],
        ),
      );
    }
  }

}
