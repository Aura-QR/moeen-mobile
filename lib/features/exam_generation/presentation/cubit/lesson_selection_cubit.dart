import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

abstract class LessonSelectionState {}

class LessonSelectionInitial extends LessonSelectionState {}

class LessonSelectionLoading extends LessonSelectionState {}

class LessonSelectionError extends LessonSelectionState {
  final String message;
  LessonSelectionError(this.message);
}

class LessonSelectionUpdated extends LessonSelectionState {
  final SubjectDetailsModel? subjectDetails;
  final List<CurriculumChapterModel> filteredChapters;
  final List<CurriculumLessonModel> selectedLessons;
  final String searchQuery;
  final List<String> availableSemesters;
  final String? selectedSemester;

  LessonSelectionUpdated({
    required this.subjectDetails,
    required this.filteredChapters,
    required this.selectedLessons,
    required this.searchQuery,
    required this.availableSemesters,
    required this.selectedSemester,
  });
}

class LessonSelectionCubit extends Cubit<LessonSelectionState> {
  LessonSelectionCubit() : super(LessonSelectionInitial());

  SubjectDetailsModel? _subjectDetails;
  final List<CurriculumLessonModel> _selectedLessons = [];
  String _searchQuery = '';
  int? _currentSubjectId;
  String? _selectedSemester;
  String? _selectedUnitName;

  Future<void> loadLessonsForSubjectId(int subjectId, {String? unitName}) async {
    _selectedUnitName = unitName;
    if (_currentSubjectId == subjectId && _subjectDetails != null) {
      _emitState();
      return; // Already loaded
    }

    _currentSubjectId = subjectId;
    emit(LessonSelectionLoading());

    final result = await ApiService.getSubjectLessons(subjectId);
    
    result.fold(
      (dynamic failure) => emit(LessonSelectionError(failure?.message ?? 'Unknown error')),
      (details) {
        _subjectDetails = details;
        
        // Remove selected lessons that are no longer in this subject
        final allLessonsIds = details.chapters.expand((c) => c.lessons).map((l) => l.id).toSet();
        _selectedLessons.removeWhere((selected) => !allLessonsIds.contains(selected.id));
        
        _emitState();
      },
    );
  }

  void selectSemester(String? semester) {
    _selectedSemester = semester;
    _emitState();
  }

  void retry() {
    if (_currentSubjectId != null) {
      loadLessonsForSubjectId(_currentSubjectId!, unitName: _selectedUnitName);
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _emitState();
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');
  }

  void toggleLesson(CurriculumLessonModel lesson) {
    if (_selectedLessons.any((l) => l.id == lesson.id)) {
      _selectedLessons.removeWhere((l) => l.id == lesson.id);
    } else {
      _selectedLessons.add(lesson);
    }
    _emitState();
  }

  void removeLesson(int lessonId) {
    _selectedLessons.removeWhere((l) => l.id == lessonId);
    _emitState();
  }

  void _emitState() {
    final normalizedQuery = _normalizeArabic(_searchQuery);
    
    List<CurriculumChapterModel> filtered = [];
    if (_subjectDetails != null) {
      for (var chapter in _subjectDetails!.chapters) {
        if (_selectedSemester != null && chapter.semester != _selectedSemester) {
          continue;
        }

        if (_selectedUnitName != null && _selectedUnitName!.isNotEmpty) {
          final chapterUnitName = (chapter.unitName != null && chapter.unitName!.isNotEmpty) ? chapter.unitName! : chapter.title;
          if (chapterUnitName != _selectedUnitName) {
            continue;
          }
        }
        
        final matchingLessons = chapter.lessons.where((l) {
          final name = l.title.toLowerCase();
          final normalizedName = _normalizeArabic(name);
          return normalizedName.contains(normalizedQuery);
        }).toList();
        
        if (matchingLessons.isNotEmpty) {
          filtered.add(CurriculumChapterModel(
            chapterId: chapter.chapterId,
            title: chapter.title,
            semester: chapter.semester,
            unitId: chapter.unitId,
            unitName: chapter.unitName,
            lessons: matchingLessons,
          ));
        }
      }
    }

    emit(LessonSelectionUpdated(
      subjectDetails: _subjectDetails,
      filteredChapters: filtered,
      selectedLessons: List.from(_selectedLessons),
      searchQuery: _searchQuery,
      availableSemesters: _subjectDetails?.chapters.map((c) => c.semester).toSet().toList() ?? [],
      selectedSemester: _selectedSemester,
    ));
  }
  
  List<CurriculumLessonModel> get selectedLessons => _selectedLessons;
  bool get hasSelection => _selectedLessons.isNotEmpty;
}
