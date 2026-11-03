import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/lab/presentation/cubit/lab_experiment_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_theme_script.dart';
import 'package:moean/features/lab/presentation/widgets/lab_webview_error_view.dart';
import 'package:url_launcher/url_launcher.dart';

class LabInAppWebViewWidget extends StatefulWidget {
  final String experimentKey;
  final LabExperimentCubit cubit;

  const LabInAppWebViewWidget({
    super.key,
    required this.experimentKey,
    required this.cubit,
  });

  @override
  State<LabInAppWebViewWidget> createState() => _LabInAppWebViewWidgetState();
}

class _LabInAppWebViewWidgetState extends State<LabInAppWebViewWidget> {
  InAppWebViewController? _controller;

  String get _embedUrl =>
      'https://haderedu.com/lab/${widget.experimentKey}?embed=1';

  void _applyTheme(InAppWebViewController? controller, bool isDark) {
    controller?.evaluateJavascript(source: buildLabThemeScript(isDark));
  }

  Future<void> _reload() async {
    widget.cubit.retryLoad();
    await _controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_embedUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ColorsManager.isDark;

    return BlocListener<ThemeCubit, ThemeState>(
      listener: (context, _) => _applyTheme(_controller, ColorsManager.isDark),
      child: Container(
        color: ColorsManager.background,
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_embedUrl)),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: buildLabThemeScript(isDark),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                supportZoom: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                useShouldOverrideUrlLoading: true,
                transparentBackground: true,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              onLoadStart: (controller, url) => widget.cubit.onWebViewStarted(),
              onLoadStop: (controller, url) {
                _applyTheme(controller, ColorsManager.isDark);
                widget.cubit.onWebViewReady();
              },
              onReceivedError: (controller, request, error) {
                if (request.isForMainFrame ?? false) {
                  widget.cubit.onWebViewError();
                }
              },
              onReceivedHttpError: (controller, request, response) {
                if ((request.isForMainFrame ?? false) &&
                    (response.statusCode ?? 0) >= 400) {
                  widget.cubit.onWebViewError();
                }
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final uri = action.request.url;
                if (uri == null) return NavigationActionPolicy.ALLOW;

                final host = uri.host.toLowerCase();
                final path = uri.path.toLowerCase();

                // Stay inside WebView if it's within haderedu.com/lab/
                if (host.contains('haderedu.com') && path.startsWith('/lab/')) {
                  return NavigationActionPolicy.ALLOW;
                }

                // Otherwise open externally in browser
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              },
            ),
            if (widget.cubit.state.webViewStatus == LabWebViewStatus.loading)
              Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.primaryColor,
                ),
              ),
            if (widget.cubit.state.webViewStatus == LabWebViewStatus.error)
              LabWebviewErrorView(onRetry: _reload),
          ],
        ),
      ),
    );
  }
}
