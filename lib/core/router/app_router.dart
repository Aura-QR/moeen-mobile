import 'package:flutter/material.dart';
import 'package:moean/main.dart';

/// Centralized route constants and navigator helpers backed by [navigatorKey].
abstract final class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String myDocuments = '/documents';
  static const String documentDefaults = '/documents/defaults';
  static const String classes = '/classes';
  static const String thankYouCertificates = '/tools/certificates';
  static const String classSheets = '/tools/sheets';
  static const String reportTools = '/tools/reports';
  static const String reportEditor = '/tools/reports/editor';
  static const String roleSuites = '/tools/roles';
  static const String roleDocuments = '/tools/roles/documents';
  static const String conceptMaps = '/concept-maps';
  static const String conceptMapsNew = '/concept-maps/new';
  static const String conceptMapsEditor = '/concept-maps/editor';
  static const String outcomesMap = '/outcomes-map';
  static const String outcomesMapNew = '/outcomes-map/new';
  static const String outcomesMapEditor = '/outcomes-map/editor';
  static const String readingComprehension = '/reading-comprehension';
  static const String readingComprehensionNew = '/reading-comprehension/new';
  static const String readingComprehensionEditor = '/reading-comprehension/editor';
  static const String learningStyles = '/learning-styles';
  static const String learningStyleNew = '/learning-styles/new';
  static const String learningStyle = '/learning-styles/survey';
  static const String nationalExams = '/exams/national';
  static const String nafsTest = '/exams/nafs';
  static const String tahsiliTest = '/exams/tahsili';

  static String roleDocumentsPath(String roleKey) => '$roleSuites/$roleKey';

  static Future<T?> push<T extends Object?>(
    String routeName, {
    Object? arguments,
    BuildContext? context,
  }) async {
    final nav =
        navigatorKey.currentState ??
        (context == null ? null : Navigator.maybeOf(context));
    if (nav == null) return null;
    final result = await nav.pushNamed(routeName, arguments: arguments);
    return result is T ? result : null;
  }

  static void pop<T extends Object?>([T? result, BuildContext? context]) {
    final nav =
        navigatorKey.currentState ??
        (context == null ? null : Navigator.maybeOf(context));
    nav?.pop<T>(result);
  }
}
