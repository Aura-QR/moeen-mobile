import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';
import 'package:moean/features/presentations/data/repositories/presentations_repository.dart';
import 'package:moean/features/presentations/domain/services/pptx_generator_service.dart';
import 'package:share_plus/share_plus.dart';
import 'presentations_state.dart';

class PresentationsCubit extends Cubit<PresentationsState> {
  final PresentationsRepository repository;

  PresentationsCubit(this.repository) : super(PresentationsInitial()) {
    _loadSubjects();
  }

  CurriculumStageModel? selectedStage;
  String? selectedTrack;
  CurriculumGradeModel? selectedGrade;
  CurriculumSubjectModel? selectedSubject;
  CurriculumChapterModel? selectedUnit;
  CurriculumLessonModel? selectedLesson;

  List<CurriculumStageModel> stages = [];
  SubjectDetailsModel? subjectDetails;

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
  
  bool isDataLoading = false;
  String? dataErrorMessage;

  String selectedTemplate = 'emerald-green';
  String selectedSlidesCount = '8';

  bool get canCreate =>
      selectedStage != null &&
      selectedGrade != null &&
      selectedSubject != null &&
      selectedUnit != null &&
      selectedLesson != null;

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
    String? track,
    CurriculumGradeModel? grade,
    CurriculumSubjectModel? subject,
    CurriculumChapterModel? unit,
    CurriculumLessonModel? lesson,
    String? template,
    String? slidesCount,
  }) {
    if (stage != null) {
      selectedStage = stage;
      selectedTrack = null;
      selectedGrade = null;
      selectedSubject = null;
      selectedUnit = null;
      selectedLesson = null;
      subjectDetails = null;
    }
    if (track != null) {
      selectedTrack = track;
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
      "template_id": selectedTemplate,
      "slides_count": int.tryParse(selectedSlidesCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 8,
      "slide_count": int.tryParse(selectedSlidesCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 8,
      "stage": selectedStage!.name,
      "track": selectedTrack ?? selectedGrade!.track ?? "",
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
      (error) {
        if (error.contains('Webhook returned HTTP 200') || error.contains('not valid JSON')) {
          // The n8n webhook might have started generation in the background but failed to return a JSON response.
          // Treat this as 'pending' and start polling.
          _pollPresentation(lessonId, selectedTemplate);
        } else {
          emit(PresentationsError(error));
        }
      },
      (presentation) {
        if (presentation.status == 'ready') {
          generatedPresentation = presentation;
          emit(PresentationsSuccess(presentation));
        } else if (presentation.status == 'failed') {
          emit(PresentationsError(presentation.generationError ?? 'فشل في إنشاء العرض'));
        } else {
          // Poll
          _pollPresentation(lessonId, selectedTemplate);
        }
      },
    );
  }

  Future<void> downloadPresentation() async {
    if (generatedPresentation == null) return;
    try {
      final title = selectedLesson?.title ?? 'Presentation';
      final path = await PptxGeneratorService.generatePresentation(
        generatedPresentation!, 
        title,
        subjectName: selectedSubject?.name ?? '',
        gradeName: selectedGrade?.name ?? '',
        unitName: selectedUnit?.title ?? '',
      );
      await Share.shareXFiles([XFile(path)], text: 'Presentation: $title');
    } catch (e) {
      // emit an error if needed, but since it's a download action we might just print or show a toast via UI
      print('Error generating PPTX: $e');
    }
  }

  void _pollPresentation(int lessonId, String templateId) async {
    int attempts = 0;
    while (attempts < 20) {
      await Future.delayed(const Duration(seconds: 3));
      if (isClosed) return;
      attempts++;

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

      if (stopPolling) return;
    }
    
    if (!isClosed) {
      emit(PresentationsError('استغرق إنشاء العرض وقتاً أطول من المعتاد. يرجى المحاولة لاحقاً.'));
    }
  }

  void reset() {
    selectedStage = null;
    selectedTrack = null;
    selectedGrade = null;
    selectedSubject = null;
    selectedUnit = null;
    selectedLesson = null;
    subjectDetails = null;
    selectedTemplate = 'emerald-green';
    selectedSlidesCount = '8';
    generatedPresentation = null;
    emit(PresentationsInitial());
  }
}
