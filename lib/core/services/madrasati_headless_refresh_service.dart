import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/core/services/madrasati_session_service.dart';

/// Uses a [HeadlessInAppWebView] to silently refresh the Madrasati session
/// without showing any UI to the user.
///
/// Workflow:
/// 1. Open `https://schools.madrasati.sa/` headlessly.
/// 2. Wait for page load (user already logged-in via stored cookies).
/// 3. Extract cookies from the webview.
/// 4. POST to `/madrasati/connect` with the new cookies.
/// 5. Save updated session + notify [MadrasatiSessionService].
/// 6. Destroy the headless webview.
///
/// Returns `true` on success, `false` on failure.
class MadrasatiHeadlessRefreshService {
  final SecureStorageHelper _secureStorage;
  final MadrasatiSessionService _sessionService;

  MadrasatiHeadlessRefreshService(
    this._secureStorage,
    this._sessionService,
  );

  HeadlessInAppWebView? _headlessWebView;
  Completer<bool>? _completer;
  bool _isRunning = false;
  bool _msLoginTimeoutStarted = false;

  static const String _madrasatiUrl = 'https://schools.madrasati.sa/';

  /// Starts the headless refresh flow.
  /// Returns true if cookies were extracted and session updated successfully.
  Future<bool> refresh() async {
    if (_isRunning) {
      debugPrint('⏳ HeadlessRefresh: already running, skipping');
      return false;
    }

    _isRunning = true;
    _msLoginTimeoutStarted = false;
    _completer = Completer<bool>();

    try {
      _headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(_madrasatiUrl),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          userAgent:
              'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
        ),
        onLoadStart: (controller, url) async {
          final urlStr = url?.toString().toLowerCase() ?? '';
          if (urlStr.contains('login.microsoftonline.com') && !_msLoginTimeoutStarted) {
            _msLoginTimeoutStarted = true;
            Future.delayed(const Duration(seconds: 6), () {
              if (_isRunning && !(_completer?.isCompleted ?? true)) {
                debugPrint('⏱️ HeadlessRefresh: Microsoft login stuck (likely requires password), failing fast.');
                _finish(false);
              }
            });
          }
        },
        onLoadStop: (controller, url) async {
          await _onPageLoaded(controller, url);
        },
        onProgressChanged: (controller, progress) async {
          if (progress >= 50) {
            final url = await controller.getUrl();
            final urlStr = url?.toString().toLowerCase() ?? '';

            if (urlStr.contains('login.microsoftonline.com') && !_msLoginTimeoutStarted) {
              _msLoginTimeoutStarted = true;
              Future.delayed(const Duration(seconds: 6), () {
                if (_isRunning && !(_completer?.isCompleted ?? true)) {
                  debugPrint('⏱️ HeadlessRefresh: Microsoft login stuck (likely requires password), failing fast.');
                  _finish(false);
                }
              });
            }

            final isLandingPage = urlStr == 'https://schools.madrasati.sa/' || urlStr == 'https://schools.madrasati.sa';
            
            if (isLandingPage) {
              await controller.evaluateJavascript(source: '''
                var links = document.querySelectorAll('a');
                for (var i = 0; i < links.length; i++) {
                  var text = links[i].innerText || '';
                  var href = links[i].href || '';
                  if (text.includes('مايكروسوفت') || text.includes('كادر') || href.toLowerCase().includes('ssologin')) {
                    links[i].click();
                    break;
                  }
                }
              ''');
            } else if (urlStr.contains('login.microsoftonline.com')) {
              await controller.evaluateJavascript(source: '''
                var accountTile = document.querySelector('.table') || document.querySelector('.tile-container') || document.querySelector('.list-group-item');
                if (accountTile) {
                   accountTile.click();
                }
              ''');
            }
          }
        },
        onReceivedError: (controller, request, error) {
          if (request.isForMainFrame ?? false) {
            debugPrint('❌ HeadlessRefresh: WebView error: ${error.description}');
            _finish(false);
          }
        },
      );

      await _headlessWebView!.run();
      debugPrint('🌐 HeadlessRefresh: WebView started');

      // Timeout after 20 seconds to allow slow pages to load
      return await _completer!.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('⏱️ HeadlessRefresh: timed out (likely stuck on Microsoft login or slow loading)');
          _finish(false);
          return false;
        },
      );
    } catch (e) {
      debugPrint('❌ HeadlessRefresh: exception: $e');
      _finish(false);
      return false;
    }
  }

  Future<void> _onPageLoaded(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    final urlStr = url?.toString().toLowerCase() ?? '';
    debugPrint('🌐 HeadlessRefresh: page loaded → $urlStr');

    final isLandingPage = urlStr == 'https://schools.madrasati.sa/' || urlStr == 'https://schools.madrasati.sa';

    if (isLandingPage) {
      debugPrint('🌐 HeadlessRefresh: on landing page, attempting to click login button...');
      await controller.evaluateJavascript(source: '''
        setTimeout(function() {
          var links = document.querySelectorAll('a');
          for (var i = 0; i < links.length; i++) {
            var text = links[i].innerText || '';
            var href = links[i].href || '';
            if (text.includes('مايكروسوفت') || text.includes('كادر') || href.toLowerCase().includes('ssologin')) {
              links[i].click();
              return;
            }
          }
        }, 1000);
      ''');
      return;
    }

    final uri = Uri.tryParse(urlStr);
    final host = uri?.host ?? '';
    final isMadrasatiHost = host == 'schools.madrasati.sa' || host.endsWith('.madrasati.sa');

    if (host == 'login.microsoftonline.com') {
      debugPrint('🌐 HeadlessRefresh: on Microsoft Login. Attempting to auto-select account if picker is present...');
      await controller.evaluateJavascript(source: '''
        setTimeout(function() {
          var accountTile = document.querySelector('.table') || document.querySelector('.tile-container') || document.querySelector('.list-group-item');
          if (accountTile) {
             accountTile.click();
          }
        }, 1000);
      ''');
    }

    // Only proceed once we're inside authenticated Madrasati pages (not landing page)
    final isInsideMadrasati = (isMadrasatiHost && !isLandingPage) ||
        urlStr.contains('teacher') ||
        urlStr.contains('schoolschedule') ||
        urlStr.contains('schoolmanagment');

    if (!isInsideMadrasati) {
      debugPrint('⏳ HeadlessRefresh: not yet inside Madrasati, waiting...');
      return;
    }

    try {
      final cookieManager = CookieManager.instance();

      // Extract cookies from Madrasati domain
      final madrasatiCookies = await cookieManager.getCookies(
        url: WebUri('https://schools.madrasati.sa/'),
      );
      final msCookies = await cookieManager.getCookies(
        url: WebUri('https://login.microsoftonline.com/'),
      );

      final allCookies = [...madrasatiCookies, ...msCookies];
      final sessionCookieStr =
          allCookies.map((c) => '${c.name}=${c.value}').join('; ');

      debugPrint(
          '🍪 HeadlessRefresh: extracted ${allCookies.length} cookies');

      // Check we have the critical cookie
      final hasAuthCookie = allCookies.any(
        (c) => c.name.contains('.AspNetCore.Cookies'),
      );

      if (!hasAuthCookie || sessionCookieStr.isEmpty) {
        debugPrint('❌ HeadlessRefresh: missing .AspNetCore.Cookies. Waiting for potential redirect...');
        return;
      }

      // Load saved school ID from secure storage
      final savedSession = await _secureStorage.getMadrasatiSession();
      final schoolId = savedSession?.schoolId ?? '';

      final expiresAt = DateTime.now().add(const Duration(days: 30));
      final expiresStr =
          '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')} '
          '${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}:00';

      // POST to /madrasati/connect
      final result = await DioHelper.postData(
        url: connectMadrasatiApi,
        data: {
          'session_cookie': sessionCookieStr,
          'madrasati_school_id': schoolId,
          'expires_at': expiresStr,
        },
      );

      result.fold(
        (error) {
          debugPrint('❌ HeadlessRefresh: connect API error: $error');
          _finish(false);
        },
        (res) async {
          final success = res.data['success'] ?? false;
          if (success) {
            // Save refreshed session
            await _secureStorage.saveMadrasatiSession(
              MadrasatiSessionData(
                sessionCookie: sessionCookieStr,
                schoolId: schoolId,
                expiresAt: expiresAt,
              ),
            );
            _sessionService.notifySessionActive();
            debugPrint('✅ HeadlessRefresh: session refreshed successfully');
            _finish(true);
          } else {
            debugPrint(
                '❌ HeadlessRefresh: connect API returned success=false');
            _finish(false);
          }
        },
      );
    } catch (e) {
      debugPrint('❌ HeadlessRefresh: exception in _onPageLoaded: $e');
      _finish(false);
    }
  }

  void _finish(bool success) {
    _isRunning = false;
    _headlessWebView?.dispose();
    _headlessWebView = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(success);
    }
  }
}
