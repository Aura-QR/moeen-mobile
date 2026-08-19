import 'package:equatable/equatable.dart';

abstract class PrivacyPolicyState extends Equatable {
  const PrivacyPolicyState();

  @override
  List<Object?> get props => [];
}

class PrivacyPolicyInitial extends PrivacyPolicyState {
  const PrivacyPolicyInitial();
}

class PrivacyPolicyStateUpdated extends PrivacyPolicyState {
  final int? activeSection;
  final String searchQuery;

  const PrivacyPolicyStateUpdated({
    this.activeSection,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [activeSection, searchQuery];
}

class PrivacyPolicyPdfGenerating extends PrivacyPolicyState {
  const PrivacyPolicyPdfGenerating();
}

class PrivacyPolicyPdfGenerated extends PrivacyPolicyState {
  const PrivacyPolicyPdfGenerated();
}

class PrivacyPolicyPdfError extends PrivacyPolicyState {
  final String message;

  const PrivacyPolicyPdfError(this.message);

  @override
  List<Object?> get props => [message];
}
