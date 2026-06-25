import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/services/madrasati_headless_refresh_service.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  // ─── Theme ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ThemeCubit());

  // ─── SharedPreferences (for non-sensitive prefs like theme) ───
  final sharedPref = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPref);

  // ─── Secure Storage ──────────────────────────────────────────
  const androidOptions = AndroidOptions(encryptedSharedPreferences: true);
  const secureStorage = FlutterSecureStorage(aOptions: androidOptions);
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(sl<FlutterSecureStorage>()),
  );

  // ─── Session Services ─────────────────────────────────────────
  sl.registerLazySingleton<MadrasatiSessionService>(
    () => MadrasatiSessionService(),
  );
  sl.registerLazySingleton<MadrasatiHeadlessRefreshService>(
    () => MadrasatiHeadlessRefreshService(
      sl<SecureStorageHelper>(),
      sl<MadrasatiSessionService>(),
    ),
  );

  // ─── Dio ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final isArabic = sl<ThemeCubit>().isArabicLang;
            options.headers['Accept-Language'] = isArabic ? 'ar' : 'en';
          } catch (_) {}
          return handler.next(options);
        },
      ),
    );
    return dio;
  });
}
