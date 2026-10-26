import 'package:equatable/equatable.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';

enum SharedFileUploadStatus {
  idle,
  loadingMeta,
  ready,
  uploading,
  registering,
  done,
  failed,
}

class SharedFileUploadState extends Equatable {
  final SharedFileUploadStatus status;
  final SharedFilesMetaModel meta;
  final DevicePickedPath? file;
  final String? mime;
  final String? title;
  final int expiryDays;
  final double progress;
  final String? error;
  final PaymentRequiredFailure? paymentRequired;
  final SharedFileModel? result;

  const SharedFileUploadState({
    this.status = SharedFileUploadStatus.idle,
    this.meta = const SharedFilesMetaModel(),
    this.file,
    this.mime,
    this.title,
    this.expiryDays = 30,
    this.progress = 0.0,
    this.error,
    this.paymentRequired,
    this.result,
  });

  bool get canUpload =>
      file != null &&
      mime != null &&
      status != SharedFileUploadStatus.uploading &&
      status != SharedFileUploadStatus.registering;

  SharedFileUploadState copyWith({
    SharedFileUploadStatus? status,
    SharedFilesMetaModel? meta,
    DevicePickedPath? file,
    String? mime,
    String? title,
    int? expiryDays,
    double? progress,
    String? error,
    PaymentRequiredFailure? paymentRequired,
    SharedFileModel? result,
    bool clearError = false,
    bool clearPaymentRequired = false,
  }) {
    return SharedFileUploadState(
      status: status ?? this.status,
      meta: meta ?? this.meta,
      file: file ?? this.file,
      mime: mime ?? this.mime,
      title: title ?? this.title,
      expiryDays: expiryDays ?? this.expiryDays,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      paymentRequired: clearPaymentRequired
          ? null
          : (paymentRequired ?? this.paymentRequired),
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        status,
        meta,
        file,
        mime,
        title,
        expiryDays,
        progress,
        error,
        paymentRequired,
        result,
      ];
}
