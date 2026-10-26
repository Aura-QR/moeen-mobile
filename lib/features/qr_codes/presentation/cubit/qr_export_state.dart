import 'package:equatable/equatable.dart';

class QrExportState extends Equatable {
  final bool isExporting;
  final String? message;
  final bool isSuccess;

  const QrExportState({
    this.isExporting = false,
    this.message,
    this.isSuccess = false,
  });

  QrExportState copyWith({
    bool? isExporting,
    String? message,
    bool? isSuccess,
    bool clearMessage = false,
  }) {
    return QrExportState(
      isExporting: isExporting ?? this.isExporting,
      message: clearMessage ? null : (message ?? this.message),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isExporting, message, isSuccess];
}
