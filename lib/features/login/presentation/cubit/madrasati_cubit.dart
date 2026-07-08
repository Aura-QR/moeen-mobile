import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/services/madrasati_session_service.dart';

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

  /// Connects the app to Madrasati by sending the session cookie.
  ///
  /// [sessionCookie] - The `.AspNetCore.Cookies` session string extracted
  ///   from the webview after the initial manual login.
  /// [madrasatiSchoolId] - The school's unique ID.
  /// [expiresAt] - Session expiry datetime string.
  /// [refreshToken] - The Microsoft OAuth refresh_token returned by the backend
  ///   after connecting. Used by [MadrasatiSessionInterceptor] to silently
  ///   refresh the session in the background when it expires.
  Future<void> connectMadrasati({
    required String sessionCookie,
    required String madrasatiSchoolId,
    required String expiresAt,
    String? refreshToken,
  }) async {
    // ══════════════════════════════════════════════════════════════════════
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚀 [MadrasatiCubit] connectMadrasati() ── START');
    debugPrint('   schoolId   : $madrasatiSchoolId');
    debugPrint('   expiresAt  : $expiresAt');
    debugPrint('   refreshToken (from caller): ${refreshToken != null ? '✅ "${refreshToken.substring(0, refreshToken.length.clamp(0, 20))}…"' : '❌ null'}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    emit(MadrasatiLoadingState());
    debugPrint('🔄 [MadrasatiCubit] State → MadrasatiLoadingState');

    try {
      debugPrint('📡 [MadrasatiCubit] Sending POST to: $connectMadrasatiApi');
      final response = await DioHelper.postData(
        url: connectMadrasatiApi,
        data: {
          'session_cookie': sessionCookie,
          'madrasati_school_id': madrasatiSchoolId,
          'expires_at': expiresAt,
        },
      );

      response.fold(
        (error) {
          debugPrint('💥 [MadrasatiCubit] API returned LEFT (error): $error');
          debugPrint('❌ [MadrasatiCubit] State → MadrasatiErrorState');
          emit(MadrasatiErrorState(error));

        },

        (res) async {
          debugPrint('📥 [MadrasatiCubit] API returned RIGHT (success path)');
          debugPrint('   statusCode : $res.statusCode');
          debugPrint('   statusCode : $res');


          // ── طباعة كل حقل بيرجع من الباك بالاسم ──────────────────────────
          debugPrint('');
          debugPrint('┌─────────────────────────────────────────────────────┐');
          debugPrint('│         📦 BACKEND RESPONSE — Full Breakdown         │');
          debugPrint('├─────────────────────────────────────────────────────┤');
          debugPrint('│ [top-level]                                          │');
          debugPrint('│   success  : ${res.data['success']}');
          debugPrint('│   message  : ${res.data['message']}');
          debugPrint('├─────────────────────────────────────────────────────┤');
          debugPrint('│ [data] object:                                       │');

          final dataObj = res.data['data'];
          debugPrint('│   data     : ${dataObj != null ? '✅ present' : '❌ null'}');
          if (dataObj == null) {
            debugPrint('│   ⚠️  data is NULL — backend did not return a data object');
          } else {
            // session_cookie — الكوكي الجديد
            final backendCookie = dataObj['session_cookie'] as String?;
            debugPrint('│   session_cookie    : ${backendCookie != null ? '✅ "${backendCookie.substring(0, backendCookie.length.clamp(0, 30))}…"' : '❌ null'}');

            // refresh_token — الاسم الأول المحتمل
            final rt1 = dataObj['refresh_token'] as String?;
            debugPrint('│   refresh_token     : ${rt1 != null ? '✅ "${rt1.substring(0, rt1.length.clamp(0, 30))}…"' : '❌ null'}');

            // new_refresh_token — الاسم الثاني المحتمل (مذكور ف خطة refresh-session)
            final rt2 = dataObj['new_refresh_token'] as String?;
            debugPrint('│   new_refresh_token : ${rt2 != null ? '✅ "${rt2.substring(0, rt2.length.clamp(0, 30))}…"' : '❌ null'}');
            
            // expires_at — وقت انتهاء الجلسة الجديدة
            final backendExpiry = dataObj['expires_at'];
            debugPrint('│   expires_at        : ${backendExpiry ?? '❌ null'}');

            // أي حقول تانية موجودة مش متوقعة
            final knownKeys = {'session_cookie', 'refresh_token', 'new_refresh_token', 'expires_at'};
            final extraKeys = (dataObj as Map).keys.where((k) => !knownKeys.contains(k)).toList();
            if (extraKeys.isNotEmpty) {
              debugPrint('│   [extra fields]    : $extraKeys');
            }
          }
          debugPrint('└─────────────────────────────────────────────────────┘');
          debugPrint('');

          final success = res.data['success'] ?? false;
          final message =
              res.data['message'] as String? ?? 'Connected successfully';

          if (success) {
            // ── Extract refresh_token from API response (if available) ────
            // The backend may return a refresh_token in the connect response,
            // or it can be passed in from the caller (e.g., WebView login flow).
            // Per integration plan: connect endpoint → 'refresh_token'
            //                       refresh endpoint → 'new_refresh_token'
            final apiRefreshToken =
                (res.data['data']?['refresh_token'] ??
                 res.data['data']?['new_refresh_token']) as String?;

            debugPrint('');
            debugPrint('🔑 [MadrasatiCubit] refresh_token trace:');
            debugPrint('   ├─ From API  response : ${apiRefreshToken != null ? '✅ "${apiRefreshToken.substring(0, apiRefreshToken.length.clamp(0, 30))}…"' : '❌ null (not in API response)'}');
            debugPrint('   ├─ From caller (param): ${refreshToken != null ? '✅ "${refreshToken.substring(0, refreshToken.length.clamp(0, 30))}…"' : '❌ null (not passed by caller)'}');

            final tokenToSave = apiRefreshToken ?? refreshToken;
            debugPrint('   └─ Final token to save: ${tokenToSave != null ? '✅ will be saved 🔐' : '⚠️  NO TOKEN — session refresh will NOT work!'}');
            debugPrint('');

            // ── Save session securely ─────────────────────────────────────
            final expiry = DateTime.tryParse(expiresAt.replaceAll(' ', 'T'));
            debugPrint('💾 [MadrasatiCubit] Saving session to SecureStorage…');
            await sl<SecureStorageHelper>().saveMadrasatiSession(
              MadrasatiSessionData(
                sessionCookie: sessionCookie,
                schoolId: madrasatiSchoolId,
                expiresAt: expiry,
                refreshToken: tokenToSave,
              ),
            );
            debugPrint('   Session saved ✅  (expiresAt parsed: $expiry)');

            // ── Notify session service that session is now active ─────────
            debugPrint('🔔 [MadrasatiCubit] Notifying MadrasatiSessionService…');
            sl<MadrasatiSessionService>().notifySessionActive();
            debugPrint('   notifySessionActive() called ✅');

            debugPrint('✅ [MadrasatiCubit] State → MadrasatiSuccessState("$message")');
            emit(MadrasatiSuccessState(message));
          } else {
            debugPrint('❌ [MadrasatiCubit] success=false → State → MadrasatiErrorState("$message")');
            emit(MadrasatiErrorState(message));
          }
        },
      );
    } catch (e, st) {
      debugPrint('💥 [MadrasatiCubit] Exception caught: $e');
      debugPrint('   StackTrace: $st');
      debugPrint('❌ [MadrasatiCubit] State → MadrasatiErrorState');
      emit(MadrasatiErrorState(e.toString()));
    }

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🏁 [MadrasatiCubit] connectMadrasati() ── END');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
