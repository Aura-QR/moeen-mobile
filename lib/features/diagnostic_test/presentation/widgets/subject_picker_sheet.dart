import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';

/// Picks one subject (with its grade) from the curriculum. Resolves to null when closed.
Future<LessonPickerSubjectModel?> showSubjectPickerSheet(BuildContext context) => showModalBottomSheet<LessonPickerSubjectModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const FractionallySizedBox(heightFactor: 0.85, child: _SubjectPicker()),
    );

class _SubjectPicker extends StatefulWidget {
  const _SubjectPicker();

  @override
  State<_SubjectPicker> createState() => _SubjectPickerState();
}

class _SubjectPickerState extends State<_SubjectPicker> {
  List<LessonPickerSubjectModel>? _subjects;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    CurriculumLessonsRepository().getSubjects().then((r) {
      if (!mounted) return;
      r.fold((f) => setState(() => _error = f.message), (s) => setState(() => _subjects = s));
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = (_subjects ?? const <LessonPickerSubjectModel>[]).where((s) => s.matches(_query)).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(appTranslation().get('diagnostic_pick_subject'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
          const SizedBox(height: 12),
          TextField(
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: appTranslation().get('diagnostic_search_subject'),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _subjects == null
                ? Center(child: _error != null ? Text(appTranslation().get(_error!)) : const CircularProgressIndicator())
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                    itemBuilder: (_, i) => ListTile(
                      title: Text(list[i].subjectName, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                      subtitle: Text(list[i].gradeName, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
                      onTap: () => Navigator.pop(context, list[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
