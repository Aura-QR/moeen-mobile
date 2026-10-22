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
    final key = json['key']?.toString() ?? '';
    final defaultCols = (json['default_columns'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(ClassSheetColumn.fromJson)
            .toList() ??
        _defaultColumnsFor(key);

    return SheetKindModel(
      key: key,
      label: json['label']?.toString() ?? _defaultLabelFor(key),
      description: json['description']?.toString() ?? _defaultDescFor(key),
      icon: _iconFor(key),
      kindType: _typeFor(key),
      isLandscape: json['is_landscape'] as bool? ?? (key == 'attendance'),
      defaultColumns: defaultCols,
    );
  }

  static SheetKindType _typeFor(String key) => switch (key) {
        'attendance' => SheetKindType.attendance,
        'daily_follow_up' || 'follow_up' => SheetKindType.dailyFollowUp,
        'skills' => SheetKindType.skills,
        'blank' || 'custom' => SheetKindType.blank,
        _ => SheetKindType.grades,
      };

  static IconData _iconFor(String key) => switch (key) {
        'attendance' => Icons.event_available_outlined,
        'daily_follow_up' || 'follow_up' => Icons.fact_check_outlined,
        'skills' => Icons.checklist_rtl_rounded,
        'blank' || 'custom' => Icons.grid_on_rounded,
        _ => Icons.format_list_numbered_rounded,
      };

  static String _defaultLabelFor(String key) => switch (key) {
        'attendance' => 'sheets_kind_attendance',
        'daily_follow_up' || 'follow_up' => 'sheets_kind_daily_follow_up',
        'skills' => 'sheets_kind_skills',
        'blank' || 'custom' => 'sheets_kind_blank',
        _ => 'sheets_kind_grades',
      };

  static String _defaultDescFor(String key) => switch (key) {
        'attendance' => 'sheets_kind_attendance_desc',
        'daily_follow_up' || 'follow_up' => 'sheets_kind_daily_follow_up_desc',
        'skills' => 'sheets_kind_skills_desc',
        'blank' || 'custom' => 'sheets_kind_blank_desc',
        _ => 'sheets_kind_grades_desc',
      };

  static List<ClassSheetColumn> _defaultColumnsFor(String key) => switch (key) {
        'attendance' => const [],
        'daily_follow_up' || 'follow_up' => const [
            ClassSheetColumn(label: 'المشاركة'),
            ClassSheetColumn(label: 'الواجبات'),
            ClassSheetColumn(label: 'المهام الأدائية'),
            ClassSheetColumn(label: 'ملاحظات'),
          ],
        'skills' => const [
            ClassSheetColumn(label: 'المهارة 1'),
            ClassSheetColumn(label: 'المهارة 2'),
            ClassSheetColumn(label: 'المهارة 3'),
            ClassSheetColumn(label: 'المهارة 4'),
            ClassSheetColumn(label: 'التقييم العام'),
          ],
        'blank' || 'custom' => const [
            ClassSheetColumn(label: 'عمود 1'),
            ClassSheetColumn(label: 'عمود 2'),
            ClassSheetColumn(label: 'عمود 3'),
            ClassSheetColumn(label: 'عمود 4'),
            ClassSheetColumn(label: 'عمود 5'),
          ],
        _ => const [
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
