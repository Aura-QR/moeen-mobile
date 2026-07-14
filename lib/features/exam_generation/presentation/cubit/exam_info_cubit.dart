import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

abstract class ExamInfoState {}

class ExamInfoInitial extends ExamInfoState {}

class ExamInfoLoading extends ExamInfoState {}

class ExamInfoError extends ExamInfoState {
  final String message;
  ExamInfoError(this.message);
}

class ExamInfoUpdated extends ExamInfoState {
  final String gradeStage;
  final String grade;
  final String subject;
  final UnitModel? selectedUnit;
  final List<SubjectGroupModel> subjectsData;
  final String difficulty;

  ExamInfoUpdated({
    required this.gradeStage,
    required this.grade,
    required this.subject,
    required this.selectedUnit,
    required this.subjectsData,
    required this.difficulty,
  });
}

class ExamInfoCubit extends Cubit<ExamInfoState> {
  ExamInfoCubit() : super(ExamInfoInitial()) {
    _loadSubjects();
  }

  String gradeStage = '';
  String grade = '';
  String subject = '';
  UnitModel? selectedUnit;
  String difficulty = 'medium';
  
  List<SubjectGroupModel> subjectsData = [];

  Future<void> _loadSubjects() async {
    emit(ExamInfoLoading());
    final result = await ApiService.getSubjects();
    result.fold(
      (dynamic failure) => emit(ExamInfoError(failure?.message ?? 'Unknown error')),
      (data) {
        subjectsData = data;
        _emitUpdated();
      },
    );
  }

  void retry() {
    _loadSubjects();
  }

  void updateInfo({
    String? gradeStage,
    String? grade,
    String? subject,
    UnitModel? selectedUnit,
    String? difficulty,
  }) {
    if (gradeStage != null) {
      this.gradeStage = gradeStage;
    }
    if (grade != null) {
      this.grade = grade;
    }
    if (subject != null) {
      this.subject = subject;
      this.selectedUnit = null; // reset unit when subject changes
    }
    if (selectedUnit != null) {
      this.selectedUnit = selectedUnit;
    }
    if (difficulty != null) {
      this.difficulty = difficulty;
    }

    _emitUpdated();
  }

  void _emitUpdated() {
    emit(ExamInfoUpdated(
      gradeStage: gradeStage,
      grade: grade,
      subject: subject,
      selectedUnit: selectedUnit,
      subjectsData: subjectsData,
      difficulty: difficulty,
    ));
  }

  bool get isValid => 
    gradeStage.isNotEmpty && 
    grade.isNotEmpty && 
    subject.isNotEmpty && 
    selectedUnit != null &&
    difficulty.isNotEmpty;
}
