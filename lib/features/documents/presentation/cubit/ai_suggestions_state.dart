part of 'ai_suggestions_cubit.dart';

enum AiSuggestionsStatus { idle, loading, done, failed }

class AiSuggestionsState {
  final AiSuggestionsStatus status;

  /// A message for the user when [AiSuggestionsStatus.failed], e.g. a 429 limit.
  final String? errorMessage;

  /// Lists keyed by section once [AiSuggestionsStatus.done].
  final Map<String, List<String>> result;

  /// No trial or subscription (402): the screen offers the upgrade sheet.
  final PaymentRequiredFailure? paymentRequired;

  const AiSuggestionsState({
    this.status = AiSuggestionsStatus.idle,
    this.errorMessage,
    this.result = const {},
    this.paymentRequired,
  });

  bool get isLoading => status == AiSuggestionsStatus.loading;
}
