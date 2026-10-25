import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

class DiagnosisState {
  final Diagnosis? diagnosis;
  final bool isLoading;
  final bool isBusy;
  final int? groupId;
  final String? error;

  /// Set once a plan is saved: (type, document id); the screen opens it.
  final ({String type, int id})? createdPlan;

  const DiagnosisState({this.diagnosis, this.isLoading = true, this.isBusy = false, this.groupId, this.error, this.createdPlan});

  DiagnosisState copyWith({Diagnosis? diagnosis, bool? isLoading, bool? isBusy, int? groupId, bool allGroups = false, String? error, bool clearError = false, ({String type, int id})? createdPlan, bool clearPlan = false}) =>
      DiagnosisState(
        diagnosis: diagnosis ?? this.diagnosis,
        isLoading: isLoading ?? this.isLoading,
        isBusy: isBusy ?? this.isBusy,
        groupId: allGroups ? null : groupId ?? this.groupId,
        error: clearError ? null : error ?? this.error,
        createdPlan: clearPlan ? null : createdPlan ?? this.createdPlan,
      );

  /// A skill's mastery for the chosen class, or the whole test.
  double? masteryOf(SkillDiagnosis s) => groupId == null ? s.mastery : s.groups.where((g) => g.id == groupId).firstOrNull?.mastery;

  List<StudentDiagnosis> get students => (diagnosis?.students ?? const []).where((s) => groupId == null || s.groupId == groupId).toList();
}

/// «التشخيص» of an online test made from a diagnostic exam.
class DiagnosisCubit extends Cubit<DiagnosisState> {
  final int testId;
  final DiagnosticRepository _repository;
  final DocumentsRepository _documents;

  DiagnosisCubit({required this.testId, required DiagnosticRepository repository, required DocumentsRepository documents})
      : _repository = repository,
        _documents = documents,
        super(const DiagnosisState());

  static DiagnosisCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    final result = await _repository.getDiagnosis(testId);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (d) => emit(state.copyWith(isLoading: false, diagnosis: d, clearError: true)),
    );
  }

  void setGroup(int? id) => emit(id == null ? state.copyWith(allGroups: true) : state.copyWith(groupId: id));

  /// [type]: `remedial_plan` or `enrichment_plan`, filled from the diagnosis.
  Future<void> createPlan(String type) async {
    final d = state.diagnosis;
    if (d == null || state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearError: true));
    final result = await _documents.createDocument(type: type, input: type == 'remedial_plan' ? d.remedial : d.enrichment, status: 'draft');
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isBusy: false, error: f.message)),
      (doc) => emit(state.copyWith(isBusy: false, createdPlan: (type: type, id: doc.id))),
    );
  }

  void clearPlan() => emit(state.copyWith(clearPlan: true));
  void clearError() => emit(state.copyWith(clearError: true));
}
