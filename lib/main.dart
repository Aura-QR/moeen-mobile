import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/theme/theme.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'dart:developer' as developer;

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await initInjections();
    final bool isDark = CacheHelper.getData(key: 'isDark') ?? false;
    final bool isArabic = CacheHelper.getData(key: 'isArabicLang') ?? true;
    
    developer.log('Main: Loading translations...');
    final String translation = await rootBundle.loadString(
      'assets/translations/${isArabic ? 'ar' : 'en'}.json',
    );
    developer.log('Main: Translations loaded');

    runApp(MyApp(isDark: isDark, isArabic: isArabic, translation: translation));
    
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final bool isArabic;
  final String translation;

  const MyApp({
    super.key,
    required this.isDark,
    required this.isArabic,
    required this.translation,
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
        // BlocProvider(create: (context) => sl<AuthCubit>()..loadCachedUser()),
        // BlocProvider(create: (context) => sl<ProfileCubit>()),
        // BlocProvider(create: (context) => sl<NotificationCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final themeCubit = context.read<ThemeCubit>();

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            routes: Routes.routes,
          //  onGenerateRoute: Routes.onGenerateRoute,
            initialRoute: Routes.register,
            theme: ThemesManager.lightTheme,
            darkTheme: ThemesManager.darkTheme,
            themeMode: themeCubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              return Directionality(
                textDirection: themeCubit.isArabicLang
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}