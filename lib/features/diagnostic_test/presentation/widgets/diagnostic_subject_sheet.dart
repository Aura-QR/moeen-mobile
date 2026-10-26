import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class DiagnosticSubjectSheet extends StatefulWidget {
  final List<CurriculumSubjectModel> subjects;
  final CurriculumSubjectModel? selected;

  const DiagnosticSubjectSheet({
    super.key,
    required this.subjects,
    this.selected,
  });

  static Future<CurriculumSubjectModel?> show(
    BuildContext context, {
    required List<CurriculumSubjectModel> subjects,
    CurriculumSubjectModel? selected,
  }) =>
      showModalBottomSheet<CurriculumSubjectModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: ColorsManager.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.72,
          child: DiagnosticSubjectSheet(subjects: subjects, selected: selected),
        ),
      );

  @override
  State<DiagnosticSubjectSheet> createState() => _DiagnosticSubjectSheetState();
}

class _DiagnosticSubjectSheetState extends State<DiagnosticSubjectSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurriculumSubjectModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.subjects;
    return widget.subjects.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsManager.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            verticalSpace12,
            Row(
              children: [
                Expanded(
                  child: Text(
                    appTranslation().get('diagnostic_pick_subject'),
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: ColorsManager.secondaryText),
                ),
              ],
            ),
            verticalSpace8,
            PrimaryTextField(
              controller: _searchController,
              hint: appTranslation().get('diagnostic_search_subject'),
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (v) => setState(() => _query = v),
            ),
            verticalSpace12,
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        appTranslation().get('search_empty_title'),
                        style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => verticalSpace8,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = widget.selected?.id == item.id;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context, item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorsManager.primaryColor.withValues(alpha: 0.1)
                                  : ColorsManager.surfacePrimary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked_rounded : Icons.menu_book_outlined,
                                  color: isSelected ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                                  size: 20,
                                ),
                                horizontalSpace12,
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: (isSelected ? TextStylesManager.bold14 : TextStylesManager.medium14).copyWith(
                                      color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
