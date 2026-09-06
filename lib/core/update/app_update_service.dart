import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the server decided about the running build.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    required this.storeUrl,
    required this.title,
    required this.message,
  });

  final bool updateAvailable;

  /// The teacher cannot dismiss the prompt. Reserved for a release the app
  /// genuinely cannot work without, since it locks them out until they update.
  final bool forceUpdate;

  final String latestVersion;
  final String storeUrl;
  final String title;
  final String message;
}

/// Asks the backend whether a newer build is out.
///
/// The comparison itself lives on the server. That is deliberate: a
/// version-comparison bug shipped inside a release can never be fixed for the
/// teachers still running it, while the same bug server-side is one deploy away
/// from being fixed for everyone at once. This only reports and remembers.
class AppUpdateService {
  static const String _skippedVersionKey = 'hader_update_skipped_version';

  /// Short on purpose. The check runs at launch and must never be what the
  /// teacher waits on — a slow or unreachable server just means no prompt.
  static const Duration _timeout = Duration(seconds: 6);

  static Future<AppUpdateInfo?> check() async {
    try {
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : null;
      if (platform == null) return null;

      final info = await PackageInfo.fromPlatform();
      // Sent as "1.0.2+8" so the server sees exactly what pubspec declares and
      // decides for itself which part matters.
      final current = '${info.version}+${info.buildNumber}';

      final response = await Dio(BaseOptions(
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
      )).get(
        'https://api.haderedu.com/api/app/version',
        queryParameters: {'platform': platform, 'version': current},
      );

      final data = response.data;
      if (data is! Map) return null;
      if (data['update_available'] != true) return null;

      return AppUpdateInfo(
        updateAvailable: true,
        forceUpdate: data['force_update'] == true,
        latestVersion: (data['latest_version'] ?? '').toString(),
        storeUrl: (data['store_url'] ?? '').toString(),
        title: (data['title'] ?? 'تحديث جديد').toString(),
        message: (data['message'] ?? '').toString(),
      );
    } catch (error) {
      // Never surface this. A teacher who cannot reach our server has a real
      // problem already, and an update prompt is not the way to tell them.
      debugPrint('[AppUpdate] check failed: $error');
      return null;
    }
  }

  /// Whether this optional update was already dismissed.
  ///
  /// Remembered per version, so a teacher who taps "later" is left alone until
  /// the *next* release rather than being asked again every launch — which is
  /// how an update prompt turns into something people learn to tap through.
  static Future<bool> wasSkipped(String version) async {
    if (version.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_skippedVersionKey) == version;
    } catch (_) {
      return false;
    }
  }

  static Future<void> skip(String version) async {
    if (version.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_skippedVersionKey, version);
    } catch (error) {
      debugPrint('[AppUpdate] skip failed: $error');
    }
  }
}
