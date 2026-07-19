import 'package:moean/features/search/data/models/search_result_model.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<SearchResultModel> results;
  final String query;
  final String activeFilter;

  const SearchLoaded({
    required this.results,
    required this.query,
    required this.activeFilter,
  });
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});
}
