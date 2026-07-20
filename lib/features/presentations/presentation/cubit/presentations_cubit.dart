import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';
import 'package:moean/features/presentations/data/repositories/presentations_repository.dart';
import 'presentations_state.dart';

class PresentationsCubit extends Cubit<PresentationsState> {
  final PresentationsRepository repository;

  PresentationsCubit(this.repository) : super(PresentationsInitial()) {
    _loadSubjects();
  }

  CurriculumStageModel? selectedStage;
  CurriculumGradeModel? selectedGrade;
  CurriculumSubjectModel? selectedSubject;
  CurriculumChapterModel? selectedUnit;
  CurriculumLessonModel? selectedLesson;

  List<CurriculumStageModel> stages = [];
  SubjectDetailsModel? subjectDetails;
  
  bool isDataLoading = false;
  String? dataErrorMessage;

  String? selectedTemplate;
  String? selectedSlidesCount;

  bool get canCreate =>
      selectedStage != null &&
      selectedGrade != null &&
      selectedSubject != null &&
      selectedUnit != null &&
      selectedLesson != null &&
      selectedTemplate != null &&
      selectedSlidesCount != null;

  PresentationModel? generatedPresentation;

  Future<void> _loadSubjects() async {
    isDataLoading = true;
    dataErrorMessage = null;
    emit(PresentationsInitial());
    
    final result = await ApiService.getSubjects();
    result.fold(
      (failure) => dataErrorMessage = failure.message,
      (data) => stages = data,
    );
    
    isDataLoading = false;
    emit(PresentationsInitial());
  }

  Future<void> _loadSubjectLessons(int subjectId) async {
    isDataLoading = true;
    dataErrorMessage = null;
    emit(PresentationsInitial());
    
    final result = await ApiService.getSubjectLessons(subjectId);
    result.fold(
      (failure) => dataErrorMessage = failure.message,
      (data) => subjectDetails = data,
    );
    
    isDataLoading = false;
    emit(PresentationsInitial());
  }

  void updateSelection({
    CurriculumStageModel? stage,
    CurriculumGradeModel? grade,
    CurriculumSubjectModel? subject,
    CurriculumChapterModel? unit,
    CurriculumLessonModel? lesson,
    String? template,
    String? slidesCount,
  }) {
    if (stage != null) {
      selectedStage = stage;
      selectedGrade = null;
      selectedSubject = null;
      selectedUnit = null;
      selectedLesson = null;
      subjectDetails = null;
    }
    if (grade != null) {
      selectedGrade = grade;
      selectedSubject = null;
      selectedUnit = null;
      selectedLesson = null;
      subjectDetails = null;
    }
    if (subject != null) {
      selectedSubject = subject;
      selectedUnit = null;
      selectedLesson = null;
      subjectDetails = null;
      _loadSubjectLessons(subject.id);
    }
    if (unit != null) {
      selectedUnit = unit;
      selectedLesson = null;
    }
    if (lesson != null) selectedLesson = lesson;
    if (template != null) selectedTemplate = template;
    if (slidesCount != null) selectedSlidesCount = slidesCount;
    
    emit(PresentationsInitial());
  }

  Future<void> createPresentation() async {
    if (!canCreate) return;

    emit(PresentationsLoading());
    
    int lessonId = selectedLesson!.id;

    final payload = {
      "lesson_id": lessonId,
      "template_id": selectedTemplate ?? "default",
      "stage": selectedStage!.name,
      "track": selectedGrade!.track ?? "",
      "grade": selectedGrade!.name,
      "semester": selectedLesson!.semester,
      "subject": selectedSubject!.name,
      "unit": selectedUnit!.title,
      "chapter": selectedLesson!.title,
      "lesson_title": selectedLesson!.title,
    };

    final result = await repository.generatePresentation(
      lessonId: lessonId,
      payload: payload,
    );

    result.fold(
      (error) => emit(PresentationsError(error)),
      (presentation) {
        if (presentation.status == 'ready') {
          generatedPresentation = presentation;
          emit(PresentationsSuccess(presentation));
        } else if (presentation.status == 'failed') {
          emit(PresentationsError(presentation.generationError ?? 'فشل في إنشاء العرض'));
        } else {
          // Poll
          _pollPresentation(lessonId, selectedTemplate ?? "default");
        }
      },
    );
  }

  void _pollPresentation(int lessonId, String templateId) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      if (isClosed) return;

      final result = await repository.getPresentation(
        lessonId: lessonId,
        templateId: templateId,
      );

      bool stopPolling = false;
      result.fold(
        (error) {
          emit(PresentationsError(error));
          stopPolling = true;
        },
        (presentation) {
          if (presentation.status == 'ready') {
            generatedPresentation = presentation;
            emit(PresentationsSuccess(presentation));
            stopPolling = true;
          } else if (presentation.status == 'failed') {
            emit(PresentationsError(presentation.generationError ?? 'فشل في إنشاء العرض'));
            stopPolling = true;
          }
        },
      );

      if (stopPolling) break;
    }
  }

  void reset() {
    selectedStage = null;
    selectedGrade = null;
    selectedSubject = null;
    selectedUnit = null;
    selectedLesson = null;
    subjectDetails = null;
    selectedTemplate = null;
    selectedSlidesCount = null;
    generatedPresentation = null;
    emit(PresentationsInitial());
  }
}
