abstract class EmailBlockState {
  const EmailBlockState();
}

class EmailBlockInitial extends EmailBlockState {
  const EmailBlockInitial();
}

class EmailBlockResending extends EmailBlockState {
  const EmailBlockResending();
}

class EmailBlockResent extends EmailBlockState {
  final String message;
  const EmailBlockResent(this.message);
}

class EmailBlockResendError extends EmailBlockState {
  final String message;
  const EmailBlockResendError(this.message);
}
