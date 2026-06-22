import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/login/presentation/cubit/madrasati_cubit.dart';

class MicrosoftLoginScreen extends StatefulWidget {
  const MicrosoftLoginScreen({super.key});

  @override
  State<MicrosoftLoginScreen> createState() => _MicrosoftLoginScreenState();
}

class _MicrosoftLoginScreenState extends State<MicrosoftLoginScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;

  final String _madrasatiLoginUrl = 'https://schools.madrasati.sa/';
  bool _isConnecting = false;

  /// Attempts to extract the Madrasati school ID from the current URL.
  ///
  /// Madrasati URLs have the school ID embedded either in the path
  /// (`/School/abc123`) or as a query parameter (`?schoolId=abc123`).
  String _extractSchoolId(WebUri url) {
    final uri = Uri.tryParse(url.toString());
    if (uri == null) return '';

    // 1. Try query parameter: ?schoolId=... or ?school_id=...
    final fromQuery = uri.queryParameters['schoolId'] ??
        uri.queryParameters['school_id'] ??
        uri.queryParameters['SchoolId'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;

    // 2. Try to find a 32-char hex segment in the path segments
    // (Madrasati real_school_id is a 32-char alphanumeric string)
    for (final segment in uri.pathSegments) {
      if (segment.length == 32 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(segment)) {
        return segment;
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MadrasatiCubit(),
      child: BlocConsumer<MadrasatiCubit, MadrasatiState>(
        listener: (context, state) {
          if (state is MadrasatiSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsManager.successColor,
              ),
            );
            context.pushNamedAndRemoveUntil(
                Routes.schedule, (route) => false);
          } else if (state is MadrasatiErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsManager.errorColor,
              ),
            );
            setState(() => _isConnecting = false);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              title: const Text('تسجيل الدخول في منصة مدرستي'),
              backgroundColor: ColorsManager.surfacePrimary,
              foregroundColor: ColorsManager.textPrimary,
              elevation: 0,
              centerTitle: true,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: <Widget>[
                      if (progress < 1.0)
                        LinearProgressIndicator(
                          value: progress,
                          color: ColorsManager.primaryColor,
                          backgroundColor: ColorsManager.primaryColor
                              .withValues(alpha: 0.2),
                        ),
                      Expanded(
                        child: InAppWebView(
                          key: webViewKey,
                          initialUrlRequest: URLRequest(
                            url: WebUri(_madrasatiLoginUrl),
                          ),
                          initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            transparentBackground: true,
                            domStorageEnabled: true,
                            databaseEnabled: true,
                            clearCache: true,
                            clearSessionCache: true,
                            safeBrowsingEnabled: false,
                          ),
                          onWebViewCreated: (controller) {
                            webViewController = controller;
                          },
                          onProgressChanged: (controller, p) {
                            setState(() => progress = p / 100);
                          },
                          onLoadStop: (controller, url) async {
                            setState(() => progress = 1.0);

                            if (url == null) return;
                            if (!url
                                .toString()
                                .contains('schools.madrasati.sa')) {
                              return;
                            }

                            // Check for the main session cookie
                            final cookieManager = CookieManager.instance();
                            final cookies =
                                await cookieManager.getCookies(url: url);

                            if (cookies.isEmpty) return;

                            final hasSession = cookies
                                .any((c) => c.name == '.AspNetCore.Cookies');
                            if (!hasSession || _isConnecting) return;

                            setState(() => _isConnecting = true);

                            // Build the full cookie string
                            final sessionCookieStr =
                                cookies.map((c) => '${c.name}=${c.value}').join('; ');

                            // Extract school ID from URL
                            final schoolId = _extractSchoolId(url);

                            // Calculate expiry (30 days from now)
                            final expiresAt =
                                DateTime.now().add(const Duration(days: 30));
                            final expiresStr =
                                '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')} '
                                '${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}:00';

                            // ignore: use_build_context_synchronously
                            MadrasatiCubit.get(context).connectMadrasati(
                              sessionCookie: sessionCookieStr,
                              madrasatiSchoolId: schoolId,
                              expiresAt: expiresStr,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (state is MadrasatiLoadingState)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
