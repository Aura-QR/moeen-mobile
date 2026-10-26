import 'package:equatable/equatable.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';

class SharedFilesListState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<SharedFileModel> files;
  final SharedFilesMetaModel meta;
  final String? error;
  final PaymentRequiredFailure? paymentRequired;
  final SharedFileModel? selectedFile;

  const SharedFilesListState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.files = const [],
    this.meta = const SharedFilesMetaModel(),
    this.error,
    this.paymentRequired,
    this.selectedFile,
  });

  bool get isEmpty => !isLoading && error == null && files.isEmpty;
  bool get hasData => !isLoading && files.isNotEmpty;

  SharedFilesListState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<SharedFileModel>? files,
    SharedFilesMetaModel? meta,
    String? error,
    PaymentRequiredFailure? paymentRequired,
    SharedFileModel? selectedFile,
    bool clearError = false,
    bool clearPaymentRequired = false,
    bool clearSelectedFile = false,
  }) {
    return SharedFilesListState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      files: files ?? this.files,
      meta: meta ?? this.meta,
      error: clearError ? null : (error ?? this.error),
      paymentRequired: clearPaymentRequired
          ? null
          : (paymentRequired ?? this.paymentRequired),
      selectedFile: clearSelectedFile
          ? null
          : (selectedFile ?? this.selectedFile),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        files,
        meta,
        error,
        paymentRequired,
        selectedFile,
      ];
}
