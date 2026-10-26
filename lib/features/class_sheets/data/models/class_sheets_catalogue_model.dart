import 'package:flutter/material.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_column.dart';

enum SheetKindType {
  grades,
  attendance,
  dailyFollowUp,
  skills,
  blank,
}

class SheetKindModel {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final SheetKindType kindType;
  final bool isLandscape;
  final List<ClassSheetColumn> defaultColumns;

  const SheetKindModel({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.kindType,
    this.isLandscape = false,
    this.defaultColumns = const [],
  });

  factory SheetKindModel.fromJson(Map<String, dynamic> json) {
    final key = (json['key'] ?? json['sheet'] ?? json['id'])?.toString() ?? '';
    final rawLabel = json['label']?.toString().trim() ?? '';
    final rawDesc = json['description']?.toString().trim() ?? '';
    final kindType = _typeFor(key, rawLabel);
    final defaultCols = (json['default_columns'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(ClassSheetColumn.fromJson)
            .toList() ??
        _defaultColumnsFor(kindType);

    return SheetKindModel(
      key: key,
      label: rawLabel.isNotEmpty ? rawLabel : _defaultLabelFor(kindType),
      description: rawDesc.isNotEmpty ? rawDesc : _defaultDescFor(kindType),
      icon: _iconFor(kindType),
      kindType: kindType,
      isLandscape: json['is_landscape'] as bool? ?? (kindType == SheetKindType.attendance),
      defaultColumns: defaultCols,
    );
  }

  static SheetKindType _typeFor(String key, [String label = '']) {
    final k = key.toLowerCase().replaceAll('-', '_').trim();
    if (k.contains('attend') || label.contains('حضور') || label.contains('غياب')) {
      return SheetKindType.attendance;
    }
    if (k.contains('follow') ||
        k.contains('daily') ||
        k.contains('monitor') ||
        k.contains('track') ||
        label.contains('متابع')) {
      return SheetKindType.dailyFollowUp;
    }
    if (k.contains('skill') || k.contains('standard') || label.contains('مهار')) {
      return SheetKindType.skills;
    }
    if (k.contains('blank') ||
        k.contains('custom') ||
        k.contains('empty') ||
        k.contains('general') ||
        label.contains('مخصص') ||
        label.contains('فارغ') ||
        label.contains('عام')) {
      return SheetKindType.blank;
    }
    return SheetKindType.grades;
  }

  static IconData _iconFor(SheetKindType type) => switch (type) {
        SheetKindType.attendance => Icons.event_available_outlined,
        SheetKindType.dailyFollowUp => Icons.fact_check_outlined,
        SheetKindType.skills => Icons.checklist_rtl_rounded,
        SheetKindType.blank => Icons.grid_on_rounded,
        SheetKindType.grades => Icons.format_list_numbered_rounded,
      };

  static String _defaultLabelFor(SheetKindType type) => switch (type) {
        SheetKindType.attendance => 'sheets_kind_attendance',
        SheetKindType.dailyFollowUp => 'sheets_kind_daily_follow_up',
        SheetKindType.skills => 'sheets_kind_skills',
        SheetKindType.blank => 'sheets_kind_blank',
        SheetKindType.grades => 'sheets_kind_grades',
      };

  static String _defaultDescFor(SheetKindType type) => switch (type) {
        SheetKindType.attendance => 'sheets_kind_attendance_desc',
        SheetKindType.dailyFollowUp => 'sheets_kind_daily_follow_up_desc',
        SheetKindType.skills => 'sheets_kind_skills_desc',
        SheetKindType.blank => 'sheets_kind_blank_desc',
        SheetKindType.grades => 'sheets_kind_grades_desc',
      };

  static List<ClassSheetColumn> _defaultColumnsFor(SheetKindType type) => switch (type) {
        SheetKindType.attendance => const [],
        SheetKindType.dailyFollowUp => const [
            ClassSheetColumn(label: 'المشاركة'),
            ClassSheetColumn(label: 'الواجبات'),
            ClassSheetColumn(label: 'المهام الأدائية'),
            ClassSheetColumn(label: 'ملاحظات'),
          ],
        SheetKindType.skills => const [
            ClassSheetColumn(label: 'المهارة 1'),
            ClassSheetColumn(label: 'المهارة 2'),
            ClassSheetColumn(label: 'المهارة 3'),
            ClassSheetColumn(label: 'المهارة 4'),
            ClassSheetColumn(label: 'التقييم العام'),
          ],
        SheetKindType.blank => const [
            ClassSheetColumn(label: 'عمود 1'),
            ClassSheetColumn(label: 'عمود 2'),
            ClassSheetColumn(label: 'عمود 3'),
            ClassSheetColumn(label: 'عمود 4'),
            ClassSheetColumn(label: 'عمود 5'),
          ],
        SheetKindType.grades => const [
            ClassSheetColumn(label: 'المشاركة', max: 10),
            ClassSheetColumn(label: 'الواجبات', max: 10),
            ClassSheetColumn(label: 'المهام الأدائية', max: 10),
            ClassSheetColumn(label: 'اختبار قصير 1', max: 10),
            ClassSheetColumn(label: 'اختبار قصير 2', max: 10),
            ClassSheetColumn(label: 'المجموع', max: 50),
          ],
      };

  static const SheetKindModel defaultKind = SheetKindModel(
    key: 'grades',
    label: 'sheets_kind_grades',
    description: 'sheets_kind_grades_desc',
    icon: Icons.format_list_numbered_rounded,
    kindType: SheetKindType.grades,
    isLandscape: false,
    defaultColumns: [
      ClassSheetColumn(label: 'المشاركة', max: 10),
      ClassSheetColumn(label: 'الواجبات', max: 10),
      ClassSheetColumn(label: 'المهام الأدائية', max: 10),
      ClassSheetColumn(label: 'اختبار قصير 1', max: 10),
      ClassSheetColumn(label: 'اختبار قصير 2', max: 10),
      ClassSheetColumn(label: 'المجموع', max: 50),
    ],
  );

  static const List<SheetKindModel> fallbackKinds = [
    defaultKind,
    SheetKindModel(
      key: 'attendance',
      label: 'sheets_kind_attendance',
      description: 'sheets_kind_attendance_desc',
      icon: Icons.event_available_outlined,
      kindType: SheetKindType.attendance,
      isLandscape: true,
      defaultColumns: [],
    ),
    SheetKindModel(
      key: 'daily_follow_up',
      label: 'sheets_kind_daily_follow_up',
      description: 'sheets_kind_daily_follow_up_desc',
      icon: Icons.fact_check_outlined,
      kindType: SheetKindType.dailyFollowUp,
      isLandscape: false,
      defaultColumns: [
        ClassSheetColumn(label: 'المشاركة'),
        ClassSheetColumn(label: 'الواجبات'),
        ClassSheetColumn(label: 'المهام الأدائية'),
        ClassSheetColumn(label: 'ملاحظات'),
      ],
    ),
    SheetKindModel(
      key: 'skills',
      label: 'sheets_kind_skills',
      description: 'sheets_kind_skills_desc',
      icon: Icons.checklist_rtl_rounded,
      kindType: SheetKindType.skills,
      isLandscape: false,
      defaultColumns: [
        ClassSheetColumn(label: 'المهارة 1'),
        ClassSheetColumn(label: 'المهارة 2'),
        ClassSheetColumn(label: 'المهارة 3'),
        ClassSheetColumn(label: 'المهارة 4'),
        ClassSheetColumn(label: 'التقييم العام'),
      ],
    ),
    SheetKindModel(
      key: 'blank',
      label: 'sheets_kind_blank',
      description: 'sheets_kind_blank_desc',
      icon: Icons.grid_on_rounded,
      kindType: SheetKindType.blank,
      isLandscape: false,
      defaultColumns: [
        ClassSheetColumn(label: 'عمود 1'),
        ClassSheetColumn(label: 'عمود 2'),
        ClassSheetColumn(label: 'عمود 3'),
        ClassSheetColumn(label: 'عمود 4'),
        ClassSheetColumn(label: 'عمود 5'),
      ],
    ),
  ];
}
