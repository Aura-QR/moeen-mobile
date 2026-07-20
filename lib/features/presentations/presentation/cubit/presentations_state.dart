import 'package:moean/features/presentations/data/models/presentation_models.dart';

abstract class PresentationsState {}

class PresentationsInitial extends PresentationsState {}

class PresentationsLoading extends PresentationsState {}

class PresentationsSuccess extends PresentationsState {
  final PresentationModel presentation;
  PresentationsSuccess(this.presentation);
}

class PresentationsError extends PresentationsState {
  final String message;
  PresentationsError(this.message);
}
