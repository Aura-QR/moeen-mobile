import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';

/// Key used to persist the last successful schedule API response.
const _kScheduleCacheKey = 'cached_schedule';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleInitial());

  static ScheduleCubit get(BuildContext context) =>
      BlocProvider.of<ScheduleCubit>(context);

  @override
  void onChange(Change<ScheduleState> change) {
    super.onChange(change);
    debugPrint('🔄 ScheduleCubit State Changed: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }
  Future<void> getSchedule() async {
    final weekDate = _currentWeekDate();

    // 1. Try to restore from cache first so the UI isn't blank.
    final restored = _loadFromCache();
    if (restored != null) {
      emit(restored);
    } else {
      emit(ScheduleLoading());
    }

    // 2. Always refresh from network.
    await _fetchAndEmit(weekDate);
  }

  Future<void> syncSchedule() async {
    emit(ScheduleLoading());
    final weekDate = _currentWeekDate();

    final result = await ApiService.syncSchedule(weekDate: weekDate);
    result.fold(
      (error) {
        debugPrint('❌ Sync Error Response: $error');
        emit(ScheduleError(error));
      },
      (response) {
        debugPrint('✅ Sync Success Response: $response');
        debugPrint('✅ Sync Success, now fetching schedule...');
        _fetchAndEmit(weekDate);
      },
    );
  }

  Future<void> prepareLesson({
    required ClassModel classModel,
    required List<String> selectedModules,
  }) async {
    debugPrint('🚀 Starting Lesson Preparation for: ${classModel.lessonTitle}');
    debugPrint('   - Lesson ID: ${classModel.lessonId}');
    debugPrint('   - Subject ID: ${classModel.subjectId}');
    debugPrint('   - Classroom ID: ${classModel.classroomId}');
    debugPrint('   - Modules: $selectedModules');

    // emit(SchedulePrepareLoading()); // Could emit a specific loading state if needed.

    final result = await ApiService.prepareLesson(
      lessonId: classModel.lessonId,
      subjectId: classModel.subjectId,
      classroomId: classModel.classroomId,
      schoolMadrasatiId: classModel.realSchoolId,
      timeTableId: classModel.timeTaleId,
      selectedModules: selectedModules,
    );

    result.fold(
      (error) {
        debugPrint('❌ Lesson Preparation Error: $error');
        // emit(SchedulePrepareError(error)); // Handle error state if UI needs to react
      },
      (data) {
        debugPrint('✅ Lesson Preparation Success!');
        debugPrint('   - Response: $data');
        // emit(SchedulePrepareSuccess(data)); // Handle success state if UI needs to react
      },
    );
  }

  void selectDay(int index) {
    if (state is! ScheduleLoaded) return;
    final current = state as ScheduleLoaded;
    final selected = current.days[index];
    emit(ScheduleLoaded(
      days: current.days,
      classes: _classesForDay(current.allClasses, selected.dayOfWeek),
      allClasses: current.allClasses,
      selectedDayIndex: index,
    ));
  }

  Future<void> _fetchAndEmit(String weekDate) async {
    final result = await ApiService.getSchedule(weekDate: weekDate);

    result.fold(
      (error) {
        debugPrint('❌ ScheduleCubit Error Response: $error');
        // Only replace the current state with error if we have no cached data.
        if (state is! ScheduleLoaded) emit(ScheduleError(error));
      },
      (data) {
        debugPrint('✅ ScheduleCubit Success Full Response: $data');
        final weekStart = data['week_start'] as String? ?? weekDate;
        final scheduleRaw = data['schedule'];
        final rawSchedule = scheduleRaw is Map
            ? Map<String, dynamic>.from(scheduleRaw)
            : <String, dynamic>{};

        final days = _parseDays(weekStart, rawSchedule);
        final allClasses = _parseAllClasses(rawSchedule);
        final firstDayClasses = days.isNotEmpty
            ? _classesForDay(allClasses, days.first.dayOfWeek)
            : <ClassModel>[];

        final newState = ScheduleLoaded(
          days: days,
          classes: firstDayClasses,
          allClasses: allClasses,
          selectedDayIndex: 0,
        );

        debugPrint('✅ ScheduleCubit Success: week_start=${data['week_start']} | days=${days.length} | classes=${allClasses.length}');

        // Persist to cache so next launch is instant.
        _saveToCache(data);

        emit(newState);
      },
    );
  }

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      await CacheHelper.saveData(
        key: _kScheduleCacheKey,
        value: jsonEncode(data),
      );
      debugPrint('✅ Schedule cached successfully ' );
    } catch (error) {
      debugPrint('❌ Failed to cache schedule: $error');
      // Cache write failure is non-critical — silently ignore.
    }
  }

  /// Restores the last cached [ScheduleLoaded] state, or null if none exists.
  ScheduleLoaded? _loadFromCache() {
    try {
      final raw = CacheHelper.getData(key: _kScheduleCacheKey);
      if (raw == null || raw is! String) {
        debugPrint('ℹ️ No cached schedule found');
        return null;
      }

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final weekStart = data['week_start'] as String? ?? _currentWeekDate();
      final scheduleRaw = data['schedule'];
      final rawSchedule = scheduleRaw is Map
          ? Map<String, dynamic>.from(scheduleRaw)
          : <String, dynamic>{};

      final days = _parseDays(weekStart, rawSchedule);
      final allClasses = _parseAllClasses(rawSchedule);
      final firstDayClasses = days.isNotEmpty
          ? _classesForDay(allClasses, days.first.dayOfWeek)
          : <ClassModel>[];

      debugPrint('✅ Cached schedule loaded successfully');
      return ScheduleLoaded(
        days: days,
        classes: firstDayClasses,
        allClasses: allClasses,
        selectedDayIndex: 0,
      );
    } catch (error) {
      debugPrint('❌ Failed to load cached schedule: $error');
      return null;
    }
  }

  String _currentWeekDate() {
    final now = DateTime.now();
    // Dart weekday: Monday=1 … Sunday=7
    final daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
    final weekStart = now.subtract(Duration(days: daysFromSunday));
    return '${weekStart.year}-'
        '${weekStart.month.toString().padLeft(2, '0')}-'
        '${weekStart.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Private — parse helpers (no Widget returned — compliant with rules.md)
  // ---------------------------------------------------------------------------

  List<DayModel> _parseDays(
    String weekStart,
    Map<String, dynamic> rawSchedule,
  ) {
    final startDate = DateTime.parse(weekStart);
    final sortedKeys = rawSchedule.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    const dayNameKeys = <String, String>{
      '1': 'sunday',
      '2': 'monday',
      '3': 'tuesday',
      '4': 'wednesday',
      '5': 'thursday',
    };

    return sortedKeys.map((key) {
      final dayOfWeek = int.parse(key);
      final dayDate = startDate.add(Duration(days: dayOfWeek - 1));
      return DayModel(
        nameKey: dayNameKeys[key] ?? 'day_$key',
        date: '${dayDate.day} ${_arabicMonth(dayDate.month)}',
        dayOfWeek: dayOfWeek,
      );
    }).toList();
  }

  List<ClassModel> _parseAllClasses(Map<String, dynamic> rawSchedule) {
    final classes = <ClassModel>[];
    rawSchedule.forEach((_, dayList) {
      if (dayList is List) {
        for (final item in dayList) {
          if (item is Map) {
            classes.add(ClassModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
    });
    classes.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    return classes;
  }

  List<ClassModel> _classesForDay(
    List<ClassModel> allClasses,
    int dayOfWeek,
  ) =>
      allClasses.where((c) => c.dayOfWeek == dayOfWeek).toList();

  /// Arabic month names — data utility, not UI label.
  String _arabicMonth(int month) {
    const names = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return names[month];
  }
}
