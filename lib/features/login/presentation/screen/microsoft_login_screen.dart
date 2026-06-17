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

  final String madrasatiLoginUrl = "https://schools.madrasati.sa/";
  bool isConnecting = false;

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
                backgroundColor: ColorsManager.successColor ,
              ),
            );
            context.pushNamedAndRemoveUntil(Routes.home, (route) => false);
          } else if (state is MadrasatiErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorsManager.errorColor,
              ),
            );
            setState(() {
              isConnecting = false;
            });
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
                          backgroundColor:
                              ColorsManager.primaryColor.withValues(alpha: 0.2),
                        ),
                      Expanded(
                        child: InAppWebView(
                          key: webViewKey,
                          initialUrlRequest: URLRequest(
                            url: WebUri(madrasatiLoginUrl),
                          ),
                          initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            transparentBackground: true,
                          ),
                          onWebViewCreated: (controller) {
                            webViewController = controller;
                          },
                          onProgressChanged: (controller, progress) {
                            setState(() {
                              this.progress = progress / 100;
                            });
                          },
                          onLoadStop: (controller, url) async {
                            setState(() {
                              progress = 1.0;
                            });
                            
                            if (url != null && url.toString().contains('schools.madrasati.sa')) {
                              // We might be logged in, let's check cookies
                              final cookieManager = CookieManager.instance();
                              final cookies = await cookieManager.getCookies(url: url);
                              
                              if (cookies.isNotEmpty) {
                                bool hasAspNetCore = cookies.any((c) => c.name == '.AspNetCore.Cookies');
                                
                                // If we have the main session cookies, let's extract them
                                if (hasAspNetCore) {
                                  if (!isConnecting) {
                                    setState(() {
                                      isConnecting = true;
                                    });
                                    String sessionCookieStr = cookies.map((c) => "${c.name}=${c.value}").join('; ');
                                    
                                    String csrfToken = '';
                                    try {
                                      final csrfCookie = cookies.firstWhere((c) => c.name.contains('Antiforgery') || c.name.contains('RequestVerificationToken'));
                                      csrfToken = csrfCookie.value;
                                    } catch (_) {}

                                    if (csrfToken.isEmpty) {
                                      try {
                                        final jsResult = await controller.evaluateJavascript(source: "document.querySelector('input[name=__RequestVerificationToken]')?.value;");
                                        if (jsResult != null) {
                                          csrfToken = jsResult.toString();
                                        }
                                      } catch (_) {}
                                    }
                                    
                                    DateTime expiresAt = DateTime.now().add(const Duration(days: 30));
                                    String expiresStr = "${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')} ${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}:00";
                                    
                                    // ignore: use_build_context_synchronously
                                    context.read<MadrasatiCubit>().connectMadrasati(
                                      sessionCookie: sessionCookieStr,
                                      csrfToken: csrfToken,
                                      expiresAt: expiresStr,
                                    );
                                  }
                                }
                              }
                            }
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
