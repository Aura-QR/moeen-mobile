/// A one-shot message for a snackbar: a translation key or an API message.
class UiFeedback {
  final String message;
  final bool isError;

  const UiFeedback(this.message, {this.isError = true});
}
