part of 'certificate_cubit.dart';

abstract class CertificateState {
  const CertificateState();
}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateLoaded extends CertificateState {
  const CertificateLoaded();
}

class CertificateTemplateSelected extends CertificateState {
  final int index;
  const CertificateTemplateSelected(this.index);
}

class CertificateGenderChanged extends CertificateState {
  final String gender;
  const CertificateGenderChanged(this.gender);
}

class CertificateDateChanged extends CertificateState {
  final DateTime date;
  const CertificateDateChanged(this.date);
}

class CertificateReadyTextSelected extends CertificateState {
  final String text;
  const CertificateReadyTextSelected(this.text);
}

class CertificatePreviewUpdated extends CertificateState {
  const CertificatePreviewUpdated();
}

class CertificateGenerating extends CertificateState {}

class CertificateError extends CertificateState {
  final String message;
  const CertificateError(this.message);
}
