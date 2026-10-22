import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_column.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_input.dart';
import 'package:moean/features/class_sheets/data/models/class_sheets_catalogue_model.dart';
import 'package:moean/features/class_sheets/data/repositories/class_sheets_repository.dart';
import 'package:moean/features/class_sheets/presentation/cubit/class_sheets_state.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

class ClassSheetsCubit extends Cubit<ClassSheetsState> {
  static ClassSheetsCubit get(BuildContext context) => BlocProvider.of(context);

  ClassSheetsCubit({
    required ClassSheetsRepository repository,
    required ClassesRepository classesRepository,
    required DocumentsRepository documentsRepository,
    this.documentId,
    this.initialClass,
    DocumentPreviewCubit? previewCubit,
  })  : _repo = repository,
        _classesRepo = classesRepository,
        _docsRepo = documentsRepository,
        _previewCubit = previewCubit,
        super(const ClassSheetsState());

  final ClassSheetsRepository _repo;
  final ClassesRepository _classesRepo;
  final DocumentsRepository _docsRepo;
  final int? documentId;
  final SchoolClassModel? initialClass;
  DocumentPreviewCubit? _previewCubit;

  void attachPreviewCubit(DocumentPreviewCubit previewCubit) {
    _previewCubit = previewCubit;
    schedulePreview();
  }

  Future<void> init() async {
    emit(state.copyWith(status: ClassSheetsStatus.loading));

    // 1. Load catalogue
    final catalogueResult = await _repo.getCatalogue();
    final kinds = catalogueResult.fold((_) => SheetKindModel.fallbackKinds, (k) => k);

    // 2. Load classes
    final classesResult = await _classesRepo.getClasses();
    final classes = classesResult.fold((_) => <SchoolClassModel>[], (c) => c);

    var currentKind = kinds.firstOrNull ?? SheetKindModel.fallbackKinds.first;
    var currentInput = state.input.copyWith(
      kind: currentKind.key,
      columns: currentKind.defaultColumns,
    );

    // 3. If reopening a saved document
    int? loadedDocId = documentId;
    if (documentId != null) {
      final docResult = await _docsRepo.getDocument(documentId!);
      docResult.fold(
        (_) {},
        (doc) {
          final parsedInput = ClassSheetInput.fromJson(doc.input);
          currentInput = parsedInput;
          currentKind = kinds.firstWhere(
            (k) => k.key == parsedInput.kind,
            orElse: () => SheetKindModel.fallbackKinds.first,
          );
        },
      );
    } else if (initialClass != null) {
      // 4. If opened from «فصولي» directly
      SchoolClassModel detailedClass = initialClass!;
      if (initialClass!.id != null) {
        final classDetailsResult = await _classesRepo.getClass(initialClass!.id!);
        detailedClass = classDetailsResult.fold((_) => initialClass!, (c) => c);
      }
      currentInput = currentInput.copyWith(
        classId: detailedClass.id,
        className: detailedClass.name,
        subject: detailedClass.subject,
        grade: detailedClass.grade,
        students: detailedClass.students,
        useEmptyRows: detailedClass.students.isEmpty,
      );
    }

    emit(state.copyWith(
      status: ClassSheetsStatus.success,
      kinds: kinds,
      selectedKind: currentKind,
      input: currentInput,
      classes: classes,
      savedDocumentId: loadedDocId,
    ));

    schedulePreview();
  }

  void selectKind(SheetKindModel kind) {
    if (kind.key == state.selectedKind.key) return;

    final updatedInput = state.input.copyWith(
      kind: kind.key,
      columns: kind.defaultColumns,
      weeks: kind.kindType == SheetKindType.attendance ? 2 : state.input.weeks,
      startDate: kind.kindType == SheetKindType.attendance && state.input.startDate == null
          ? DateTime.now()
          : state.input.startDate,
      date: kind.kindType == SheetKindType.dailyFollowUp && state.input.date == null
          ? DateTime.now()
          : state.input.date,
    );

    emit(state.copyWith(
      selectedKind: kind,
      input: updatedInput,
    ));

    schedulePreview();
  }

  Future<void> selectClass(SchoolClassModel schoolClass) async {
    emit(state.copyWith(isLoadingClasses: true));
    SchoolClassModel detailedClass = schoolClass;
    if (schoolClass.id != null) {
      final detailsResult = await _classesRepo.getClass(schoolClass.id!);
      detailedClass = detailsResult.fold((_) => schoolClass, (c) => c);
    }

    final updatedInput = state.input.copyWith(
      classId: detailedClass.id,
      className: detailedClass.name,
      subject: detailedClass.subject.isNotEmpty ? detailedClass.subject : state.input.subject,
      grade: detailedClass.grade.isNotEmpty ? detailedClass.grade : state.input.grade,
      students: detailedClass.students,
      useEmptyRows: false,
    );

    emit(state.copyWith(
      isLoadingClasses: false,
      input: updatedInput,
    ));

    schedulePreview();
  }

  void setUseEmptyRows(bool useEmpty) {
    final updatedInput = state.input.copyWith(
      useEmptyRows: useEmpty,
      clearClassId: useEmpty,
      className: useEmpty ? '' : state.input.className,
    );

    emit(state.copyWith(input: updatedInput));
    schedulePreview();
  }

  void setEmptyRows(int count) {
    if (count < 1 || count > 100) return;
    emit(state.copyWith(input: state.input.copyWith(emptyRows: count)));
    schedulePreview();
  }

  void updateSubject(String subject) {
    emit(state.copyWith(input: state.input.copyWith(subject: subject)));
    schedulePreview();
  }

  void updateGrade(String grade) {
    emit(state.copyWith(input: state.input.copyWith(grade: grade)));
    schedulePreview();
  }

  void updateTerm(String term) {
    emit(state.copyWith(input: state.input.copyWith(term: term)));
    schedulePreview();
  }

  void updateTitle(String title) {
    emit(state.copyWith(input: state.input.copyWith(title: title)));
    schedulePreview();
  }

  void updateStartDate(DateTime date) {
    emit(state.copyWith(input: state.input.copyWith(startDate: date)));
    schedulePreview();
  }

  void updateWeeks(int weeks) {
    if (weeks < 1 || weeks > 4) return;
    emit(state.copyWith(input: state.input.copyWith(weeks: weeks)));
    schedulePreview();
  }

  void updateFollowUpDate(DateTime date) {
    emit(state.copyWith(input: state.input.copyWith(date: date)));
    schedulePreview();
  }

  void reorderColumns(int oldIndex, int newIndex) {
    final cols = List<ClassSheetColumn>.from(state.input.columns);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);

    emit(state.copyWith(input: state.input.copyWith(columns: cols)));
    schedulePreview();
  }

  void addColumn(ClassSheetColumn column) {
    final cols = [...state.input.columns, column];
    emit(state.copyWith(input: state.input.copyWith(columns: cols)));
    schedulePreview();
  }

  void updateColumn(int index, ClassSheetColumn column) {
    if (index < 0 || index >= state.input.columns.length) return;
    final cols = List<ClassSheetColumn>.from(state.input.columns);
    cols[index] = column;
    emit(state.copyWith(input: state.input.copyWith(columns: cols)));
    schedulePreview();
  }

  void removeColumn(int index) {
    if (index < 0 || index >= state.input.columns.length) return;
    final cols = List<ClassSheetColumn>.from(state.input.columns)..removeAt(index);
    emit(state.copyWith(input: state.input.copyWith(columns: cols)));
    schedulePreview();
  }

  void resetColumns() {
    emit(state.copyWith(input: state.input.copyWith(columns: state.selectedKind.defaultColumns)));
    schedulePreview();
  }

  void schedulePreview() {
    _previewCubit?.schedule(state.input.toJson());
  }

  Future<void> save({DocumentFollowUp? followUp}) async {
    if (state.isSaving) return;
    emit(state.copyWith(status: ClassSheetsStatus.saving, clearError: true, clearFeedback: true));

    final inputJson = state.input.toJson();
    final result = state.savedDocumentId != null
        ? await _docsRepo.updateDocument(
            state.savedDocumentId!,
            inputJson,
            status: DocumentStatus.finalized,
          )
        : await _docsRepo.createDocument(
            type: DocumentTypes.classSheet,
            input: inputJson,
            status: DocumentStatus.finalized,
          );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ClassSheetsStatus.failure,
        errorMessage: failure.message,
        feedbackMessage: failure.message,
        isErrorFeedback: true,
      )),
      (doc) => emit(state.copyWith(
        status: ClassSheetsStatus.success,
        savedDocumentId: doc.id,
        followUp: followUp,
        feedbackMessage: 'document_saved',
        isErrorFeedback: false,
      )),
    );
  }

  void clearFollowUp() => emit(state.copyWith(clearFollowUp: true));
  void clearFeedback() => emit(state.copyWith(clearFeedback: true));
}
