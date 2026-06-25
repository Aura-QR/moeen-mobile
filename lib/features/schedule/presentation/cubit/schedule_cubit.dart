import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/madrasati_session_service.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  StreamSubscription? _sessionActiveSubscription;

  ScheduleCubit() : super(ScheduleInitial()) {
    _sessionActiveSubscription = sl<MadrasatiSessionService>().onSessionActive.listen((_) {
      // Re-fetch schedule when session is refreshed
      if (state is ScheduleError) {
        getSchedule();
      }
    });
  }

  static ScheduleCubit get(BuildContext context) =>
      BlocProvider.of<ScheduleCubit>(context);

  @override
  void onChange(Change<ScheduleState> change) {
    super.onChange(change);
    debugPrint('🔄 ScheduleCubit State Changed: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }
  Future<void> getSchedule() async {
    final weekDate = _currentWeekDate();
    emit(ScheduleLoading());
    final result = await ApiService.syncSchedule(weekDate: weekDate);
    if (isClosed) return;
    result.fold(
      (error) {
        debugPrint('❌ Sync Error Response: $error');
        emit(ScheduleError(error));
      },
      (data) => _handleData(data, weekDate),
    );
  }

  Future<void> refreshSchedule() async {
    emit(ScheduleLoading());
    final weekDate = _currentWeekDate();
    final result = await ApiService.getSchedule(weekDate: weekDate);
    if (isClosed) return;
    result.fold(
      (error) {
        debugPrint('❌ Schedule Error Response: $error');
        emit(ScheduleError(error));
      },
      (data) => _handleData(data, weekDate),
    );
  }

  Future<void> syncSchedule() async {
    await getSchedule();
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
      encryptedToken: classModel.encryptedToken,
    );

    result.fold(
      (error) {
        debugPrint('❌ Lesson Preparation Error: $error');
        // emit(SchedulePrepareError(error)); // Handle error state if UI needs to react
      },
      (data) {
        debugPrint('✅ Lesson Preparation Success!');
        debugPrint('   - Response: $data');
        
        final preparationId = int.tryParse(data['preparation_id']?.toString() ?? '');
        if (preparationId != null) {
          _startPolling(preparationId);
        }
      },
    );
  }

  Timer? _pollingTimer;

  void _startPolling(int preparationId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      debugPrint('⏳ Polling preparation status for ID: $preparationId');
      final result = await ApiService.checkPreparationStatus(preparationId: preparationId);
      
      result.fold(
        (error) {
          debugPrint('❌ Polling Error: $error');
          timer.cancel();
        },
        (data) {
          debugPrint('✅ Polling Response: $data');
          final status = data['status'] as String?;
          if (status == 'completed' || status == 'success' || status == 'failed' || status == 'error') {
            timer.cancel();
            if (status == 'completed' || status == 'success') {
               refreshSchedule();
            }
          }
        },
      );
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _sessionActiveSubscription?.cancel();
    return super.close();
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
      availableLessons: current.availableLessons,
    ));
  }

  Future<void> fetchAvailableLessonsIfNeeded() async {
    if (state is! ScheduleLoaded) return;
    final current = state as ScheduleLoaded;
    if (current.availableLessons != null && current.availableLessons!.isNotEmpty) return;

    final weekDate = _currentWeekDate();
    final result = await ApiService.getAvailableLessons(weekDate: weekDate);
    if (isClosed) return;
    result.fold(
      (error) => debugPrint('❌ Available Lessons Error: $error'),
      (data) {
        emit(ScheduleLoaded(
          days: current.days,
          classes: current.classes,
          allClasses: current.allClasses,
          selectedDayIndex: current.selectedDayIndex,
          availableLessons: data,
        ));
      },
    );
  }

  void _handleData(Map<String, dynamic> data, String weekDate) {
    debugPrint('✅ ScheduleCubit Success Full Response: $data');

    final weekStart = data['week_start'] as String? ?? weekDate;
    final days = _parseDays(weekStart, <String, dynamic>{}); // mock doesn't need rawSchedule for days
    final allClasses = <ClassModel>[];

    final daysList = data['days'] is List 
        ? data['days'] as List 
        : (data['schedule'] is List ? data['schedule'] as List : null);
    final fakeData = data['data'] is List ? data['data'] as List : null;

    if (daysList != null) {
      for (final dayItem in daysList) {
        if (dayItem is Map && dayItem['periods'] is List) {
          final int dayOfWeekValue = dayItem['day_of_week'] as int? ?? 0;
          final int normalizedDayOfWeek = dayOfWeekValue + 1; // 0 -> 1 (Sunday)
          for (final periodItem in dayItem['periods']) {
            if (periodItem is Map) {
              final p = Map<String, dynamic>.from(periodItem);
              p['day_of_week'] = normalizedDayOfWeek;
              allClasses.add(ClassModel.fromJson(p));
            }
          }
        }
      }
    } else if (fakeData != null) {
      // Parse fake API structure
      for (final item in fakeData) {
        if (item is Map) {
          allClasses.add(ClassModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else {
      // Parse old structure
      final scheduleRaw = data['schedule'] ?? data['data'];
      final rawSchedule = scheduleRaw is Map
          ? Map<String, dynamic>.from(scheduleRaw)
          : <String, dynamic>{};
      allClasses.addAll(_parseAllClasses(rawSchedule));
    }

    allClasses.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

    final firstDayClasses = days.isNotEmpty
        ? _classesForDay(allClasses, days.first.dayOfWeek)
        : <ClassModel>[];

    final newState = ScheduleLoaded(
      days: days,
      classes: firstDayClasses,
      allClasses: allClasses,
      selectedDayIndex: 0,
      availableLessons: null,
    );

    debugPrint('✅ ScheduleCubit Success: week_start=$weekStart | days=${days.length} | classes=${allClasses.length}');

    if (!isClosed) {
      emit(newState);
    }
  }



  DateTime? _currentWeekStart;

  String _currentWeekDate() {
    if (_currentWeekStart == null) {
      final now = DateTime.now();
      // Dart weekday: Monday=1 … Sunday=7
      final daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
      _currentWeekStart = now.subtract(Duration(days: daysFromSunday));
    }
    return '${_currentWeekStart!.year}-'
        '${_currentWeekStart!.month.toString().padLeft(2, '0')}-'
        '${_currentWeekStart!.day.toString().padLeft(2, '0')}';
  }

  void nextWeek() {
    _currentWeekDate();
    _currentWeekStart = _currentWeekStart!.add(const Duration(days: 7));
    getSchedule();
  }

  void previousWeek() {
    _currentWeekDate();
    _currentWeekStart = _currentWeekStart!.subtract(const Duration(days: 7));
    getSchedule();
  }

  // ---------------------------------------------------------------------------
  // Private — parse helpers (no Widget returned — compliant with rules.md)
  // ---------------------------------------------------------------------------

  List<DayModel> _parseDays(
    String weekStart,
    Map<String, dynamic> rawSchedule,
  ) {
    final startDate = DateTime.parse(weekStart);
    // Always show Sunday (1) to Thursday (5)
    final sortedKeys = ['1', '2', '3', '4', '5'];

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
  ) {
    final dayClasses =
        allClasses.where((c) => c.dayOfWeek == dayOfWeek).toList();
    if (dayClasses.isEmpty) return [];

    // Fixed to 8 periods as standard
    const maxPeriod = 8;

    final filledClasses = <ClassModel>[];
    for (int i = 1; i <= maxPeriod; i++) {
      final existing = dayClasses.where((c) => c.periodNumber == i).toList();
      if (existing.isNotEmpty) {
        filledClasses.addAll(existing);
      } else {
        filledClasses.add(
          ClassModel(
            id: 'empty_${dayOfWeek}_$i',
            periodNumber: i,
            classroomId: '',
            status: ClassStatus.notPrepared,
            dayOfWeek: dayOfWeek,
            lessonTitle: null,
          ),
        );
      }
    }
    return filledClasses;
  }

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
