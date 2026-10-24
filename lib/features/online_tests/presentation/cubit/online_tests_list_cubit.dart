import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';

class OnlineTestsListState {
  final List<OnlineTest> tests;
  final bool isLoading;
  final String? error;

  const OnlineTestsListState({this.tests = const [], this.isLoading = true, this.error});
}

/// «اختباراتي الإلكترونية».
class OnlineTestsListCubit extends Cubit<OnlineTestsListState> {
  final OnlineTestsRepository _repository;

  OnlineTestsListCubit(this._repository) : super(const OnlineTestsListState());

  static OnlineTestsListCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    emit(OnlineTestsListState(tests: state.tests));
    final result = await _repository.getTests();
    if (isClosed) return;
    result.fold(
      (failure) => emit(OnlineTestsListState(tests: state.tests, isLoading: false, error: failure.message)),
      (tests) => emit(OnlineTestsListState(tests: tests, isLoading: false)),
    );
  }
}
