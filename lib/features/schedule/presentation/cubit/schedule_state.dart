import 'package:moean/features/schedule/data/models/schedule_models.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<DayModel> days;
  final List<ClassModel> classes;
  final List<ClassModel> allClasses;
  final int selectedDayIndex;

  ScheduleLoaded({
    required this.days,
    required this.classes,
    required this.allClasses,
    required this.selectedDayIndex,
  });
}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);
}
