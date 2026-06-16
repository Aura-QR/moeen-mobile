import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  sl.registerLazySingleton(
    () => ThemeCubit(),
  );
 
  final sharedPref = await SharedPreferences.getInstance();
  sl.registerLazySingleton(
    () => sharedPref,
  );

  sl.registerLazySingleton(
    () {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
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
    },
  );
}
