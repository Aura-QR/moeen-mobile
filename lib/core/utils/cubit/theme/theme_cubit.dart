import 'dart:convert';
import 'package:moean/core/di/injections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/utils/constants/translations.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';

ThemeCubit get themeCubit => sl<ThemeCubit>();

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitialState());
  static ThemeCubit get(BuildContext context) => BlocProvider.of(context);

  void init({bool isDark = false}) {
    _isDarkMode = isDark;
  }

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void changeTheme({bool? fromShared}) {
    _isDarkMode = fromShared ?? !_isDarkMode;
    CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
    emit(ThemeChangeThemeState());
  }

  bool _isArabicLang = false;
  TranslationModel? _translationModel;

  bool get isArabicLang => _isArabicLang;

  TranslationModel? get translationModel => _translationModel;

  Future<void> changeLanguage() async {
    try {
      emit(ThemeLanguageLoadingState());

      final newIsArabic = !_isArabicLang;
      final String translations = await rootBundle.loadString(
        'assets/translations/${newIsArabic ? 'ar' : 'en'}.json',
      );

      final model = TranslationModel.fromJson(json.decode(translations));
      _isArabicLang = newIsArabic;
      _translationModel = model;

      await CacheHelper.saveData(key: 'isArabicLang', value: _isArabicLang);
      emit(ThemeLanguageUpdatedState());
    } catch (e) {
      emit(ThemeLanguageErrorState(e.toString()));
    }
  }

  Future<void> initializeLanguage({
    required bool isArabic,
    required String translations,
  }) async {
    try {
      _isArabicLang = isArabic;
      _translationModel = TranslationModel.fromJson(json.decode(translations));
      CacheHelper.saveData(key: 'isArabicLang', value: _isArabicLang);
      emit(ThemeLanguageSuccessState());
    } catch (e) {
      emit(ThemeLanguageErrorState(e.toString()));
    }
  }
}
