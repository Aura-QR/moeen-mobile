import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_field_error.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

part 'reading_editor_state.dart';

/// L12 «الفهم القرائي» editor: passage, vocabulary and questions, with preview,
/// save, «شارك إلكترونيًا» and field-level `422` handling.
class ReadingEditorCubit extends Cubit<ReadingEditorState> {
  static ReadingEditorCubit get(BuildContext context) => BlocProvider.of(context);

  /// The portfolio element a reading worksheet counts for.
  static const String portfolioItemKey = 'teaching_strategies';

  ReadingEditorCubit({
    required DocumentsRepository documentsRepository,
    int? documentId,
    ReadingComprehensionInput? initialInput,
  })  : _documents = documentsRepository,
        _initialInput = initialInput,
        super(ReadingEditorState(
          documentId: documentId,
          input: initialInput ?? ReadingComprehensionInput.blank(),
          isDirty: initialInput != null,
        ));

  final DocumentsRepository _documents;
  final ReadingComprehensionInput? _initialInput;

  final TextEditingController titleController = TextEditingController();

  Future<void> load() async {
    emit(state.copyWith(status: ReadingEditorStatus.loading));
    final id = state.documentId;
    final defaultsFuture = _documents.getDefaults();
    final docFuture = id == null ? null : _documents.getDocument(id);

    final defaultsResult = await defaultsFuture;
    final docResult = await docFuture;
    if (isClosed) return;

    final docFailure = docResult?.fold((f) => f, (_) => null);
    if (docFailure != null) {
      emit(state.copyWith(status: ReadingEditorStatus.failure, errorMessage: docFailure.message));
      return;
    }

    final defaults = defaultsResult.fold((_) => const DocumentDefaultsModel(), (d) => d);
    final saved = docResult?.fold((_) => null, (doc) => doc);

    if (saved != null) {
      final parsed = ReadingComprehensionInput.fromJson(saved.input);
      final resolvedTitle = parsed.title.trim().isNotEmpty ? parsed.title : saved.title;
      final input = parsed.copyWith(title: resolvedTitle);
      titleController.text = input.title;
      emit(state.copyWith(
        status: ReadingEditorStatus.success,
        defaults: defaults,
        documentStatus: saved.status,
        input: input,
        isDirty: false,
      ));
      return;
    }

    final starter = _initialInput ?? ReadingComprehensionInput.blank();
    titleController.text = starter.title;
    emit(state.copyWith(
      status: ReadingEditorStatus.success,
      defaults: defaults,
      input: starter,
      isDirty: _initialInput != null,
    ));
  }

  void markTitleEdited() {
    if (!state.isDirty || state.titleError != null) {
      emit(state.copyWith(isDirty: true, clearTitleError: true));
    }
  }

  // ─── Passage ───────────────────────────────────────────────────────────
  void updateParagraph(int index, String text) {
    if (index < 0 || index >= state.input.passage.length) return;
    final passage = [...state.input.passage]..[index] = text;
    final errors = Map<int, String>.from(state.passageErrors)..remove(index);
    emit(state.copyWith(input: state.input.copyWith(passage: passage), passageErrors: errors, isDirty: true));
  }

  void addParagraph() {
    if (!state.input.canAddParagraph) return;
    emit(state.copyWith(input: state.input.copyWith(passage: [...state.input.passage, '']), isDirty: true));
  }

  void removeParagraph(int index) {
    if (state.input.passage.length <= 1 || index < 0 || index >= state.input.passage.length) return;
    final passage = [...state.input.passage]..removeAt(index);
    emit(state.copyWith(input: state.input.copyWith(passage: passage), passageErrors: const {}, isDirty: true));
  }

  void moveParagraph(int index, int delta) {
    final target = index + delta;
    final passage = [...state.input.passage];
    if (index < 0 || target < 0 || index >= passage.length || target >= passage.length) return;
    final item = passage.removeAt(index);
    passage.insert(target, item);
    emit(state.copyWith(input: state.input.copyWith(passage: passage), passageErrors: const {}, isDirty: true));
  }

  // ─── Vocabulary ────────────────────────────────────────────────────────
  void updateVocabulary(int index, {String? word, String? meaning}) {
    if (index < 0 || index >= state.input.vocabulary.length) return;
    final list = [...state.input.vocabulary]..[index] = state.input.vocabulary[index].copyWith(word: word, meaning: meaning);
    final errors = Map<int, String>.from(state.vocabularyErrors)..remove(index);
    emit(state.copyWith(input: state.input.copyWith(vocabulary: list), vocabularyErrors: errors, isDirty: true));
  }

  void addVocabulary() {
    if (!state.input.canAddVocabulary) return;
    emit(state.copyWith(
      input: state.input.copyWith(vocabulary: [...state.input.vocabulary, const ReadingVocabularyItem()]),
      isDirty: true,
    ));
  }

  void removeVocabulary(int index) {
    if (index < 0 || index >= state.input.vocabulary.length) return;
    final list = [...state.input.vocabulary]..removeAt(index);
    emit(state.copyWith(input: state.input.copyWith(vocabulary: list), vocabularyErrors: const {}, isDirty: true));
  }

  // ─── Questions ─────────────────────────────────────────────────────────
  void addQuestion(ReadingQuestionLevel level) {
    if (!state.input.canAddQuestion) return;
    final questions = [...state.input.questions, ReadingQuestion(level: level)];
    emit(state.copyWith(
      input: state.input.copyWith(questions: questions),
      isDirty: true,
      openQuestionIndex: questions.length - 1,
    ));
  }

  void updateQuestion(int index, ReadingQuestion question) {
    if (index < 0 || index >= state.input.questions.length) return;
    final questions = [...state.input.questions]..[index] = question;
    final errors = Map<int, String>.from(state.questionErrors)..remove(index);
    emit(state.copyWith(input: state.input.copyWith(questions: questions), questionErrors: errors, isDirty: true));
  }

  void removeQuestion(int index) {
    if (index < 0 || index >= state.input.questions.length) return;
    final questions = [...state.input.questions]..removeAt(index);
    emit(state.copyWith(input: state.input.copyWith(questions: questions), questionErrors: const {}, isDirty: true));
  }

  /// Moves a question up or down within its own level group.
  void moveQuestion(int index, int delta) {
    final questions = state.input.questions;
    if (index < 0 || index >= questions.length) return;
    final level = questions[index].level;
    final sameLevel = [for (var i = 0; i < questions.length; i++) if (questions[i].level == level) i];
    final pos = sameLevel.indexOf(index);
    final swapPos = pos + delta;
    if (pos < 0 || swapPos < 0 || swapPos >= sameLevel.length) return;
    final reordered = [...questions];
    final other = sameLevel[swapPos];
    final temp = reordered[index];
    reordered[index] = reordered[other];
    reordered[other] = temp;
    emit(state.copyWith(input: state.input.copyWith(questions: reordered), questionErrors: const {}, isDirty: true));
  }

  void consumeOpenQuestion() => emit(state.copyWith());

  // ─── Settings ──────────────────────────────────────────────────────────
  void setStudentFields(bool value) {
    if (value == state.input.studentFields) return;
    emit(state.copyWith(input: state.input.copyWith(studentFields: value), isDirty: true));
  }

  void setShowAnswers(bool value) {
    if (value == state.input.showAnswers) return;
    emit(state.copyWith(input: state.input.copyWith(showAnswers: value), isDirty: true));
  }

  void setDocumentStatus(String status) {
    if (status == state.documentStatus) return;
    emit(state.copyWith(documentStatus: status, isDirty: true));
  }

  Map<String, dynamic> buildPreviewPayload() =>
      state.input.copyWith(title: titleController.text.trim()).toJson();

  // ─── Save / export / attach ────────────────────────────────────────────
  Future<void> save() => _save(null);
  Future<void> saveAndExport() => _save(DocumentFollowUp.export);
  Future<void> saveAndAttach() => _save(DocumentFollowUp.attachToPortfolio);

  Future<void> saveIfDirty() async {
    if (!state.isDirty || state.status != ReadingEditorStatus.success) return;
    if (titleController.text.trim().isEmpty) return;
    if (!_hasPassage) return;
    await _save(null, quiet: true);
  }

  bool get _hasPassage => state.input.passage.any((p) => p.trim().isNotEmpty);

  Future<void> _save(DocumentFollowUp? followUp, {bool quiet = false}) async {
    if (state.isSaving) return;
    final localError = _validateLocally();
    if (localError != null) {
      emit(localError);
      return;
    }

    emit(state.copyWith(isSaving: true));
    final payload = state.input.copyWith(title: titleController.text.trim()).toJson();
    final id = state.documentId;
    final result = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.readingComprehension,
            input: payload,
            status: state.documentStatus,
            keepFieldErrors: true,
          )
        : await _documents.updateDocument(id, payload, status: state.documentStatus, keepFieldErrors: true);
    if (isClosed) return;

    result.fold(
      (failure) => emit(_handleFailure(failure)),
      (saved) => emit(state.copyWith(
        isSaving: false,
        isDirty: false,
        documentId: saved.id,
        clearErrors: true,
        clearTitleError: true,
        followUp: followUp,
        feedback: followUp == null && !quiet ? const UiFeedback('document_saved', isError: false) : null,
      )),
    );
  }

  /// «شارك إلكترونيًا»: saves, then copies the worksheet into an exam.
  Future<void> share() async {
    if (state.isSaving || state.isSharing) return;
    final localError = _validateLocally();
    if (localError != null) {
      emit(localError);
      return;
    }

    emit(state.copyWith(isSaving: true));
    final payload = state.input.copyWith(title: titleController.text.trim()).toJson();
    final id = state.documentId;
    final saved = id == null
        ? await _documents.createDocument(
            type: DocumentTypes.readingComprehension,
            input: payload,
            status: state.documentStatus,
            keepFieldErrors: true,
          )
        : await _documents.updateDocument(id, payload, status: state.documentStatus, keepFieldErrors: true);
    if (isClosed) return;

    final document = saved.fold((failure) {
      emit(_handleFailure(failure));
      return null;
    }, (doc) => doc);
    if (document == null) return;

    emit(state.copyWith(isSaving: false, isDirty: false, documentId: document.id, clearErrors: true));
    emit(state.copyWith(isSharing: true));
    final examResult = await _documents.toExam(document.id);
    if (isClosed) return;
    examResult.fold(
      (failure) => emit(_handleFailure(failure).copyWith(isSharing: false)),
      (ref) => emit(state.copyWith(isSharing: false, shareExamRef: ref)),
    );
  }

  ReadingEditorState? _validateLocally() {
    if (titleController.text.trim().isEmpty) {
      return state.copyWith(titleError: 'reading_title_required', feedback: const UiFeedback('reading_title_required'));
    }
    if (!_hasPassage) {
      return state.copyWith(passageErrors: {0: 'reading_passage_required'}, feedback: const UiFeedback('reading_passage_required'));
    }
    for (var i = 0; i < state.input.questions.length; i++) {
      if (state.input.questions[i].text.trim().isEmpty) {
        return state.copyWith(
          questionErrors: {...state.questionErrors, i: 'reading_question_text_required'},
          openQuestionIndex: i,
          feedback: const UiFeedback('reading_question_text_required'),
        );
      }
    }
    return null;
  }

  ReadingEditorState _handleFailure(Failure failure) {
    if (failure is PaymentRequiredFailure) {
      return state.copyWith(isSaving: false, paymentRequired: failure);
    }
    if (failure is! ValidationFailure) {
      return state.copyWith(isSaving: false, feedback: UiFeedback(failure.message));
    }

    final passageErrors = <int, String>{};
    final vocabularyErrors = <int, String>{};
    final questionErrors = <int, String>{};
    String? titleError;
    int? openQuestion;

    for (final entry in failure.errors.entries) {
      final parsed = ReadingFieldError.parse(entry.key, entry.value);
      if (parsed == null) continue;
      switch (parsed.target) {
        case ReadingErrorTarget.title:
          titleError ??= parsed.message;
        case ReadingErrorTarget.passage:
          passageErrors[parsed.index ?? 0] = parsed.message;
        case ReadingErrorTarget.vocabulary:
          if (parsed.index != null) vocabularyErrors[parsed.index!] = parsed.message;
        case ReadingErrorTarget.question:
          if (parsed.index != null) {
            questionErrors[parsed.index!] = parsed.message;
            openQuestion ??= parsed.index;
          }
        case ReadingErrorTarget.other:
          break;
      }
    }

    return state.copyWith(
      isSaving: false,
      titleError: titleError,
      passageErrors: passageErrors,
      vocabularyErrors: vocabularyErrors,
      questionErrors: questionErrors,
      openQuestionIndex: openQuestion,
      feedback: UiFeedback(failure.message),
    );
  }

  @override
  Future<void> close() {
    titleController.dispose();
    return super.close();
  }
}
