import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class TextStylesManager {
  static TextStyle _tajawal(double size, FontWeight weight) {
    return GoogleFonts.tajawal(
      fontSize: size,
      fontWeight: weight,
      height: 1.3,
    );
  }

  static TextStyle _aldhabi(double size, FontWeight weight) {
    return TextStyle(
      fontFamily: 'Aldhabi',
      fontSize: size,
      fontWeight: weight,
      height: 1.3,
    );
  }

  /// Regular text styles
  static TextStyle get regular8 => _tajawal(8.0, FontWeight.w400);

  static TextStyle get regular10 => _tajawal(10.0, FontWeight.w400);

  static TextStyle get regular12 => _tajawal(12.0, FontWeight.w400);

  static TextStyle get regular13 => _tajawal(13.0, FontWeight.w400);

  static TextStyle get regular14 => _tajawal(14.0, FontWeight.w400);

  static TextStyle get regular16 => _tajawal(16.0, FontWeight.w400);

  static TextStyle get regular18 => _tajawal(18.0, FontWeight.w400);

  static TextStyle get regular20 => _tajawal(20.0, FontWeight.w400);

  static TextStyle get regular22 => _tajawal(22.0, FontWeight.w400);

  static TextStyle get regular24 => _tajawal(24.0, FontWeight.w400);

  static TextStyle get regular40 => _tajawal(40.0, FontWeight.w400);

  /// Medium text styles
  static TextStyle get medium10 => _tajawal(10.0, FontWeight.w500);

  static TextStyle get medium12 => _tajawal(12.0, FontWeight.w500);

  static TextStyle get medium13 => _tajawal(13.0, FontWeight.w500);

  static TextStyle get medium14 => _tajawal(14.0, FontWeight.w500);

  static TextStyle get medium16 => _tajawal(16.0, FontWeight.w500);

  static TextStyle get medium18 => _tajawal(18.0, FontWeight.w500);

  static TextStyle get medium20 => _tajawal(20.0, FontWeight.w500);

  static TextStyle get medium22 => _tajawal(22.0, FontWeight.w500);

  static TextStyle get medium24 => _tajawal(24.0, FontWeight.w500);

  /// Bold text styles
  static TextStyle get bold10 => _tajawal(10.0, FontWeight.w700);

  static TextStyle get bold12 => _tajawal(12.0, FontWeight.w700);

  static TextStyle get bold13 => _tajawal(13.0, FontWeight.w700);

  static TextStyle get bold14 => _tajawal(14.0, FontWeight.w700);

  static TextStyle get bold16 => _tajawal(16.0, FontWeight.w700);

  static TextStyle get bold18 => _tajawal(18.0, FontWeight.w700);

  static TextStyle get bold20 => _tajawal(20.0, FontWeight.w700);

  static TextStyle get bold22 => _tajawal(22.0, FontWeight.w700);

  static TextStyle get bold24 => _tajawal(24.0, FontWeight.w700);

  static TextStyle get bold26 => _tajawal(26.0, FontWeight.w700);

  static TextStyle get bold40 => _tajawal(40.0, FontWeight.w700);

  static TextStyle get bold48 => _tajawal(48.0, FontWeight.w700);

  /// Aldhabi display text styles (for headings / hero text)
  static TextStyle get aldhabiRegular16 => _aldhabi(16.0, FontWeight.w400);
  static TextStyle get aldhabiRegular20 => _aldhabi(20.0, FontWeight.w400);
  static TextStyle get aldhabiRegular24 => _aldhabi(24.0, FontWeight.w400);
  static TextStyle get aldhabiRegular28 => _aldhabi(28.0, FontWeight.w400);
  static TextStyle get aldhabiRegular32 => _aldhabi(32.0, FontWeight.w400);
  static TextStyle get aldhaBold20 => _aldhabi(20.0, FontWeight.w700);
  static TextStyle get aldhaBold24 => _aldhabi(24.0, FontWeight.w700);
  static TextStyle get aldhaBold28 => _aldhabi(28.0, FontWeight.w700);
  static TextStyle get aldhaBold32 => _aldhabi(32.0, FontWeight.w700);
}
