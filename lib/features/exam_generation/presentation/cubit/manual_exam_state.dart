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

class ManualExamPaymentRequired extends ManualExamState {
  final String message;
  final String code;
  ManualExamPaymentRequired(this.message, this.code);
}

// Emitted when form validates successfully and updates
class ManualExamFormUpdated extends ManualExamState {}
