import 'dart:convert';

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
  // Before the generic `__` branch: the JSON holds colons.
  if (error.startsWith('__422__:')) {
    try {
      final body = jsonDecode(error.substring('__422__:'.length)) as Map<String, dynamic>;
      final errors = body['errors'];
      return ValidationFailure(
        body['message']?.toString() ?? 'generic_error',
        errors is Map ? Map<String, dynamic>.from(errors) : const {},
      );
    } catch (_) {
      return const ServerFailure('generic_error');
    }
  }
  if (error.startsWith('No response')) {
    return const ServerFailure('network_error');
  }
  if (error.startsWith('__')) {
    final parts = error.split(':');
    final message = parts.length >= 3 ? parts.sublist(2).join(':') : 'generic_error';
    // No trial or subscription: the UI offers the upgrade sheet.
    if (parts.first == '__402__') {
      return PaymentRequiredFailure(message, code: parts.length >= 2 ? parts[1] : 'quota_exceeded');
    }
    return ServerFailure(message);
  }
  if (error.startsWith('Error') || error == 'something went wrong') {
    return const ServerFailure('generic_error');
  }
  return ServerFailure(error);
}
