part of 'role_suites_cubit.dart';

enum RoleSuitesStatus { loading, success, failure }

class RoleSuitesState {
  final RoleSuitesStatus status;
  final List<RoleSuiteSummary> roles;
  final String? matchedRoleKey;
  final String? errorMessage;

  const RoleSuitesState({
    this.status = RoleSuitesStatus.loading,
    this.roles = const [],
    this.matchedRoleKey,
    this.errorMessage,
  });

  RoleSuitesState copyWith({
    RoleSuitesStatus? status,
    List<RoleSuiteSummary>? roles,
    String? matchedRoleKey,
    bool clearMatchedRole = false,
    String? errorMessage,
  }) {
    return RoleSuitesState(
      status: status ?? this.status,
      roles: roles ?? this.roles,
      matchedRoleKey: clearMatchedRole ? null : (matchedRoleKey ?? this.matchedRoleKey),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
