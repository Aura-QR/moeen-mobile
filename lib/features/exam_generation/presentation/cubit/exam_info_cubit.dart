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
  final String? selectedSemester;
  final String? selectedTrack;
  final CurriculumGradeModel? selectedGrade;
  final CurriculumSubjectModel? selectedSubject;
  final String? unitName;
  final String? examTitle;
  final List<CurriculumStageModel> stages;
  final String difficulty;
  final GenerationSource generationSource;
  final Map<int, List<int>> selectedBankQuestionIds;
  final List<String> availableUnits;
  final bool isUnitsLoading;

  ExamInfoUpdated({
    required this.selectedStage,
    required this.selectedSemester,
    required this.selectedTrack,
    required this.selectedGrade,
    required this.selectedSubject,
    this.unitName,
    this.examTitle,
    required this.stages,
    required this.difficulty,
    required this.generationSource,
    required this.selectedBankQuestionIds,
    required this.availableUnits,
    required this.isUnitsLoading,
  });
}

class ExamInfoCubit extends Cubit<ExamInfoState> {
  ExamInfoCubit() : super(ExamInfoInitial()) {
    _loadSubjects();
  }

  CurriculumStageModel? selectedStage;
  String? selectedSemester;
  String? selectedTrack;
  CurriculumGradeModel? selectedGrade;
  CurriculumSubjectModel? selectedSubject;
  String? unitName;
  String? examTitle;
  
  String difficulty = 'medium';
  GenerationSource generationSource = GenerationSource.aiOnly;
  final Map<int, List<int>> selectedBankQuestionIds = {};
  
  List<CurriculumStageModel> stages = [];
  List<String> availableUnits = [];
  bool isUnitsLoading = false;

  List<String> get availableTracks {
    if (selectedStage == null) return [];
    return selectedStage!.grades
        .map((g) => g.track)
        .whereType<String>()
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
  }

  List<CurriculumGradeModel> get availableGrades {
    if (selectedStage == null) return [];
    if (availableTracks.isNotEmpty) {
      if (selectedTrack == null) return [];
      return selectedStage!.grades.where((g) => g.track == selectedTrack).toList();
    }
    return selectedStage!.grades;
  }

  Future<void> _loadSubjects() async {
    emit(ExamInfoLoading());
    final endpoint = '/subjects';
    
    // --- Console Print ---
    print('========== API CALL ==========');
    print('ENDPOINT: $endpoint');
    print('METHOD: GET');
    print('BODY: {}');
    print('==============================');
    // ---------------------

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
    String? semester,
    String? track,
    CurriculumGradeModel? grade,
    CurriculumSubjectModel? subject,
    String? unitName,
    String? examTitle,
    String? difficulty,
  }) {
    if (stage != null) {
      selectedStage = stage;
      selectedSemester = null;
      selectedTrack = null;
      selectedGrade = null;
      selectedSubject = null;
      this.unitName = null;
      this.examTitle = null;
    }
    if (semester != null) {
      selectedSemester = semester;
    }
    if (track != null) {
      selectedTrack = track;
      selectedGrade = null;
      selectedSubject = null;
      this.unitName = null;
      this.examTitle = null;
    }
    if (grade != null) {
      selectedGrade = grade;
      selectedSubject = null;
      this.unitName = null;
      this.examTitle = null;
    }
    if (subject != null) {
      selectedSubject = subject;
      this.unitName = null;
      this.examTitle = null;
      _loadUnitsForSubject(subject.id);
    }
    if (unitName != null) {
      this.unitName = unitName;
    }
    if (examTitle != null) {
      this.examTitle = examTitle;
    }
    if (difficulty != null) {
      this.difficulty = difficulty;
    }

    _emitUpdated();
  }

  Future<void> _loadUnitsForSubject(int subjectId) async {
    isUnitsLoading = true;
    availableUnits = [];
    final endpoint = '/subjects/$subjectId/lessons';
    
    // --- Console Print ---
    print('========== API CALL ==========');
    print('ENDPOINT: $endpoint');
    print('METHOD: GET');
    print('BODY: {}');
    print('==============================');
    // ---------------------

    _emitUpdated();

    final result = await ApiService.getSubjectLessons(subjectId);

    
    isUnitsLoading = false;
    result.fold(
      (failure) {
        _emitUpdated();
      },
      (data) {
        final units = data.chapters
            .where((c) => selectedSemester == null || c.semester == selectedSemester)
            .map((c) => (c.unitName != null && c.unitName!.isNotEmpty) ? c.unitName! : c.title)
            .where((u) => u.isNotEmpty)
            .toSet()
            .toList();
        availableUnits = units;
        _emitUpdated();
      }
    );
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
      selectedSemester: selectedSemester,
      selectedTrack: selectedTrack,
      selectedGrade: selectedGrade,
      selectedSubject: selectedSubject,
      unitName: unitName,
      examTitle: examTitle,
      stages: stages,
      difficulty: difficulty,
      generationSource: generationSource,
      selectedBankQuestionIds: Map.from(selectedBankQuestionIds),
      availableUnits: availableUnits,
      isUnitsLoading: isUnitsLoading,
    ));
  }

  bool get isValid => 
    selectedStage != null && 
    selectedSemester != null &&
    (availableTracks.isEmpty || selectedTrack != null) &&
    selectedGrade != null && 
    selectedSubject != null && 
    difficulty.isNotEmpty;
}
