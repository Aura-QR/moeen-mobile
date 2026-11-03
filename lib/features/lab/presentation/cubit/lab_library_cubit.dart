import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/data/models/lab_site_page.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:url_launcher/url_launcher.dart';

part 'lab_library_state.dart';

/// L8 «معمل حضر الافتراضي»: Virtual Lab experiments list cubit.
class LabLibraryCubit extends Cubit<LabLibraryState> {
  static LabLibraryCubit get(BuildContext context) => BlocProvider.of(context);

  LabLibraryCubit({
    required LabRepository labRepository,
    Duration searchDebounce = const Duration(milliseconds: 400),
    Future<bool> Function(Uri uri)? urlLauncher,
    int? initialLessonId,
    String? initialLessonTitle,
  })  : _labRepository = labRepository,
        _searchDebounce = searchDebounce,
        _urlLauncher = urlLauncher ?? _launchExternally,
        super(LabLibraryState(
          lessonId: initialLessonId,
          lessonTitle: initialLessonTitle,
        ));

  final LabRepository _labRepository;
  final Duration _searchDebounce;
  final Future<bool> Function(Uri uri) _urlLauncher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  Future<void> init() async {
    await Future.wait([
      load(),
      loadFilters(),
    ]);
  }

  Future<void> loadFilters() async {
    final result = await _labRepository.getFilters();
    if (isClosed) return;
    result.fold(
      (_) => null,
      (filters) => emit(state.copyWith(filters: filters)),
    );
  }

  Future<void> load() async {
    if (state.experiments.isEmpty) {
      emit(state.copyWith(status: LabLibraryStatus.loading));
    }

    final result = await _labRepository.getExperiments(
      page: 1,
      search: searchController.text.trim(),
      stageId: state.selectedStageId,
      gradeId: state.selectedGradeId,
      subjectId: state.selectedSubjectId,
      subjectGroup: state.selectedSubjectGroup,
      lessonId: state.lessonId,
      sort: state.sort,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.experiments.isEmpty
            ? state.copyWith(
                status: LabLibraryStatus.failure,
                errorMessage: failure.message,
              )
            : state.copyWith(feedback: UiFeedback(failure.message)),
      ),
      (page) => emit(
        state.copyWith(
          status: LabLibraryStatus.success,
          experiments: page.items,
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != LabLibraryStatus.success) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final result = await _labRepository.getExperiments(
      page: state.page + 1,
      search: searchController.text.trim(),
      stageId: state.selectedStageId,
      gradeId: state.selectedGradeId,
      subjectId: state.selectedSubjectId,
      subjectGroup: state.selectedSubjectGroup,
      lessonId: state.lessonId,
      sort: state.sort,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          feedback: UiFeedback(failure.message),
        ),
      ),
      (page) => emit(
        state.copyWith(
          isLoadingMore: false,
          experiments: [...state.experiments, ...page.items],
          page: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (!isClosed) load();
    });
  }

  /// Opens a site-only page (create / request an experiment) in the phone's
  /// browser, since the teacher's login cannot be passed to the site.
  Future<void> openSitePage(LabSitePage page) async {
    bool opened;
    try {
      opened = await _urlLauncher(page.uri);
    } catch (_) {
      opened = false;
    }
    if (opened || isClosed) return;
    emit(state.copyWith(
      feedback: const UiFeedback('lab_open_link_error', isError: true),
    ));
  }

  void setSort(String sort) {
    if (state.sort == sort) return;
    emit(state.copyWith(sort: sort));
    load();
  }

  void setStage(int? stageId) {
    if (state.selectedStageId == stageId) {
      emit(state.copyWith(clearStage: true, clearGrade: true, clearSubject: true));
    } else {
      emit(state.copyWith(
        selectedStageId: stageId,
        clearGrade: true,
        clearSubject: true,
      ));
    }
    load();
  }

  void setGrade(int? gradeId) {
    if (state.selectedGradeId == gradeId) {
      emit(state.copyWith(clearGrade: true, clearSubject: true));
    } else {
      emit(state.copyWith(
        selectedGradeId: gradeId,
        clearSubject: true,
      ));
    }
    load();
  }

  void setSubject(int? subjectId) {
    if (state.selectedSubjectId == subjectId) {
      emit(state.copyWith(clearSubject: true));
    } else {
      emit(state.copyWith(selectedSubjectId: subjectId));
    }
    load();
  }

  void setSubjectGroup(String? groupKey) {
    if (state.selectedSubjectGroup == groupKey) {
      emit(state.copyWith(clearSubjectGroup: true));
    } else {
      emit(state.copyWith(selectedSubjectGroup: groupKey));
    }
    load();
  }

  void clearFilters() {
    emit(state.copyWith(
      clearStage: true,
      clearGrade: true,
      clearSubject: true,
      clearSubjectGroup: true,
    ));
    load();
  }

  void clearLessonFilter() {
    emit(state.copyWith(clearLesson: true));
    load();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
