import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

enum GenerationSource {
  aiOnly,
  mixed,
}
abstract class ExamInfoState {}

class ExamInfoInitial extends ExamInfoState {}

class ExamInfoLoading extends ExamInfoState {}

class ExamInfoError extends ExamInfoState {
  final String message;
  ExamInfoError(this.message);
}

class ExamInfoUpdated extends ExamInfoState {
  final CurriculumStageModel? selectedStage;
  final CurriculumGradeModel? selectedGrade;
  final CurriculumSubjectModel? selectedSubject;
  final List<CurriculumStageModel> stages;
  final String difficulty;
  final GenerationSource generationSource;
  final Map<int, List<int>> selectedBankQuestionIds;

  ExamInfoUpdated({
    required this.selectedStage,
    required this.selectedGrade,
    required this.selectedSubject,
    required this.stages,
    required this.difficulty,
    required this.generationSource,
    required this.selectedBankQuestionIds,
  });
}

class ExamInfoCubit extends Cubit<ExamInfoState> {
  ExamInfoCubit() : super(ExamInfoInitial()) {
    _loadSubjects();
  }

  CurriculumStageModel? selectedStage;
  CurriculumGradeModel? selectedGrade;
  CurriculumSubjectModel? selectedSubject;
  
  String difficulty = 'medium';
  GenerationSource generationSource = GenerationSource.aiOnly;
  final Map<int, List<int>> selectedBankQuestionIds = {};
  
  List<CurriculumStageModel> stages = [];

  Future<void> _loadSubjects() async {
    emit(ExamInfoLoading());
    final result = await ApiService.getSubjects();
    result.fold(
      (dynamic failure) => emit(ExamInfoError(failure?.message ?? 'Unknown error')),
      (data) {
        stages = data;
        _emitUpdated();
      },
    );
  }

  void retry() {
    _loadSubjects();
  }

  void updateInfo({
    CurriculumStageModel? stage,
    CurriculumGradeModel? grade,
    CurriculumSubjectModel? subject,
    String? difficulty,
  }) {
    if (stage != null) {
      selectedStage = stage;
      selectedGrade = null; // reset grade when stage changes
      selectedSubject = null; // reset subject when stage changes
    }
    if (grade != null) {
      selectedGrade = grade;
      selectedSubject = null; // reset subject when grade changes
    }
    if (subject != null) {
      selectedSubject = subject;
    }
    if (difficulty != null) {
      this.difficulty = difficulty;
    }

    _emitUpdated();
  }

  void updateSelectedBankQuestions(Map<int, List<int>> questionIdsMap) {
    selectedBankQuestionIds.clear();
    selectedBankQuestionIds.addAll(questionIdsMap);
    _emitUpdated();
  }

  void updateGenerationSource(GenerationSource source) {
    generationSource = source;
    _emitUpdated();
  }

  void _emitUpdated() {
    emit(ExamInfoUpdated(
      selectedStage: selectedStage,
      selectedGrade: selectedGrade,
      selectedSubject: selectedSubject,
      stages: stages,
      difficulty: difficulty,
      generationSource: generationSource,
      selectedBankQuestionIds: Map.from(selectedBankQuestionIds),
    ));
  }

  bool get isValid => 
    selectedStage != null && 
    selectedGrade != null && 
    selectedSubject != null && 
    difficulty.isNotEmpty;
}
