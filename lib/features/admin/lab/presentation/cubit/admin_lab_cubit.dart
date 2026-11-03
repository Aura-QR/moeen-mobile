import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';
import 'package:moean/features/admin/lab/data/repositories/admin_lab_repository.dart';

part 'admin_lab_state.dart';

class AdminLabCubit extends Cubit<AdminLabState> {
  static AdminLabCubit get(BuildContext context) => BlocProvider.of(context);

  AdminLabCubit({
    required AdminLabRepository adminLabRepository,
    Duration searchDebounce = const Duration(milliseconds: 400),
  })  : _repository = adminLabRepository,
        _searchDebounce = searchDebounce,
        super(const AdminLabState());

  final AdminLabRepository _repository;
  final Duration _searchDebounce;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  Future<void> init() async {
    await Future.wait([
      fetchExperiments(),
      fetchReports(),
      fetchRequests(),
    ]);
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!isClosed) fetchExperiments();
    });
  }

  void setTab(int tab) {
    if (state.currentTab == tab) return;
    emit(state.copyWith(currentTab: tab));
  }

  Future<void> fetchExperiments() async {
    emit(state.copyWith(isLoadingExperiments: true));

    String? status;
    String? source;
    bool? hasReports;

    if (state.experimentFilter == 'hidden') {
      status = 'hidden';
    } else if (state.experimentFilter == 'community') {
      source = 'community';
    } else if (state.experimentFilter == 'reports') {
      hasReports = true;
    }

    final result = await _repository.getExperiments(
      status: status,
      source: source,
      hasReports: hasReports,
      search: searchController.text.trim(),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingExperiments: false,
        errorMessage: failure.message,
      )),
      (list) => emit(state.copyWith(
        isLoadingExperiments: false,
        experiments: list,
      )),
    );
  }

  Future<void> fetchReports() async {
    emit(state.copyWith(isLoadingReports: true));

    final result = await _repository.getReports(status: state.reportFilter);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingReports: false,
        errorMessage: failure.message,
      )),
      (list) => emit(state.copyWith(
        isLoadingReports: false,
        reports: list,
      )),
    );
  }

  Future<void> fetchRequests() async {
    emit(state.copyWith(isLoadingRequests: true));

    final result = await _repository.getRequests(status: state.requestFilter);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingRequests: false,
        errorMessage: failure.message,
      )),
      (list) => emit(state.copyWith(
        isLoadingRequests: false,
        requests: list,
      )),
    );
  }

  Future<void> toggleApproveExperiment(
    AdminLabExperimentModel experiment,
  ) async {
    final newApproved = !experiment.approved;
    emit(state.copyWith(isActionInProgress: true));

    final result = await _repository.updateExperiment(
      experiment.key,
      approve: newApproved,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isActionInProgress: false,
        feedback: UiFeedback(failure.message, isError: true),
      )),
      (_) {
        final updated = state.experiments.map((e) {
          return e.key == experiment.key ? e.copyWith(approved: newApproved) : e;
        }).toList();

        emit(state.copyWith(
          isActionInProgress: false,
          experiments: updated,
          feedback: const UiFeedback('admin_lab_action_success', isError: false),
        ));
      },
    );
  }

  Future<void> togglePublishExperiment(
    AdminLabExperimentModel experiment,
  ) async {
    final newStatus = experiment.isPublished ? 'hidden' : 'published';
    emit(state.copyWith(isActionInProgress: true));

    final result = await _repository.updateExperiment(
      experiment.key,
      status: newStatus,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isActionInProgress: false,
        feedback: UiFeedback(failure.message, isError: true),
      )),
      (_) {
        final updated = state.experiments.map((e) {
          return e.key == experiment.key ? e.copyWith(status: newStatus) : e;
        }).toList();

        emit(state.copyWith(
          isActionInProgress: false,
          experiments: updated,
          feedback: const UiFeedback('admin_lab_action_success', isError: false),
        ));
      },
    );
  }

  Future<void> toggleFeatureExperiment(
    AdminLabExperimentModel experiment,
  ) async {
    final newFeatured = !experiment.featured;
    emit(state.copyWith(isActionInProgress: true));

    final result = await _repository.updateExperiment(
      experiment.key,
      featured: newFeatured,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isActionInProgress: false,
        feedback: UiFeedback(failure.message, isError: true),
      )),
      (_) {
        final updated = state.experiments.map((e) {
          return e.key == experiment.key ? e.copyWith(featured: newFeatured) : e;
        }).toList();

        emit(state.copyWith(
          isActionInProgress: false,
          experiments: updated,
          feedback: const UiFeedback('admin_lab_action_success', isError: false),
        ));
      },
    );
  }

  Future<void> toggleReportStatus(AdminLabMistakeReportModel report) async {
    final newStatus = report.isOpen ? 'done' : 'open';
    emit(state.copyWith(isActionInProgress: true));

    final result = await _repository.updateReportStatus(report.id, newStatus);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isActionInProgress: false,
        feedback: UiFeedback(failure.message, isError: true),
      )),
      (_) {
        final updated = state.reports.map((r) {
          return r.id == report.id ? r.copyWith(status: newStatus) : r;
        }).toList();

        emit(state.copyWith(
          isActionInProgress: false,
          reports: updated,
          feedback: const UiFeedback('admin_lab_action_success', isError: false),
        ));
      },
    );
  }

  Future<void> toggleRequestStatus(AdminLabRequestModel req) async {
    final newStatus = req.isOpen ? 'done' : 'open';
    emit(state.copyWith(isActionInProgress: true));

    final result = await _repository.updateRequestStatus(req.id, newStatus);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        isActionInProgress: false,
        feedback: UiFeedback(failure.message, isError: true),
      )),
      (_) {
        final updated = state.requests.map((r) {
          return r.id == req.id ? r.copyWith(status: newStatus) : r;
        }).toList();

        emit(state.copyWith(
          isActionInProgress: false,
          requests: updated,
          feedback: const UiFeedback('admin_lab_action_success', isError: false),
        ));
      },
    );
  }

  void setExperimentFilter(String? filter) {
    if (state.experimentFilter == filter) {
      emit(state.copyWith(clearExperimentFilter: true));
    } else {
      emit(state.copyWith(experimentFilter: filter));
    }
    fetchExperiments();
  }

  void setReportFilter(String? filter) {
    if (state.reportFilter == filter) {
      emit(state.copyWith(clearReportFilter: true));
    } else {
      emit(state.copyWith(reportFilter: filter));
    }
    fetchReports();
  }

  void setRequestFilter(String? filter) {
    if (state.requestFilter == filter) {
      emit(state.copyWith(clearRequestFilter: true));
    } else {
      emit(state.copyWith(requestFilter: filter));
    }
    fetchRequests();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
