part of 'curriculum_distribution_cubit.dart';

abstract class CurriculumDistributionState {}

class CurriculumDistributionInitial extends CurriculumDistributionState {}

class CurriculumDistributionLoading extends CurriculumDistributionState {}

class CurriculumDistributionPlansLoaded extends CurriculumDistributionState {
  final List<CurriculumPlanModel> plans;
  CurriculumDistributionPlansLoaded({required this.plans});
}

class CurriculumDistributionDetailLoaded extends CurriculumDistributionState {
  final CurriculumPlanDetailModel detail;
  final CurriculumProgressModel? progress;
  CurriculumDistributionDetailLoaded({required this.detail, this.progress});
}

class CurriculumDistributionError extends CurriculumDistributionState {
  final String message;
  CurriculumDistributionError({required this.message});
}

class CurriculumDistributionPreparing extends CurriculumDistributionState {
  final CurriculumPlanDetailModel detail;
  final CurriculumProgressModel? progress;
  CurriculumDistributionPreparing({required this.detail, this.progress});
}

class CurriculumDistributionPrepareSuccess extends CurriculumDistributionState {
  final CurriculumPlanDetailModel detail;
  final CurriculumProgressModel? progress;
  final Map<String, dynamic> result;
  CurriculumDistributionPrepareSuccess({
    required this.detail,
    this.progress,
    required this.result,
  });
}
