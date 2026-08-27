import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/core/theme/theme.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/core/widgets/session_monitor_wrapper.dart';
import 'dart:developer' as developer;
import 'package:moean/core/services/referral_service.dart';
import 'package:moean/core/utils/constants/secrets.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MyFatoorah SDK early to avoid delay issues during checkout
  MFSDK.init(Secrets.myfatoorahApiKey, MFCountry.SAUDIARABIA, MFEnvironment.LIVE);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await initInjections();

  // Initialize ReferralService safely in the background
  // We do not await it tightly so it doesn't block startup
  ReferralService.init().catchError((e) {
    developer.log('ReferralService init error: $e');
  });

  final bool isDark = CacheHelper.getData(key: 'isDark') ?? false;
  final bool isArabic = CacheHelper.getData(key: 'isArabicLang') ?? true;

  developer.log('Main: Loading translations...');
  final String translation = await rootBundle.loadString(
    'assets/translations/${isArabic ? 'ar' : 'en'}.json',
  );
  developer.log('Main: Translations loaded');

  // ── Restore token from secure storage ──────────────────────────
  final secureStorage = sl<SecureStorageHelper>();
  final String? savedToken = await secureStorage.getToken();

  String initialRoute = Routes.login;

  if (savedToken != null && savedToken.isNotEmpty) {
    // Token found – verify it is still valid via /auth/me
    token = savedToken;
    developer.log('Main: Token found, verifying via /auth/me...');

    final meResult = await ApiService.getMe();

    meResult.fold(
      (error) {
        // 401 or network error – clear token
        developer.log('Main: Token invalid ($error), clearing...');
        token = null;
        secureStorage.deleteToken();
        initialRoute = Routes.home; // start at home
      },
      (user) {
        developer.log('Main: Token valid, user=${user.name}');
        if (user.email == 'admin@moeen.com' || user.email == 'admin@moeen.sa') {
          initialRoute = Routes.adminTeachers;
        } else {
          initialRoute = Routes.home; // start at home
        }
        sl<MadrasatiSessionService>().notifySessionActive();
      },
    );
  } else {
    developer.log('Main: No token found, going to home');
    initialRoute = Routes.home;
  }

  runApp(MyApp(
    isDark: isDark,
    isArabic: isArabic,
    translation: translation,
    initialRoute: initialRoute,
  ));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final bool isArabic;
  final String translation;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.isDark,
    required this.isArabic,
    required this.translation,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeCubit = sl<ThemeCubit>();
    themeCubit
      ..init(isDark: isDark)
      ..initializeLanguage(isArabic: isArabic, translations: translation);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final themeCubit = context.read<ThemeCubit>();

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            routes: Routes.routes,
            initialRoute: initialRoute,
            theme: ThemesManager.lightTheme,
            darkTheme: ThemesManager.darkTheme,
            locale: themeCubit.isArabicLang ? const Locale('ar') : const Locale('en'),
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode:
                themeCubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              return Directionality(
                textDirection: themeCubit.isArabicLang
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                // SessionMonitorWrapper listens to session expiry globally
                child: SessionMonitorWrapper(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
