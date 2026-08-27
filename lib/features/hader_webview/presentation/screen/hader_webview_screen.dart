import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/hader_webview/data/hader_bridge.dart';

/// Runs the Hader lesson-preparation automation inside the app.
///
/// This replaces the "install a third-party browser + sideload the extension"
/// flow, which cannot work on iOS at all — every iOS browser is WebKit and none
/// can load a Chrome extension. Here the app *is* the browser: it loads
/// Madrasati in a WebView and injects the extension's own `content.js`, so both
/// platforms run the exact same automation code.
///
/// The page is loaded in desktop mode on purpose. `content.js` finds lesson
/// cards with `td.day-cell div[data-data]` and detects the schedule page by
/// looking for `.calendar-table` — selectors written against Madrasati's
/// desktop table. A mobile viewport renders a different layout entirely and
/// those selectors would match nothing.
class HaderWebViewScreen extends StatefulWidget {
  const HaderWebViewScreen({super.key, this.initialUrl});

  /// Defaults to the teacher schedule, which is where the lesson cards live.
  final String? initialUrl;

  @override
  State<HaderWebViewScreen> createState() => _HaderWebViewScreenState();
}

class _HaderWebViewScreenState extends State<HaderWebViewScreen> {
  static const String _defaultUrl = 'https://schools.madrasati.sa/SchoolSchedule';

  /// Compile-time override (`--dart-define=HADER_URL=...`). Madrasati is
  /// geo-restricted to Saudi Arabia, so development outside it needs a
  /// stand-in schedule page to exercise the injected automation against.
  static const String _urlOverride = String.fromEnvironment('HADER_URL');

  static String get _startUrl =>
      _urlOverride.isNotEmpty ? _urlOverride : _defaultUrl;

  /// A desktop Chrome UA, so Madrasati serves the desktop schedule table that
  /// the injected selectors are written against.
  static const String _desktopUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  final GlobalKey _webViewKey = GlobalKey();

  InAppWebViewController? _controller;
  late final HaderBridge _bridge;

  UnmodifiableListView<UserScript>? _userScripts;
  String? _setupError;

  /// Host of the URL this screen was opened with, kept so navigation inside it
  /// is not blocked by the allowlist.
  late final String _initialHost =
      WebUri(widget.initialUrl ?? _startUrl).host.toLowerCase();
  double _progress = 0;
  String _statusMessage = 'جارٍ فتح مدرستي…';
  _StatusKind _statusKind = _StatusKind.info;

  @override
  void initState() {
    super.initState();
    _bridge = HaderBridge(
      onAutomationStatus: _onAutomationStatus,
    );
    _prepareUserScripts();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Script injection
  // ───────────────────────────────────────────────────────────────────────────

  /// Assembles the four scripts that stand in for the extension.
  ///
  /// Order matters: the seed defines the state the shim reads at construction,
  /// the shim installs `chrome.*`, and `content.js` uses both. All of them run
  /// in subframes too, because the automation drives the lesson form through a
  /// hidden same-origin iframe.
  Future<void> _prepareUserScripts() async {
    try {
      final seed = await _bridge.buildSeed();
      final viewportSource =
          await rootBundle.loadString(HaderAssets.desktopViewport);
      final shimSource = await rootBundle.loadString(HaderAssets.shim);
      final constantsSource = await rootBundle.loadString(HaderAssets.constants);
      final contentSource = await rootBundle.loadString(HaderAssets.content);
      final polishSource =
          await rootBundle.loadString(HaderAssets.mobilePolish);

      final scripts = <UserScript>[
        UserScript(
          groupName: 'hader-viewport',
          source: viewportSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-seed',
          source: 'window.__HADER_SEED__ = ${jsonEncode(seed)};',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-shim',
          source: shimSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-constants',
          source: constantsSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-content',
          source: contentSource,
          // The extension registers content.js at `document_idle`; document end
          // is the closest match, and content.js polls for late-rendered
          // schedule cards on its own regardless.
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-polish',
          source: polishSource,
          // Decorates what content.js renders, so it must come after it. Top
          // frame only: the hidden automation iframe has no UI to tidy.
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: true,
        ),
      ];

      if (!mounted) return;
      setState(() => _userScripts = UnmodifiableListView(scripts));
    } catch (error) {
      if (!mounted) return;
      setState(() => _setupError = error.toString());
    }
  }

  void _onAutomationStatus(String status, dynamic detail) {
    if (!mounted) return;
    switch (status) {
      case 'START':
        _setStatus('جارٍ تحضير الدرس…', _StatusKind.working);
        break;
      case 'DONE':
        _setStatus('تم تحضير الدرس بنجاح ✅', _StatusKind.success);
        break;
      case 'ERROR':
        _setStatus('تعذّر إكمال التحضير. حاول مرة أخرى.', _StatusKind.error);
        break;
      default:
        _setStatus('حضر جاهز', _StatusKind.info);
    }
  }

  void _setStatus(String message, _StatusKind kind) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _statusKind = kind;
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UI
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final navigator = Navigator.of(context);
          // Walk back through Madrasati's own history before leaving the screen,
          // so a teacher deep in the lesson form does not lose their place.
          if (await _controller?.canGoBack() ?? false) {
            await _controller?.goBack();
            return;
          }
          navigator.pop();
        },
        child: Scaffold(
          backgroundColor: ColorsManager.white,
          appBar: AppBar(
            backgroundColor: ColorsManager.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'تحضير الدروس',
              style: TextStylesManager.bold20
                  .copyWith(color: ColorsManager.themeActiveAccent),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: ColorsManager.themeDarkPrimary,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: ColorsManager.themeDarkPrimary,
                tooltip: 'إعادة تحميل',
                onPressed: () => _controller?.reload(),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_setupError != null) return _buildSetupError();
    if (_userScripts == null) return _buildLoading();

    return Column(
      children: [
        _buildStatusBar(),
        if (_progress < 1.0)
          LinearProgressIndicator(
            value: _progress,
            minHeight: 2,
            color: ColorsManager.themeActiveAccent,
            backgroundColor:
                ColorsManager.themeActiveAccent.withValues(alpha: 0.15),
          ),
        Expanded(child: _buildWebView()),
      ],
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(
        url: WebUri(widget.initialUrl ?? _startUrl),
      ),
      initialUserScripts: _userScripts,
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        // Desktop mode is what keeps content.js's selectors matching — see the
        // class doc above.
        preferredContentMode: UserPreferredContentMode.DESKTOP,
        userAgent: _desktopUserAgent,
        // A desktop table on a phone needs to be pinch-zoomable to be usable.
        useWideViewPort: true,
        loadWithOverviewMode: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        supportZoom: true,
        // The automation opens a hidden same-origin iframe and talks to it with
        // postMessage; it never needs a popup window.
        supportMultipleWindows: false,
        javaScriptCanOpenWindowsAutomatically: false,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: true,
        safeBrowsingEnabled: false,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        _bridge.register(controller);
      },
      onLoadStart: (controller, url) {
        _setStatus('جارٍ التحميل…', _StatusKind.info);
      },
      onLoadStop: (controller, url) async {
        if (!mounted) return;
        setState(() => _progress = 1.0);
        _setStatus('حضر جاهز — اختر الحصص من الجدول', _StatusKind.info);
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) return;
        setState(() => _progress = progress / 100);
      },
      shouldOverrideUrlLoading: (controller, action) async {
        final url = action.request.url;
        if (url == null) return NavigationActionPolicy.ALLOW;
        // Madrasati signs in through Microsoft, so both hosts must stay in this
        // WebView; anything else is an outbound link we do not follow.
        final host = url.host.toLowerCase();
        final isAllowed = host.endsWith('madrasati.sa') ||
            host.endsWith('microsoftonline.com') ||
            host.endsWith('microsoft.com') ||
            host.endsWith('live.com') ||
            host.endsWith('office.com') ||
            // Whatever the caller pointed this screen at is allowed too, so a
            // stand-in schedule page can be loaded when Madrasati is not
            // reachable (it is geo-restricted outside Saudi Arabia).
            host == _initialHost;
        return isAllowed
            ? NavigationActionPolicy.ALLOW
            : NavigationActionPolicy.CANCEL;
      },
      onReceivedError: (controller, request, error) {
        // Subframe failures are routine here — the automation drives a hidden
        // iframe — so only a main-frame failure is worth surfacing.
        if (!(request.isForMainFrame ?? false)) return;
        _setStatus('تعذّر الاتصال بمدرستي: ${error.description}', _StatusKind.error);
      },
      onReceivedHttpError: (controller, request, response) {
        if (!(request.isForMainFrame ?? false)) return;
        if ((response.statusCode ?? 0) >= 500) {
          _setStatus('مدرستي لا تستجيب حالياً (${response.statusCode})',
              _StatusKind.error);
        }
      },
      onConsoleMessage: (controller, message) {
        debugPrint('[HaderWebView] ${message.message}');
      },
    );
  }

  Widget _buildStatusBar() {
    final color = switch (_statusKind) {
      _StatusKind.success => ColorsManager.statusSuccess,
      _StatusKind.error => ColorsManager.errorColor,
      _StatusKind.working => ColorsManager.statusWaiting,
      _StatusKind.info => ColorsManager.themeActiveAccent,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: [
          if (_statusKind == _StatusKind.working)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(
              switch (_statusKind) {
                _StatusKind.success => Icons.check_circle_rounded,
                _StatusKind.error => Icons.error_rounded,
                _ => Icons.info_rounded,
              },
              size: 16,
              color: color,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStylesManager.bold14.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: ColorsManager.themeActiveAccent),
          const SizedBox(height: 16),
          Text(
            'جارٍ تجهيز حضر…',
            style: TextStylesManager.bold14
                .copyWith(color: ColorsManager.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: ColorsManager.errorColor),
            const SizedBox(height: 16),
            Text(
              'تعذّر تجهيز حضر',
              style: TextStylesManager.bold20
                  .copyWith(color: ColorsManager.themeDarkPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _setupError ?? '',
              textAlign: TextAlign.center,
              style: TextStylesManager.bold14
                  .copyWith(color: ColorsManager.textBody),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => _setupError = null);
                _prepareUserScripts();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StatusKind { info, working, success, error }
