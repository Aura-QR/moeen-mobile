import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

abstract class QuestionCountState {}

class QuestionCountInitial extends QuestionCountState {}

class QuestionCountUpdated extends QuestionCountState {
  final Map<int, RequestedCountsEntity> counts;
  final int totalQuestions;
  final int totalLessons;

  QuestionCountUpdated({
    required this.counts,
    required this.totalQuestions,
    required this.totalLessons,
  });
}

class QuestionCountCubit extends Cubit<QuestionCountState> {
  QuestionCountCubit() : super(QuestionCountInitial());

  // Store counts efficiently
  final Map<int, RequestedCountsEntity> _counts = {};

  void initForLessons(List<CurriculumLessonModel> selectedLessons) {
    // Retain old counts for lessons still selected, initialize new ones to 0
    final newCounts = <int, RequestedCountsEntity>{};
    for (final lesson in selectedLessons) {
      final int id = lesson.id;
      if (_counts.containsKey(id)) {
        newCounts[id] = _counts[id]!;
      } else {
        newCounts[id] = const RequestedCountsEntity(mcq: 0, trueFalse: 0, fillBlank: 0, essay: 0, matching: 0);
      }
    }
    _counts.clear();
    _counts.addAll(newCounts);
    _emitState();
  }

  void updateCount(int lessonId, String type, int delta) {
    if (!_counts.containsKey(lessonId)) return;
    final current = _counts[lessonId]!;
    
    int newMcq = current.mcq;
    int newTrueFalse = current.trueFalse;
    int newFillBlank = current.fillBlank;
    int newEssay = current.essay;
    int newMatching = current.matching;

    switch (type) {
      case 'mcq':
        newMcq = (newMcq + delta).clamp(0, 100);
        break;
      case 'true_false':
        newTrueFalse = (newTrueFalse + delta).clamp(0, 100);
        break;
      case 'fill_blank':
        newFillBlank = (newFillBlank + delta).clamp(0, 100);
        break;
      case 'essay':
        newEssay = (newEssay + delta).clamp(0, 100);
        break;
      case 'matching':
        newMatching = (newMatching + delta).clamp(0, 100);
        break;
    }

    _counts[lessonId] = RequestedCountsEntity(
      mcq: newMcq,
      trueFalse: newTrueFalse,
      fillBlank: newFillBlank,
      essay: newEssay,
      matching: newMatching,
    );

    _emitState();
  }

  void _emitState() {
    int total = 0;
    for (final count in _counts.values) {
      total += count.total;
    }
    emit(QuestionCountUpdated(
      counts: Map.from(_counts),
      totalQuestions: total,
      totalLessons: _counts.length,
    ));
  }
  
  Map<int, RequestedCountsEntity> get counts => _counts;
  
  int get totalRequestedQuestions {
    int total = 0;
    for (final count in _counts.values) {
      total += count.total;
    }
    return total;
  }
}
