import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';

abstract class LessonSelectionState {}

class LessonSelectionInitial extends LessonSelectionState {}

class LessonSelectionLoading extends LessonSelectionState {}

class LessonSelectionError extends LessonSelectionState {
  final String message;
  LessonSelectionError(this.message);
}

class LessonSelectionUpdated extends LessonSelectionState {
  final List<Map<String, dynamic>> allLessons;
  final List<Map<String, dynamic>> filteredLessons;
  final List<Map<String, dynamic>> selectedLessons;
  final String searchQuery;

  LessonSelectionUpdated({
    required this.allLessons,
    required this.filteredLessons,
    required this.selectedLessons,
    required this.searchQuery,
  });
}

class LessonSelectionCubit extends Cubit<LessonSelectionState> {
  LessonSelectionCubit() : super(LessonSelectionInitial());

  List<Map<String, dynamic>> _allLessons = [];
  final List<Map<String, dynamic>> _selectedLessons = [];
  String _searchQuery = '';
  int? _currentSubjectId;

  Future<void> loadLessonsForSubjectId(int subjectId) async {
    if (_currentSubjectId == subjectId && _allLessons.isNotEmpty) {
      _emitState();
      return; // Already loaded
    }

    _currentSubjectId = subjectId;
    emit(LessonSelectionLoading());

    final result = await ApiService.getSubjectLessons(subjectId);
    
    result.fold(
      (dynamic failure) => emit(LessonSelectionError(failure?.message ?? 'Unknown error')),
      (lessonsData) {
        _allLessons = lessonsData.map((e) => {
          'id': e.id,
          'name': e.name,
        }).toList();
        
        // Keep previously selected lessons if they still exist in the new unit, otherwise clear
        _selectedLessons.removeWhere((selected) => !_allLessons.any((l) => l['id'] == selected['id']));
        
        _emitState();
      },
    );
  }

  void retry() {
    if (_currentSubjectId != null) {
      loadLessonsForSubjectId(_currentSubjectId!);
    }
  }

  void search(String query) {
    print('Search query received: $query');
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

  void toggleLesson(Map<String, dynamic> lesson) {
    if (_selectedLessons.any((l) => l['id'] == lesson['id'])) {
      _selectedLessons.removeWhere((l) => l['id'] == lesson['id']);
    } else {
      _selectedLessons.add(lesson);
    }
    _emitState();
  }

  void removeLesson(int lessonId) {
    _selectedLessons.removeWhere((l) => l['id'] == lessonId);
    _emitState();
  }

  void _emitState() {
    final normalizedQuery = _normalizeArabic(_searchQuery);
    print('Normalized Search query: $normalizedQuery');
    print('All lessons count: ${_allLessons.length}');

    final filtered = _allLessons.where((l) {
      final name = (l['name'] as String).toLowerCase();
      final normalizedName = _normalizeArabic(name);
      return normalizedName.contains(normalizedQuery);
    }).toList();
    
    print('Filtered lessons count: ${filtered.length}');

    emit(LessonSelectionUpdated(
      allLessons: List.from(_allLessons),
      filteredLessons: filtered,
      selectedLessons: List.from(_selectedLessons),
      searchQuery: _searchQuery,
    ));
  }
  
  List<Map<String, dynamic>> get selectedLessons => _selectedLessons;
  bool get hasSelection => _selectedLessons.isNotEmpty;
}
