import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'package:moean/features/curriculum/data/repositories/curriculum_repository.dart';

part 'curriculum_distribution_state.dart';

class CurriculumDistributionCubit
    extends Cubit<CurriculumDistributionState> {
  static CurriculumDistributionCubit get(BuildContext context) => BlocProvider.of(context);

  CurriculumDistributionCubit() : super(CurriculumDistributionInitial());

  final _repo = CurriculumRepository();

  // Retained for cross-call context
  int? selectedSubjectId;
  int? selectedSemester;
  int? selectedPlanId;

  // ── Load plans for a subject/semester ──────────────────────────────────────
  Future<void> loadPlans({int? subjectId, int? semester}) async {
    selectedSubjectId = subjectId;
    selectedSemester = semester;
    emit(CurriculumDistributionLoading());

    final result = await _repo.getPlans(subjectId: subjectId, semester: semester);
    result.fold(
      (error) => emit(CurriculumDistributionError(message: error)),
      (plans) {
        emit(CurriculumDistributionPlansLoaded(plans: plans));
        // Auto-load the first plan's detail right away
        if (plans.isNotEmpty) loadPlanDetail(plans.first.id);
      },
    );
  }

  // ── Load full timeline for a plan ──────────────────────────────────────────
  Future<void> loadPlanDetail(int planId, {String? region}) async {
    selectedPlanId = planId;
    emit(CurriculumDistributionLoading());

    final detailResult = await _repo.getPlanDetail(planId, region: region);
    detailResult.fold(
      (error) => emit(CurriculumDistributionError(message: error)),
      (detail) async {
        CurriculumProgressModel? progress;
        if (selectedSubjectId != null && selectedSemester != null) {
          final progResult = await _repo.getProgress(
            subjectId: selectedSubjectId!,
            semester: selectedSemester!,
          );
          progResult.fold((_) {}, (p) => progress = p);
        }
        if (!isClosed) {
          emit(CurriculumDistributionDetailLoaded(
            detail: detail,
            progress: progress,
          ));
        }
      },
    );
  }

  // ── Bulk-prepare a whole week ──────────────────────────────────────────────
  Future<void> prepareWeek(int weekId) async {
    if (selectedPlanId == null) return;

    // Keep current detail/progress visible while preparing
    final current = state;
    CurriculumPlanDetailModel? currentDetail;
    CurriculumProgressModel? currentProgress;
    if (current is CurriculumDistributionDetailLoaded) {
      currentDetail = current.detail;
      currentProgress = current.progress;
    }
    if (currentDetail != null) {
      emit(CurriculumDistributionPreparing(
        detail: currentDetail,
        progress: currentProgress,
      ));
    }

    final result = await _repo.prepareWeek(
      planId: selectedPlanId!,
      weekId: weekId,
    );
    result.fold(
      (error) => emit(CurriculumDistributionError(message: error)),
      (data) => emit(CurriculumDistributionPrepareSuccess(
        detail: currentDetail!,
        progress: currentProgress,
        result: data,
      )),
    );
  }
}
