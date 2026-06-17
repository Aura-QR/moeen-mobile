import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';

class MicrosoftLoginScreen extends StatefulWidget {
  const MicrosoftLoginScreen({super.key});

  @override
  State<MicrosoftLoginScreen> createState() => _MicrosoftLoginScreenState();
}

class _MicrosoftLoginScreenState extends State<MicrosoftLoginScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;

  // You can replace these with your actual Microsoft App credentials later
  final String clientId = "YOUR_CLIENT_ID";
  final String tenant = "common"; // or your specific tenant ID
  final String redirectUri = "YOUR_REDIRECT_URI";
  
  late final String microsoftLoginUrl;

  @override
  void initState() {
    super.initState();
    microsoftLoginUrl = 
        "https://login.microsoftonline.com/$tenant/oauth2/v2.0/authorize"
        "?client_id=$clientId"
        "&response_type=token"
        "&redirect_uri=$redirectUri"
        "&scope=user.read";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        title: const Text('تسجيل الدخول باستخدام مايكروسوفت'),
        backgroundColor: ColorsManager.surfacePrimary,
        foregroundColor: ColorsManager.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (progress < 1.0)
              LinearProgressIndicator(
                value: progress,
                color: ColorsManager.primaryColor,
                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.2),
              ),
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri(microsoftLoginUrl),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  transparentBackground: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  // You can check here if the URL starts with your redirect URI
                  // to intercept the token and navigate back
                  if (url.toString().startsWith(redirectUri)) {
                     // Extract token and go back
                     // Navigator.pop(context, extractedToken);
                  }
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
                },
                onReceivedError: (controller, request, error) {
                  // Handle loading errors
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
