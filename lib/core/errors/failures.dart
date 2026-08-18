abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;
  const ValidationFailure(super.message, this.errors);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

class ExamLockedFailure extends Failure {
  const ExamLockedFailure(super.message);
}

class AiGenerationFailure extends Failure {
  const AiGenerationFailure(super.message);
}

class PaymentRequiredFailure extends Failure {
  final String code;
  const PaymentRequiredFailure(super.message, {this.code = 'quota_exceeded'});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
