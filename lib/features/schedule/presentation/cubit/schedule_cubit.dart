import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleInitial());

  static ScheduleCubit get(BuildContext context) => BlocProvider.of<ScheduleCubit>(context);

  final List<DayModel> _mockDays = [
    DayModel(nameKey: 'sunday', date: '12 مايو'),
    DayModel(nameKey: 'monday', date: '13 مايو'),
    DayModel(nameKey: 'tuesday', date: '14 مايو'),
    DayModel(nameKey: 'wednesday', date: '15 مايو'),
    DayModel(nameKey: 'thursday', date: '16 مايو'),
  ];

  final List<ClassModel> _mockClasses = [
    ClassModel(
      id: '1',
      time: 'ص 8:45 - ص 9:45',
      numberKey: 'class_1',
      subjectKey: 'math',
      gradeKey: 'grade_6',
      status: ClassStatus.prepared,
    ),
    ClassModel(
      id: '2',
      time: 'ص 9:45 - ص 10:45',
      numberKey: 'class_2',
      subjectKey: 'arabic_language',
      gradeKey: 'grade_6',
      status: ClassStatus.prepared,
      lessonTitle: 'الدرس: أسلوب الاستفهام وأغراضه البلاغية',
    ),
    ClassModel(
      id: '3',
      time: 'ص 10:45 - ص 11:05',
      numberKey: 'class_3',
      subjectKey: 'math',
      gradeKey: 'grade_5_short',
      status: ClassStatus.notPrepared,
    ),
    ClassModel(
      id: '4',
      time: 'ص 11:05 - م 12:45',
      numberKey: 'class_4',
      subjectKey: 'science',
      gradeKey: 'grade_6',
      status: ClassStatus.waiting,
    ),
    ClassModel(
      id: '5',
      time: 'م 12:45 - م 1:00',
      numberKey: 'class_5',
      subjectKey: 'islamic_education',
      gradeKey: 'grade_6',
      status: ClassStatus.activity,
    ),
  ];

  void getSchedule() {
    emit(ScheduleLoading());
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(ScheduleLoaded(
        days: _mockDays,
        classes: _mockClasses,
        selectedDayIndex: 0,
      ));
    });
  }

  void selectDay(int index) {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      emit(ScheduleLoaded(
        days: currentState.days,
        classes: currentState.classes,
        selectedDayIndex: index,
      ));
    }
  }
}
