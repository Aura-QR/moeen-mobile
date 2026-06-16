import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  int selectedCategoryIndex = 0;
  final TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    emit(HomeSearchChanged(query: query));
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex = index;
    emit(HomeCategoryChanged(selectedIndex: index));
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
