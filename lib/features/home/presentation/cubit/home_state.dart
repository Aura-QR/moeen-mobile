part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeSearchChanged extends HomeState {
  final String query;
  HomeSearchChanged({required this.query});
}

class HomeCategoryChanged extends HomeState {
  final int selectedIndex;
  HomeCategoryChanged({required this.selectedIndex});
}
