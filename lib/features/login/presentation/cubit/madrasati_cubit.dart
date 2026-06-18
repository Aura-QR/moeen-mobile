import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

abstract class MadrasatiState {}

class MadrasatiInitialState extends MadrasatiState {}

class MadrasatiLoadingState extends MadrasatiState {}

class MadrasatiSuccessState extends MadrasatiState {
  final String message;
  MadrasatiSuccessState(this.message);
}

class MadrasatiErrorState extends MadrasatiState {
  final String message;
  MadrasatiErrorState(this.message);
}

class MadrasatiCubit extends Cubit<MadrasatiState> {
  MadrasatiCubit() : super(MadrasatiInitialState());

  static MadrasatiCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> connectMadrasati({
    required String sessionCookie,
    required String madrasatiSchoolId,
    required String expiresAt,
  }) async {
    emit(MadrasatiLoadingState());

    try {
      final response = await DioHelper.postData(
        url: connectMadrasatiApi,
        data: {
          'session_cookie': sessionCookie,
          'madrasati_school_id': madrasatiSchoolId,
          'expires_at': expiresAt,
        },
      );

      response.fold(
        (error) => emit(MadrasatiErrorState(error)),
        (res) {
          final success = res.data['success'] ?? false;
          final message =
              res.data['message'] as String? ?? 'Connected successfully';
          if (success) {
            emit(MadrasatiSuccessState(message));
          } else {
            emit(MadrasatiErrorState(message));
          }
        },
      );
    } catch (e) {
      emit(MadrasatiErrorState(e.toString()));
    }
  }
}
