import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

part 'extension_install_state.dart';

/// Quetta Browser Android package identifier.
const String _quettaPackageName = 'net.quetta.browser';

/// Haddher Chrome Web Store URL.
const String _extensionUrl =
    'https://chromewebstore.google.com/detail/khpdbfpnnjimoeffjecnfpiokemdlabn';

/// Madrasati website URL.
const String _madrasatiUrl = 'https://schools.madrasati.sa/';

/// Play Store URL for Quetta Browser.
const String _quettaPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=$_quettaPackageName';

class ExtensionInstallCubit extends Cubit<ExtensionInstallState>
    with WidgetsBindingObserver {
  ExtensionInstallCubit() : super(const ExtensionInstallReady(isQuettaInstalled: false)) {
    WidgetsBinding.instance.addObserver(this);
    _checkQuettaStatus();
  }

  static ExtensionInstallCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle observer
  // ──────────────────────────────────────────────────────────────────────────

  /// Called by Flutter whenever the app lifecycle changes.
  /// On [AppLifecycleState.resumed] we check if Quetta was just installed
  /// so the UI can dynamically update the "Copy Link" to "Open in Quetta".
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkQuettaStatus();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Package check (reliable)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _checkQuettaStatus() async {
    if (Platform.isIOS) {
      emit(const ExtensionInstallIosNotSupported(isQuettaInstalled: false));
      return;
    }

    try {
      final AndroidIntent checkIntent = const AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: _quettaPackageName,
      );
      final bool isInstalled = await checkIntent.canResolveActivity() ?? false;
      emit(ExtensionInstallReady(isQuettaInstalled: isInstalled));
    } catch (_) {
      emit(const ExtensionInstallReady(isQuettaInstalled: false));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  /// Step 1: Open Play Store for Quetta Browser.
  Future<void> downloadQuetta() async {
    try {
      final AndroidIntent intent = const AndroidIntent(
        action: 'action_view',
        data: 'market://details?id=$_quettaPackageName',
        package: 'com.android.vending',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      final bool canResolve = await intent.canResolveActivity() ?? false;
      if (canResolve) {
        await intent.launch();
      } else {
        // Fallback to https web URL if Play Store app is missing
        final Uri webUri = Uri.parse(_quettaPlayStoreUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          emit(ExtensionInstallError(
            message: 'Could not open Play Store',
            isQuettaInstalled: state.isQuettaInstalled,
          ));
        }
      }
    } catch (_) {
      emit(ExtensionInstallError(
        message: 'Could not open Play Store',
        isQuettaInstalled: state.isQuettaInstalled,
      ));
    }
  }

  /// Step 2 (Option A): Copy extension link to clipboard.
  Future<void> copyExtensionLink() async {
    await Clipboard.setData(const ClipboardData(text: _extensionUrl));
  }

  /// Step 2 (Option B): Launch the extension URL inside Quetta explicitly.
  Future<void> openExtensionInQuetta() async {
    try {
      final AndroidIntent intent = const AndroidIntent(
        action: 'action_view',
        data: _extensionUrl,
        package: _quettaPackageName,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      emit(ExtensionInstallError(
        message: 'Could not launch Quetta',
        isQuettaInstalled: state.isQuettaInstalled,
      ));
    }
  }

  /// Step 3: Open Madrasati website inside Quetta browser.
  Future<void> openMadrasatiInQuetta() async {
    try {
      final AndroidIntent intent = const AndroidIntent(
        action: 'action_view',
        data: _madrasatiUrl,
        package: _quettaPackageName,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      emit(ExtensionInstallError(
        message: 'Could not launch Quetta',
        isQuettaInstalled: state.isQuettaInstalled,
      ));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
