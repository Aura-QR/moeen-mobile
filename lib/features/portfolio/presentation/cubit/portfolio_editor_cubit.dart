import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'portfolio_editor_state.dart';

/// Builds the PDF bytes; injectable so tests don't need fonts or assets.
typedef PortfolioPdfBuilder = Future<Uint8List> Function(
  PortfolioModel portfolio,
  Map<int, Uint8List> images,
);

class PortfolioEditorCubit extends Cubit<PortfolioEditorState> {
  static PortfolioEditorCubit get(BuildContext context) => BlocProvider.of(context);

  static const int maxSignatures = 4;

  PortfolioEditorCubit({
    required this.portfolioId,
    required PortfolioRepository repository,
    required DeviceFilePicker filePicker,
    required PortfolioPdfBuilder pdfBuilder,
  })  : _repo = repository,
        _picker = filePicker,
        _pdfBuilder = pdfBuilder,
        super(const PortfolioEditorState());

  final int portfolioId;
  final PortfolioRepository _repo;
  final DeviceFilePicker _picker;
  final PortfolioPdfBuilder _pdfBuilder;

  /// Loads the portfolio and the roles. File URLs expire after 60 minutes,
  /// so this also runs whenever the screen opens or an image fails to load.
  Future<void> load() async {
    if (state.portfolio == null) emit(state.copyWith(status: PortfolioEditorStatus.loading));
    final rolesFuture = state.roles == null ? _repo.getRoles() : null;
    await refresh();
    final rolesResult = await rolesFuture;
    if (isClosed || rolesResult == null) return;
    rolesResult.fold((_) {}, (roles) => emit(state.copyWith(roles: roles)));
  }

  Future<void> refresh() async {
    final result = await _repo.getPortfolio(portfolioId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.portfolio == null
          ? state.copyWith(status: PortfolioEditorStatus.failure, errorMessage: failure.message)
          : state.copyWith(feedback: UiFeedback(failure.message))),
      (portfolio) => emit(state.copyWith(status: PortfolioEditorStatus.success, portfolio: portfolio)),
    );
  }

  Future<void> rename(String title) async {
    if (title.trim().isEmpty) return;
    await _save(_repo.updatePortfolio(portfolioId, title: title.trim()));
  }

  /// Adds the new role's standard items; existing items and evidence stay.
  Future<void> changeRole(String role) async {
    if (role == state.portfolio?.role) return;
    await _save(_repo.updatePortfolio(portfolioId, role: role));
  }

  Future<void> saveProfile(PortfolioProfileModel profile) =>
      _save(_repo.updatePortfolio(portfolioId, profile: profile), successKey: 'portfolio_saved');

  Future<void> setIncluded(PortfolioItemModel item, bool included) async {
    // Flip it locally first so the checkbox responds at once.
    _replaceItem(item.copyWith(included: included));
    await _mutate(_repo.updateItem(portfolioId, item.id, included: included));
  }

  Future<void> updateItem(PortfolioItemModel item, {String? title, String? description}) =>
      _mutate(_repo.updateItem(
        portfolioId,
        item.id,
        title: item.isCustom ? title?.trim() : null,
        description: description?.trim(),
      ));

  Future<void> addItem(String title, String description) async {
    if (title.trim().isEmpty) return;
    await _mutate(_repo.addItem(portfolioId, title: title.trim(), description: description.trim()));
  }

  Future<void> deleteItem(PortfolioItemModel item) async {
    if (!item.isCustom) return;
    await _mutate(_repo.deleteItem(portfolioId, item.id));
  }

  Future<void> pickAndUpload(int itemId, DeviceFileSource source) async {
    final file = await _picker.pick(source);
    if (file == null || isClosed) return;

    final roles = state.roles ?? const PortfolioRolesModel(roles: []);
    if (file.mime == null || !roles.allowedMimes.contains(file.mime)) {
      emit(state.copyWith(feedback: const UiFeedback('portfolio_unsupported_file')));
      return;
    }
    if (file.byteSize > roles.maxFileBytes) {
      emit(state.copyWith(feedback: const UiFeedback('portfolio_file_too_large')));
      return;
    }

    emit(state.copyWith(uploadingItemId: itemId, uploadProgress: 0));
    final result = await _repo.uploadFile(
      portfolioId: portfolioId,
      itemId: itemId,
      file: file,
      onProgress: (progress) {
        if (!isClosed) emit(state.copyWith(uploadProgress: progress));
      },
    );
    if (isClosed) return;
    emit(state.copyWith(clearUploading: true, uploadProgress: 0));
    await _afterMutation(result, successKey: 'portfolio_evidence_added');
  }

  Future<void> addLink(int itemId, String url, String title) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      emit(state.copyWith(feedback: const UiFeedback('portfolio_link_https_only')));
      return;
    }
    await _mutate(
      _repo.addLink(portfolioId: portfolioId, itemId: itemId, url: uri.toString(), title: title.trim()),
      successKey: 'portfolio_evidence_added',
    );
  }

  /// [newIndex] is the final position, after removing the moved file.
  Future<void> reorderFiles(PortfolioItemModel item, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    final files = [...item.files];
    files.insert(newIndex, files.removeAt(oldIndex));
    _replaceItem(item.copyWith(files: files));
    await _mutate(_repo.reorderFiles(portfolioId, item.id, files.map((f) => f.id).toList()));
  }

  Future<void> deleteFile(int itemId, int fileId) =>
      _mutate(_repo.deleteFile(portfolioId, itemId, fileId));

  Future<void> enableShare() async {
    final portfolio = state.portfolio;
    if (portfolio == null) return;
    emit(state.copyWith(isSharing: true));
    final result = await _repo.enableShare(portfolioId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSharing: false, feedback: UiFeedback(failure.message))),
      (url) => emit(state.copyWith(isSharing: false, portfolio: portfolio.copyWith(isPublic: true, shareUrl: url))),
    );
  }

  Future<void> disableShare() async {
    final portfolio = state.portfolio;
    if (portfolio == null) return;
    emit(state.copyWith(isSharing: true));
    final result = await _repo.disableShare(portfolioId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSharing: false, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(isSharing: false, portfolio: portfolio.copyWith(isPublic: false, clearShareUrl: true))),
    );
  }

  Future<void> deletePortfolio() async {
    emit(state.copyWith(isSaving: true));
    final result = await _repo.deletePortfolio(portfolioId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(isSaving: false, deleted: true)),
    );
  }

  /// Refetches first: the image URLs are signed and expire after 60 minutes.
  Future<void> exportPdf() async {
    emit(state.copyWith(isExporting: true));
    final result = await _repo.getPortfolio(portfolioId);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(state.copyWith(isExporting: false, feedback: UiFeedback(failure.message))),
      (portfolio) async {
        final images = <int, Uint8List>{};
        for (final item in portfolio.includedItems) {
          for (final file in item.files.where((f) => f.isImage)) {
            final bytes = await _repo.downloadBytes(file.url);
            bytes.fold((_) {}, (data) {
              if (data.isNotEmpty) images[file.id] = data;
            });
          }
        }
        final pdf = await _pdfBuilder(portfolio, images);
        if (isClosed) return;
        emit(state.copyWith(isExporting: false, portfolio: portfolio, pdfBytes: pdf));
      },
    );
  }

  Future<void> _save(Future<Either<Failure, Unit>> request, {String? successKey}) async {
    emit(state.copyWith(isSaving: true));
    final result = await request;
    if (isClosed) return;
    emit(state.copyWith(isSaving: false));
    await _afterMutation(result, successKey: successKey);
  }

  Future<void> _mutate(Future<Either<Failure, Unit>> request, {String? successKey}) async {
    final result = await request;
    if (isClosed) return;
    await _afterMutation(result, successKey: successKey);
  }

  /// Reloads after every change so completion and missing items stay right.
  Future<void> _afterMutation(Either<Failure, Unit> result, {String? successKey}) async {
    await result.fold(
      (failure) async {
        emit(state.copyWith(feedback: UiFeedback(failure.message)));
        await refresh();
      },
      (_) async {
        await refresh();
        if (successKey != null && !isClosed) {
          emit(state.copyWith(feedback: UiFeedback(successKey, isError: false)));
        }
      },
    );
  }

  void _replaceItem(PortfolioItemModel updated) {
    final portfolio = state.portfolio;
    if (portfolio == null) return;
    emit(state.copyWith(
      portfolio: portfolio.copyWith(
        items: portfolio.items.map((item) => item.id == updated.id ? updated : item).toList(),
      ),
    ));
  }
}
