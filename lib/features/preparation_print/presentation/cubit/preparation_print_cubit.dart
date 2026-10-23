import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/preparation_print/data/models/preparation_print_models.dart';

class PreparationPrintState {
  final Map<String, dynamic> input;
  final List<PrintLesson> lessons;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? feedback;
  final bool isErrorFeedback;
  final DocumentFollowUp? followUp;

  const PreparationPrintState({
    this.input = const {},
    this.lessons = const [],
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.feedback,
    this.isErrorFeedback = false,
    this.followUp,
  });

  PreparationPrintState copyWith({
    Map<String, dynamic>? input,
    List<PrintLesson>? lessons,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? feedback,
    bool? isErrorFeedback,
    DocumentFollowUp? followUp,
    bool clearFeedback = false,
    bool clearFollowUp = false,
  }) =>
      PreparationPrintState(
        input: input ?? this.input,
        lessons: lessons ?? this.lessons,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error ?? this.error,
        feedback: clearFeedback ? null : feedback ?? this.feedback,
        isErrorFeedback: isErrorFeedback ?? this.isErrorFeedback,
        followUp: clearFollowUp ? null : followUp ?? this.followUp,
      );
}

/// «طباعة التحضير»: edit the texts of a `lesson_preparation` document, then print, Word or portfolio.
class PreparationPrintCubit extends Cubit<PreparationPrintState> {
  final int documentId;
  final DocumentsRepository _documents;

  PreparationPrintCubit({required this.documentId, required DocumentsRepository documents})
      : _documents = documents,
        super(const PreparationPrintState());

  static PreparationPrintCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    final result = await _documents.getDocument(documentId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (doc) {
        final lessons = (doc.input['lessons'] as List? ?? [])
            .whereType<Map>()
            .map((l) => PrintLesson(Map<String, dynamic>.from(l)))
            .toList();
        emit(state.copyWith(isLoading: false, input: doc.input, lessons: lessons));
      },
    );
  }

  void updateText(int index, PrintSection section, String value) {
    final lessons = [...state.lessons];
    lessons[index] = lessons[index].withText(section.key, value, isList: section.isList);
    emit(state.copyWith(lessons: lessons));
  }

  void updateTitle(int index, String value) {
    final lessons = [...state.lessons];
    lessons[index] = lessons[index].withText('lesson_title', value);
    emit(state.copyWith(lessons: lessons));
  }

  Future<void> save({DocumentFollowUp? followUp}) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearFeedback: true));
    final input = {...state.input, 'lessons': state.lessons.map((l) => l.data).toList()};
    final result = await _documents.updateDocument(documentId, input, status: DocumentStatus.finalized);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: failure.message, isErrorFeedback: true)),
      (_) => emit(state.copyWith(isSaving: false, input: input, feedback: 'document_saved', isErrorFeedback: false, followUp: followUp)),
    );
  }

  void clearFeedback() => emit(state.copyWith(clearFeedback: true));
  void clearFollowUp() => emit(state.copyWith(clearFollowUp: true));
}
