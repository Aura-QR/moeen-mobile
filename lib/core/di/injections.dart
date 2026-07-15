import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/madrasati_session_interceptor.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart' as moean_exam;
import 'package:moean/features/exam_generation/data/repositories/exam_repository_impl.dart' as moean_exam;
import 'package:moean/features/exam_generation/domain/usecases/generate_exam_usecase.dart' as moean_exam;
import 'package:moean/features/exam_generation/domain/usecases/get_exam_usecase.dart' as moean_exam;
import 'package:moean/features/exam_generation/domain/usecases/update_question_points_usecase.dart' as moean_exam;
import 'package:moean/features/exam_generation/domain/usecases/add_manual_question_usecase.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/lesson_selection_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/question_count_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/generate_exam_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/exam_preview_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart' as moean_exam;
import 'package:moean/features/exam_generation/presentation/cubit/manual_exam_cubit.dart' as moean_exam;

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

  // ─── Session Service ──────────────────────────────────────────
  sl.registerLazySingleton<MadrasatiSessionService>(
    () => MadrasatiSessionService(),
  );

  // ─── Dio ──────────────────────────────────────────────────────
  // NOTE: Dio is registered first without the session interceptor,
  // then the interceptor is added afterwards (because the interceptor
  // itself needs the Dio instance to replay requests).
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // ── Language header interceptor ─────────────────────────────
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

    // ── Madrasati silent session refresh interceptor ─────────────
    // Uses QueuedInterceptor to ensure only one refresh request
    // fires even if multiple API calls fail simultaneously.
    dio.interceptors.add(
      MadrasatiSessionInterceptor(
        dio: dio,
        secureStorage: sl<SecureStorageHelper>(),
        sessionService: sl<MadrasatiSessionService>(),
      ),
    );

    return dio;
  });

  // ─── Exam Generation ──────────────────────────────────────────
  sl.registerLazySingleton<moean_exam.ExamRepository>(() => moean_exam.ExamRepositoryImpl());
  sl.registerLazySingleton(() => moean_exam.GenerateExamUseCase(sl()));
  sl.registerLazySingleton(() => moean_exam.GetExamUseCase(sl()));
  sl.registerLazySingleton(() => moean_exam.UpdateQuestionPointsUseCase(sl()));
  sl.registerLazySingleton(() => moean_exam.AddManualQuestionUseCase(sl()));

  sl.registerLazySingleton(() => moean_exam.ExamInfoCubit());
  sl.registerLazySingleton(() => moean_exam.LessonSelectionCubit());
  sl.registerLazySingleton(() => moean_exam.QuestionCountCubit());
  sl.registerFactory(() => moean_exam.GenerateExamCubit(sl()));
  sl.registerFactory(() => moean_exam.ExamPreviewCubit(
        getExamUseCase: sl(),
        updateQuestionPointsUseCase: sl(),
        examRepository: sl(),
      ));
  sl.registerFactory(() => moean_exam.MyExamsCubit(sl()));
  sl.registerFactory(() => moean_exam.ManualExamCubit(sl()));
}

