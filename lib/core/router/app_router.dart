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

  static String roleDocumentsPath(String roleKey) => '$roleSuites/$roleKey';

  static Future<T?> push<T extends Object?>(
    String routeName, {
    Object? arguments,
    BuildContext? context,
  }) {
    final nav = navigatorKey.currentState ?? (context == null ? null : Navigator.maybeOf(context));
    if (nav == null) return Future<T?>.value(null);
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  static void pop<T extends Object?>([T? result, BuildContext? context]) {
    final nav = navigatorKey.currentState ?? (context == null ? null : Navigator.maybeOf(context));
    nav?.pop<T>(result);
  }
}
