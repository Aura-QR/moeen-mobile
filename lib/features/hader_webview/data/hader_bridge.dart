import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asset paths for the files copied out of the Hader browser extension.
class HaderAssets {
  static const String shim = 'assets/hader/hader_shim.js';
  static const String desktopViewport =
      'assets/hader/hader_desktop_viewport.js';
  static const String constants = 'assets/hader/constants.js';
  static const String content = 'assets/hader/content.js';
  static const String courses = 'assets/hader/madrasati_courses_clean.json';
  static const String templates = 'assets/hader/ee10_lesson_templates.json';
  static const String logo = 'assets/hader/logo-48.png';
}

/// SharedPreferences keys holding the mirrored `chrome.storage` areas.
const String _kHaderStorageLocal = 'hader_storage_local';
const String _kHaderStorageSync = 'hader_storage_sync';

/// Bridges the injected Hader scripts to the app.
///
/// The extension's `content.js` expects a background service worker for three
/// things: persisting `chrome.storage`, reading the bundled lesson database, and
/// making authenticated calls to the Hader API. Inside the WebView there is no
/// service worker, so [hader_shim.js] forwards those to the handlers registered
/// here.
///
/// API calls in particular *must* come through Dart: the page runs on the
/// madrasati.sa origin, so a direct request to api.haderedu.com would be blocked
/// by CORS — the same reason the extension proxies them through its worker.
class HaderBridge {
  HaderBridge({
    this.onAutomationStatus,
    this.onMadrasatiSession,
  });

  /// Called when the injected automation reports START / STOP / DONE / ERROR.
  final void Function(String status, dynamic detail)? onAutomationStatus;

  /// Called when the injected scripts capture a Madrasati session.
  final void Function(String cookie, String schoolId)? onMadrasatiSession;

  String? _coursesJson;
  String? _templatesJson;

  // ───────────────────────────────────────────────────────────────────────────
  // Seed — the state the shim needs *before* content.js runs
  // ───────────────────────────────────────────────────────────────────────────

  /// Builds the value assigned to `window.__HADER_SEED__`.
  ///
  /// `content.js` checks `HADAR_AUTH` on its very first pass and stops for good
  /// if it is missing, so the auth session is embedded in the injected source
  /// rather than fetched — by the time the page can ask, the answer is there.
  Future<Map<String, dynamic>> buildSeed() async {
    final prefs = await SharedPreferences.getInstance();

    final local = _decodeArea(prefs.getString(_kHaderStorageLocal));
    final sync = _decodeArea(prefs.getString(_kHaderStorageSync));

    final authToken = token ?? await sl<SecureStorageHelper>().getToken();
    if (authToken != null && authToken.isNotEmpty) {
      local['HADAR_AUTH'] = <String, dynamic>{
        'isAuthenticated': true,
        'token': authToken,
        'tokenType': 'Bearer',
      };
    } else {
      local.remove('HADAR_AUTH');
    }

    return <String, dynamic>{
      'runtimeId': 'hader-inapp-webview',
      'debug': kDebugMode,
      'storageLocal': local,
      'storageSync': sync,
      'assets': <String, String>{
        // content.js resolves its badge logo through chrome.runtime.getURL.
        // A data URI keeps it working without an extension origin to serve from.
        'logo/logo-48.png': await _assetAsDataUri(HaderAssets.logo, 'image/png'),
      },
    };
  }

  Map<String, dynamic> _decodeArea(String? raw) {
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // A corrupt mirror is not worth failing the session over — start clean.
    }
    return <String, dynamic>{};
  }

  Future<String> _assetAsDataUri(String path, String mimeType) async {
    final bytes = await rootBundle.load(path);
    final b64 = base64Encode(bytes.buffer.asUint8List());
    return 'data:$mimeType;base64,$b64';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Handler registration
  // ───────────────────────────────────────────────────────────────────────────

  /// Registers every handler the shim can call.
  ///
  /// Handlers are attached to all frames because the automation drives the
  /// lesson form inside a hidden same-origin iframe.
  void register(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'haderStorageSet',
      callback: (args) => _handleStorageSet(args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'haderLoadDatabase',
      callback: (args) => _handleLoadDatabase(),
    );

    controller.addJavaScriptHandler(
      handlerName: 'haderApi',
      callback: (args) => _handleApi(args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'haderMadrasatiSession',
      callback: (args) => _handleMadrasatiSession(args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'haderAutomationStatus',
      callback: (args) => _handleAutomationStatus(args),
    );
  }

  Map<String, dynamic> _firstArg(List<dynamic> args) {
    if (args.isEmpty) return <String, dynamic>{};
    final raw = args.first;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // Fall through to the empty map below.
      }
    }
    return <String, dynamic>{};
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Handlers
  // ───────────────────────────────────────────────────────────────────────────

  Future<bool> _handleStorageSet(List<dynamic> args) async {
    final payload = _firstArg(args);
    final area = payload['area'] as String? ?? 'local';
    final data = payload['data'];
    if (data is! Map) return false;

    // HADAR_AUTH is re-seeded from secure storage on every load, so it is not
    // written back to SharedPreferences alongside the rest of the mirror.
    final toPersist = Map<String, dynamic>.from(data)..remove('HADAR_AUTH');

    final prefs = await SharedPreferences.getInstance();
    final key = area == 'sync' ? _kHaderStorageSync : _kHaderStorageLocal;
    await prefs.setString(key, jsonEncode(toPersist));
    return true;
  }

  Future<Map<String, dynamic>> _handleLoadDatabase() async {
    _coursesJson ??= await rootBundle.loadString(HaderAssets.courses);
    try {
      _templatesJson ??= await rootBundle.loadString(HaderAssets.templates);
    } catch (error) {
      // Templates only sharpen the generated wording; lesson lookup works
      // without them, so a missing file must not take the whole flow down.
      debugPrint('[HaderBridge] templates unavailable: $error');
      _templatesJson = '';
    }

    return <String, dynamic>{
      'coursesJson': _coursesJson,
      'templatesJson': _templatesJson!.isEmpty ? null : _templatesJson,
    };
  }

  /// Proxies an authenticated Hader API call, shaped like the response the
  /// extension's service worker returns: `{ ok, status, data }`.
  Future<Map<String, dynamic>> _handleApi(List<dynamic> args) async {
    final payload = _firstArg(args);
    final method = (payload['method'] as String? ?? 'GET').toUpperCase();
    final path = payload['path'] as String? ?? '';

    if (path.isEmpty) {
      return <String, dynamic>{'ok': false, 'status': 0, 'error': 'Missing API path'};
    }

    final url = '$baseUrl$path';

    final result = method == 'POST'
        ? await DioHelper.postData(url: url, data: payload['body'])
        : await DioHelper.getData(url: url);

    return result.fold(
      (error) => <String, dynamic>{'ok': false, 'status': 0, 'error': error},
      (response) => <String, dynamic>{
        'ok': (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300,
        'status': response.statusCode ?? 0,
        'data': response.data,
      },
    );
  }

  Future<bool> _handleMadrasatiSession(List<dynamic> args) async {
    final payload = _firstArg(args);
    final cookie = payload['session_cookie'] as String? ?? '';
    final schoolId = payload['madrasati_school_id'] as String? ?? '';
    if (cookie.isEmpty) return false;

    try {
      await sl<SecureStorageHelper>().saveMadrasatiSession(
        MadrasatiSessionData(
          sessionCookie: cookie,
          schoolId: schoolId,
          expiresAt: DateTime.now().add(const Duration(hours: 8)),
        ),
      );
    } catch (error) {
      debugPrint('[HaderBridge] failed to persist Madrasati session: $error');
      return false;
    }

    onMadrasatiSession?.call(cookie, schoolId);
    return true;
  }

  Future<bool> _handleAutomationStatus(List<dynamic> args) async {
    final payload = _firstArg(args);
    onAutomationStatus?.call(
      payload['status'] as String? ?? 'STOP',
      payload['detail'],
    );
    return true;
  }

  /// Clears the mirrored `chrome.storage` areas (used on logout).
  static Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHaderStorageLocal);
    await prefs.remove(_kHaderStorageSync);
  }
}
