abstract class ManualExamState {}

class ManualExamInitial extends ManualExamState {}

class ManualExamLoading extends ManualExamState {}

class ManualExamSuccess extends ManualExamState {
  final String message;
  ManualExamSuccess(this.message);
}

class ManualExamError extends ManualExamState {
  final String error;
  ManualExamError(this.error);
}

// Emitted when form validates successfully and updates
class ManualExamFormUpdated extends ManualExamState {}
