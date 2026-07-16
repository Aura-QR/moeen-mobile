import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/services/madrasati_session_service.dart';

/// A [QueuedInterceptor] that silently refreshes the Madrasati session
/// whenever the backend returns a session-expired error.
///
/// ## How it works
/// 1. Catches `DioException` with:
///    - Status 401, OR
///    - Status 422 with `code: "missing_madrasati_auth_cookie"`
/// 2. Reads the saved `refreshToken` and `schoolId` from [SecureStorageHelper].
/// 3. Calls `POST /api/madrasati/refresh-session` to get a new session.
/// 4. On success: saves the new `session_cookie` and `refresh_token`, then
///    replays the original failed request transparently.
/// 5. On failure (refresh itself returns 401): clears stored credentials and
///    fires `MadrasatiSessionService.notifySessionExpired()` to prompt the
///    user to do a manual WebView login.
///
/// Using [QueuedInterceptor] ensures that if multiple requests fail at the
/// same time, only ONE refresh call is made; the rest are queued and retried
/// once the refresh completes.
class MadrasatiSessionInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageHelper _secureStorage;
  final MadrasatiSessionService _sessionService;

  MadrasatiSessionInterceptor({
    required Dio dio,
    required SecureStorageHelper secureStorage,
    required MadrasatiSessionService sessionService,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _sessionService = sessionService;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip: if this request is the refresh call itself (avoid infinite loop)
    if (err.requestOptions.path.contains(refreshMadrasatiSessionApi)) {
      debugPrint('⏭️ [Interceptor] Skipping — request is the refresh call itself');
      return handler.next(err);
    }

    final response = err.response;
    final bool isMadrasatiSessionError = _isMadrasatiSessionError(response);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🛡️  [MadrasatiSessionInterceptor] onError() triggered');
    debugPrint('   failed request : ${err.requestOptions.method} ${err.requestOptions.path}');
    debugPrint('   statusCode     : ${response?.statusCode}');
    debugPrint('   isMadrasatiErr : $isMadrasatiSessionError');
    if (response?.data != null) {
      debugPrint('   error body     : ${response?.data}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!isMadrasatiSessionError) {
      debugPrint('⏭️ [Interceptor] Not a Madrasati session error — passing through');
      return handler.next(err);
    }

    debugPrint('🔄 [Interceptor] Madrasati session error detected — attempting silent refresh…');

    try {
      // 1. Read saved credentials
      debugPrint('');
      debugPrint('📂 [Interceptor] Step 1 — Reading saved credentials from SecureStorage…');
      final savedSession = await _secureStorage.getMadrasatiSession();
      final refreshToken = savedSession?.refreshToken;
      final schoolId = savedSession?.schoolId;

      debugPrint('   schoolId      : ${schoolId ?? '❌ null'}');
      debugPrint('   refreshToken  : ${refreshToken != null && refreshToken.isNotEmpty ? '✅ "${refreshToken.substring(0, refreshToken.length.clamp(0, 30))}…"' : '❌ null or empty'}');

      if (refreshToken == null ||
          refreshToken.isEmpty ||
          schoolId == null ||
          schoolId.isEmpty) {
        debugPrint('⚠️ [Interceptor] No refresh_token or schoolId — cannot silent refresh → notifySessionExpired()');
        _sessionService.notifySessionExpired();
        return handler.next(err);
      }

      // 2. Call the silent refresh endpoint
      debugPrint('');
      debugPrint('📡 [Interceptor] Step 2 — Calling POST $refreshMadrasatiSessionApi …');
      debugPrint('   payload: { refresh_token: "${refreshToken.substring(0, refreshToken.length.clamp(0, 20))}…", madrasati_school_id: "$schoolId" }');

      final refreshResponse = await _dio.post(
        refreshMadrasatiSessionApi,
        data: {
          'refresh_token': refreshToken,
          'madrasati_school_id': schoolId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // ── طباعة كاملة لكل حقل راجع من /madrasati/refresh-session ──────────
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────────────────────┐');
      debugPrint('│   📦 /refresh-session RESPONSE — Full Breakdown          │');
      debugPrint('├─────────────────────────────────────────────────────────┤');
      debugPrint('│ HTTP statusCode : ${refreshResponse.statusCode}');
      debugPrint('├─────────────────────────────────────────────────────────┤');
      debugPrint('│ [top-level]                                              │');
      debugPrint('│   success  : ${refreshResponse.data['success']}');
      debugPrint('│   message  : ${refreshResponse.data['message']}');
      debugPrint('├─────────────────────────────────────────────────────────┤');
      debugPrint('│ [data] object:                                           │');

      final rawData = refreshResponse.data['data'];
      if (rawData == null) {
        debugPrint('│   ⚠️  data is NULL — backend did not return a data object');
      } else {
        final d = rawData as Map;

        final sCookie = d['session_cookie'] as String?;
        debugPrint('│   session_cookie    : ${sCookie != null ? '✅ "${sCookie.substring(0, sCookie.length.clamp(0, 30))}…"' : '❌ null'}');

        final newRT = d['new_refresh_token'] as String?;
        debugPrint('│   new_refresh_token : ${newRT != null ? '✅ "${newRT.substring(0, newRT.length.clamp(0, 30))}…"' : '❌ null — old token will be reused'}');

        final rt = d['refresh_token'] as String?;
        debugPrint('│   refresh_token     : ${rt != null ? '✅ "${rt.substring(0, rt.length.clamp(0, 30))}…"' : '❌ null'}');

        final exp = d['expires_at'];
        debugPrint('│   expires_at        : ${exp ?? '❌ null — fallback: now + 30 days'}');

        final knownKeys = {'session_cookie', 'new_refresh_token', 'refresh_token', 'expires_at'};
        final extras = d.keys.where((k) => !knownKeys.contains(k)).toList();
        if (extras.isNotEmpty) {
          debugPrint('│   [extra fields]    : $extras');
        }
      }
      debugPrint('└─────────────────────────────────────────────────────────┘');
      debugPrint('');

      final refreshData = refreshResponse.data;
      final bool success = refreshData['success'] == true;

      if (!success) {
        debugPrint('❌ [Interceptor] success=false → notifySessionExpired()');
        _sessionService.notifySessionExpired();
        return handler.next(err);
      }

      // 3. Extract and save the new session data
      debugPrint('💾 [Interceptor] Step 3 — Saving new session to SecureStorage…');
      final data = refreshData['data'] as Map<String, dynamic>?;
      final newSessionCookie = data?['session_cookie'] as String?;
      final newRefreshToken = data?['new_refresh_token'] as String?;
      final expiresAtRaw = data?['expires_at'] as String?;

      if (newSessionCookie == null || newSessionCookie.isEmpty) {
        debugPrint('❌ [Interceptor] session_cookie missing in refresh response → notifySessionExpired()');
        _sessionService.notifySessionExpired();
        return handler.next(err);
      }

      final expiresAt = expiresAtRaw != null
          ? DateTime.tryParse(expiresAtRaw.replaceAll(' ', 'T'))
          : DateTime.now().add(const Duration(days: 30));

      final tokenSaved = newRefreshToken ?? refreshToken;
      debugPrint('   refresh_token to save : ${newRefreshToken != null ? '✅ new token from backend' : '⚠️  no new token — reusing old token'}');
      debugPrint('   expiresAt parsed      : $expiresAt');

      await _secureStorage.saveMadrasatiSession(
        MadrasatiSessionData(
          sessionCookie: newSessionCookie,
          schoolId: schoolId,
          expiresAt: expiresAt,
          refreshToken: tokenSaved,
        ),
      );
      debugPrint('   SecureStorage saved ✅');

      _sessionService.notifySessionActive();
      debugPrint('🔔 [Interceptor] notifySessionActive() called ✅');

      // 4. Replay the original failed request
      debugPrint('');
      debugPrint('🔁 [Interceptor] Step 4 — Replaying original request: ${err.requestOptions.method} ${err.requestOptions.path}');
      final opts = err.requestOptions;
      final retryResponse = await _dio.request<dynamic>(
        opts.path,
        data: opts.data,
        queryParameters: opts.queryParameters,
        options: Options(
          method: opts.method,
          headers: opts.headers,
          responseType: opts.responseType,
          contentType: opts.contentType,
        ),
      );
      debugPrint('✅ [Interceptor] Retry succeeded — statusCode: ${retryResponse.statusCode}');

      return handler.resolve(retryResponse);
    } on DioException catch (refreshErr) {
      final statusCode = refreshErr.response?.statusCode;

      // ── نفرّق: خطأ شبكة (انقطاع) vs خطأ مصادقة (session منتهية) ────────
      // لو مفيش response = مشكلة شبكة مش مصادقة
      final bool isNetworkError = refreshErr.response == null;

      debugPrint('');
      debugPrint('💥 [Interceptor] DioException during refresh call!');
      debugPrint('   statusCode    : ${statusCode ?? '❌ null (no response)'}');
      debugPrint('   isNetworkErr  : $isNetworkError');
      debugPrint('   error body    : ${refreshErr.response?.data}');
      debugPrint('   message       : ${refreshErr.message}');

      if (isNetworkError) {
        // ✋ انقطع الإنترنت — مش نظهر الدايلوج ومش نحذف الجلسة
        debugPrint('📵 [Interceptor] Network error — passing through WITHOUT showing dialog');
        return handler.next(err);
      }

      // خطأ مصادقة حقيقي (401/403/...) — لازم يعمل connect من أول
      if (statusCode == 401 || statusCode == 403) {
        await _secureStorage.deleteMadrasatiSession();
        debugPrint('🗑️ [Interceptor] refresh_token rejected ($statusCode) — cleared all session data');
      }

      _sessionService.notifySessionExpired();
      debugPrint('❌ [Interceptor] notifySessionExpired() called → SessionExpiredDialog will show');
      return handler.next(err);
    } catch (e, st) {
      debugPrint('💥 [Interceptor] Unexpected error: $e');
      debugPrint('   StackTrace: $st');
      // خطأ غير متوقع — نعامله كخطأ شبكة (مش نظهر الدايلوج)
      debugPrint('⚠️ [Interceptor] Unexpected error — passing through WITHOUT showing dialog');
      return handler.next(err);
    }
  }


  /// Returns true if the response indicates a Madrasati session problem.
  bool _isMadrasatiSessionError(Response<dynamic>? response) {
    if (response == null) return false;

    final statusCode = response.statusCode;
    if (statusCode == null) return false;

    if (response.data is Map) {
      final data = response.data as Map;
      final code = data['code']?.toString() ?? '';
      
      // Standard App Authentication Error (Bearer token expired/missing)
      // We should NOT treat this as a Madrasati session error!
      if (statusCode == 401 && code == 'unauthenticated') {
        return false;
      }

      // 422 with specific Madrasati session error codes
      if (statusCode == 422 || statusCode == 401) {
        return code == 'missing_madrasati_auth_cookie' ||
            code == 'madrasati_session_expired' ||
            code == 'madrasati_session_required';
      }
    }

    return false;
  }
}
