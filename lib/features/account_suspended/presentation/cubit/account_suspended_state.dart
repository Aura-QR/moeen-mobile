abstract class AccountSuspendedState {}

class AccountSuspendedInitialState extends AccountSuspendedState {}

class AccountSuspendedCheckingState extends AccountSuspendedState {}

class AccountSuspendedActiveState extends AccountSuspendedState {}

class AccountSuspendedStillSuspendedState extends AccountSuspendedState {
  final String message;
  AccountSuspendedStillSuspendedState({required this.message});
}

class AccountSuspendedTypesLoadedState extends AccountSuspendedState {
  final List<dynamic> types;
  AccountSuspendedTypesLoadedState({required this.types});
}

class AccountSuspendedTypeSelectedState extends AccountSuspendedState {
  final String selectedType;
  AccountSuspendedTypeSelectedState({required this.selectedType});
}

class AccountSuspendedTicketSubmittingState extends AccountSuspendedState {}

class AccountSuspendedTicketSuccessState extends AccountSuspendedState {
  final String message;
  AccountSuspendedTicketSuccessState({required this.message});
}

class AccountSuspendedTicketErrorState extends AccountSuspendedState {
  final String message;
  AccountSuspendedTicketErrorState({required this.message});
}
