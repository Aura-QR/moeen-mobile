import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:moean/features/schedule/presentation/widgets/schedule_bottom_sheet.dart';

class ClassCard extends StatefulWidget {
  final ClassModel classModel;

  const ClassCard({super.key, required this.classModel});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  bool _isExpanded = false;
  Map<String, dynamic>? _selectedLessonMap;

  final List<String> _fallbackLessons = [
    'lesson_2',
    'lesson_1',
    'review',
    'applied_activity',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLessonMap = null;
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      ScheduleCubit.get(context).fetchAvailableLessonsIfNeeded();
    }
  }

  void _showActions(BuildContext context) {
    final cubit = ScheduleCubit.get(context);
    
    ClassModel activeClass = widget.classModel;
    if (_selectedLessonMap != null) {
      final selectedId = int.tryParse(_selectedLessonMap!['lesson_id']?.toString() ?? '') ?? 
                         int.tryParse(_selectedLessonMap!['id']?.toString() ?? '') ?? widget.classModel.lessonId;
      final selectedTitle = _selectedLessonMap!['title']?.toString() ?? 
                            _selectedLessonMap!['lesson_title']?.toString() ?? 
                            _selectedLessonMap!['name']?.toString() ?? 
                            _selectedLessonMap!['value']?.toString() ?? widget.classModel.lessonTitle;
                            
      activeClass = ClassModel(
        id: widget.classModel.id,
        periodNumber: widget.classModel.periodNumber,
        lessonTitle: selectedTitle,
        classroomId: widget.classModel.classroomId,
        status: widget.classModel.status,
        dayOfWeek: widget.classModel.dayOfWeek,
        realSchoolId: widget.classModel.realSchoolId,
        timeTaleId: widget.classModel.timeTaleId,
        subjectId: widget.classModel.subjectId,
        lessonId: selectedId,
        time: widget.classModel.time,
        date: widget.classModel.date,
        encryptedToken: widget.classModel.encryptedToken,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: ScheduleBottomSheet(classModel: activeClass),
      ),
    );
  }

  Color _getStatusColor(ClassStatus status) {
    switch (status) {
      case ClassStatus.waiting:
        return ColorsManager.statusWaiting;
      case ClassStatus.prepared:
        return ColorsManager.statusSuccess;
      case ClassStatus.notPrepared:
        return ColorsManager.statusWarning;
      case ClassStatus.activity:
        return ColorsManager.statusActivity;
    }
  }

  List<Map<String, dynamic>> _getAvailableLessonsForThisClass() {
    final state = ScheduleCubit.get(context).state;
    if (state is ScheduleLoaded && state.availableLessons != null) {
      final available = state.availableLessons!;
      try {
        final timeTableId = widget.classModel.timeTaleId;
        final subjectId = widget.classModel.subjectId.toString();
        
        dynamic targetList;

        if (timeTableId.isNotEmpty && available.containsKey(timeTableId)) {
          targetList = available[timeTableId];
        } else if (subjectId != '0' && available.containsKey(subjectId)) {
          targetList = available[subjectId];
        } else if (available.containsKey('data')) {
           final dataObj = available['data'];
           
           if (dataObj is List) {
             for (var item in dataObj) {
               if (item is Map && item['time_table_id']?.toString() == timeTableId) {
                 targetList = item['lessons'] ?? item['available_lessons'];
                 break;
               }
             }
             if (targetList == null && dataObj.isNotEmpty && dataObj.first is Map) {
               if (dataObj.first.containsKey('lesson_id') || dataObj.first.containsKey('id')) {
                 targetList = dataObj;
               }
             }
           } else if (dataObj is Map) {
             if (dataObj.containsKey(timeTableId)) {
               targetList = dataObj[timeTableId];
             } else if (dataObj.containsKey(subjectId)) {
               targetList = dataObj[subjectId];
             } else if (dataObj.values.length == 1 && dataObj.values.first is List) {
               targetList = dataObj.values.first;
             }
           }
        } else if (available.containsKey('periods')) {
           final periodsList = available['periods'];
           if (periodsList is List) {
             for (var period in periodsList) {
               if (period is Map && (period['time_table_id']?.toString() == timeTableId || period['subject_id']?.toString() == subjectId)) {
                 targetList = period['available_lessons'] ?? period['lessons'];
                 if (targetList != null && (targetList as List).isNotEmpty) break;
               }
             }
           }
        } else if (available.containsKey('lessons')) {
           targetList = available['lessons'];
        } else {
           var lists = available.values.whereType<List>().toList();
           if (lists.isNotEmpty) {
             targetList = lists.first;
           }
        }
        
        if (targetList is List) {
          return targetList.map((e) => e is Map ? Map<String, dynamic>.from(e) : {'value': e.toString()}).toList();
        }
      } catch (e) {
        debugPrint('Error parsing available lessons: $e');
      }
    }
    return [];
  }

  String _getLessonDisplayName(Map<String, dynamic> lesson) {
    return lesson['title']?.toString() ?? 
           lesson['lesson_title']?.toString() ?? 
           lesson['name']?.toString() ?? 
           lesson['value']?.toString() ?? 'Lesson';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLesson = widget.classModel.lessonTitle != null;
    final bool isActivity = widget.classModel.status == ClassStatus.activity;

    return GestureDetector(
      onTap: (isActivity || !hasLesson) ? null : () => _showActions(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isExpanded
              ? ColorsManager.brandMint.withValues(alpha: 0.2)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded
                ? ColorsManager.primaryColor
                : (hasLesson ? _getStatusColor(widget.classModel.status) : ColorsManager.borderLightGray),
            width: (hasLesson && widget.classModel.status == ClassStatus.prepared) ? 2.0 : (_isExpanded ? 1.5 : 1.0),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appTranslation().get(widget.classModel.periodKey),
                        style: TextStylesManager.regular12
                            .copyWith(color: ColorsManager.primaryColor),
                      ),
                      verticalSpace4,
                      Text(
                        _selectedLessonMap != null 
                            ? _getLessonDisplayName(_selectedLessonMap!) 
                            : (widget.classModel.lessonTitle ?? appTranslation().get('no_classes')),
                        style: TextStylesManager.bold18
                            .copyWith(color: ColorsManager.mainText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace4,
                      if (hasLesson && widget.classModel.classroomId.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 14,
                              color: ColorsManager.primaryColor,
                            ),
                            horizontalSpace4,
                            Text(
                              widget.classModel.classroomId,
                              style: TextStylesManager.regular12
                                  .copyWith(color: ColorsManager.secondaryText),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.classModel.time.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: ColorsManager.secondaryText,
                          ),
                          horizontalSpace4,
                          Text(
                            widget.classModel.time,
                            style: TextStylesManager.regular12
                                .copyWith(color: ColorsManager.secondaryText),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    verticalSpace16,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.classModel.lessonTitle != null || widget.classModel.classroomId.isNotEmpty)
                          StatusIcon(status: widget.classModel.status, size: 28)
                        else
                          const SizedBox(width: 28, height: 28),
                        if (!isActivity && hasLesson) ...[
                          horizontalSpace12,
                          GestureDetector(
                            onTap: _toggleExpand,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isExpanded
                                    ? ColorsManager.brandMint
                                    : ColorsManager.scheduleBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_left,
                                color: _isExpanded
                                    ? ColorsManager.primaryColor
                                    : ColorsManager.secondaryText,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (_isExpanded && hasLesson) ...[
              verticalSpace16,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: ColorsManager.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorsManager.borderLightGray),
                ),
                child: Builder(
                  builder: (context) {
                    final dynamicLessons = _getAvailableLessonsForThisClass();
                    final bool useDynamic = dynamicLessons.isNotEmpty;
                    
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLessonMap != null 
                            ? _getLessonDisplayName(_selectedLessonMap!) 
                            : (useDynamic ? null : null), // null so hint shows
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: ColorsManager.primaryColor),
                        borderRadius: BorderRadius.circular(16),
                        dropdownColor: ColorsManager.background,
                        hint: Row(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              color: ColorsManager.primaryColor,
                              size: 20,
                            ),
                            horizontalSpace8,
                            Expanded(
                              child: Text(
                                _selectedLessonMap != null 
                                    ? _getLessonDisplayName(_selectedLessonMap!)
                                    : (widget.classModel.lessonTitle ?? ''),
                                style: TextStylesManager.regular12
                                    .copyWith(color: ColorsManager.mainText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != 'header') {
                            setState(() {
                              if (useDynamic) {
                                _selectedLessonMap = dynamicLessons.firstWhere(
                                  (l) => _getLessonDisplayName(l) == newValue,
                                  orElse: () => {'value': newValue},
                                );
                              } else {
                                _selectedLessonMap = {'value': newValue};
                              }
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem<String>(
                            enabled: false,
                            value: 'header',
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ColorsManager.brandMint.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '4',
                                    style: TextStylesManager.bold18.copyWith(
                                      color: ColorsManager.primaryColor,
                                    ),
                                  ),
                                ),
                                horizontalSpace12,
                                Text(
                                  appTranslation().get('choose_lesson'),
                                  style: TextStylesManager.bold18.copyWith(
                                    color: ColorsManager.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (useDynamic)
                            ...dynamicLessons.map<DropdownMenuItem<String>>((Map<String, dynamic> lessonMap) {
                              String value = _getLessonDisplayName(lessonMap);
                              bool isSelected = _selectedLessonMap != null && _getLessonDisplayName(_selectedLessonMap!) == value;
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      if (isSelected) ...[
                                        Icon(Icons.check_circle_outline, color: ColorsManager.surfacePrimary, size: 20),
                                        horizontalSpace8,
                                      ],
                                      Expanded(
                                        child: Text(
                                          value,
                                          style: TextStylesManager.regular12.copyWith(
                                            color: isSelected ? ColorsManager.surfacePrimary : ColorsManager.mainText,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          else
                            ..._fallbackLessons.map<DropdownMenuItem<String>>((String value) {
                              String translatedValue = appTranslation().get(value);
                              bool isSelected = _selectedLessonMap != null && _selectedLessonMap!['value'] == value;
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      if (isSelected) ...[
                                        Icon(Icons.check_circle_outline, color: ColorsManager.surfacePrimary, size: 20),
                                        horizontalSpace8,
                                      ],
                                      Text(
                                        translatedValue,
                                        style: TextStylesManager.regular12.copyWith(
                                          color: isSelected ? ColorsManager.surfacePrimary : ColorsManager.mainText,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return ['header', if (useDynamic) ...dynamicLessons.map((e) => _getLessonDisplayName(e)) else ..._fallbackLessons].map<Widget>((String value) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  color: ColorsManager.primaryColor,
                                  size: 20,
                                ),
                                horizontalSpace8,
                                Expanded(
                                  child: Text(
                                    _selectedLessonMap != null 
                                        ? _getLessonDisplayName(_selectedLessonMap!) 
                                        : widget.classModel.lessonTitle!,
                                    style: TextStylesManager.regular12
                                        .copyWith(color: ColorsManager.mainText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    );
                  }
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
