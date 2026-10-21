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

/// Turns a raw [DioHelper] error string into a [Failure].
///
/// API messages are already written for the user and are kept as-is.
/// Transport and status-line errors become a translation key, so the UI can
/// always render `appTranslation().get(failure.message)`.
Failure failureFromApiError(String error) {
  if (error == 'Unauthenticated') {
    return const UnauthorizedFailure('generic_error');
  }
  if (error.startsWith('No response')) {
    return const ServerFailure('network_error');
  }
  if (error.startsWith('__')) {
    final parts = error.split(':');
    return ServerFailure(
      parts.length >= 3 ? parts.sublist(2).join(':') : 'generic_error',
    );
  }
  if (error.startsWith('Error') || error == 'something went wrong') {
    return const ServerFailure('generic_error');
  }
  return ServerFailure(error);
}
