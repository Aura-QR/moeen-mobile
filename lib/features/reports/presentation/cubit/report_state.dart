import 'package:equatable/equatable.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportSuccess extends ReportState {
  final Map<String, dynamic> data;

  const ReportSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReportPaymentRequired extends ReportState {
  final String message;
  final String code;

  const ReportPaymentRequired({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}
