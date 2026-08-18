import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/search/data/repositories/search_repository.dart';
import 'package:moean/features/search/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  final SearchRepository _repository = SearchRepository();

  String _activeFilter = 'all';
  String _lastQuery = '';

  String get activeFilter => _activeFilter;

  static const Map<String, String?> _filterTypeMap = {
    'all': null,
    'questions': 'questions',
    'resources': 'resources',
    'exams': 'exams',
    'lessons': 'lessons',
  };

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    _lastQuery = query.trim();
    if (!isClosed) emit(const SearchLoading());

    final typeParam = _filterTypeMap[_activeFilter];

    final result = await _repository.search(
      query: _lastQuery,
      type: typeParam,
      limit: 20,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(SearchError(message: error));
      },
      (items) {
        if (!isClosed) {
          if (items.isEmpty) {
            emit(SearchEmpty(query: _lastQuery));
          } else {
            emit(SearchLoaded(
              results: items,
              query: _lastQuery,
              activeFilter: _activeFilter,
            ));
          }
        }
      },
    );
  }

  Future<void> changeFilter(String filter) async {
    if (_activeFilter == filter) return;
    _activeFilter = filter;

    if (_lastQuery.isNotEmpty) {
      await search(_lastQuery);
    } else {
      if (!isClosed) emit(const SearchInitial());
    }
  }

  void reset() {
    _lastQuery = '';
    _activeFilter = 'all';
    if (!isClosed) emit(const SearchInitial());
  }
}
