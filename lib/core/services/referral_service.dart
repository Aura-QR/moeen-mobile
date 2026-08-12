import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter/foundation.dart';
import 'package:moean/core/network/local/cache_helper.dart';

class ReferralService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  static Future<void> init() async {
    // 1. Check Google Play Install Referrer
    await _checkInstallReferrer();

    // 2. Handle Initial Deep Link (App opened via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial app link: $e');
    }

    // 3. Listen for incoming Deep Links while app is open
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('AppLinks Stream Error: $err');
      },
    );
  }

  static Future<void> _checkInstallReferrer() async {
    try {
      // Check if we already have a referral code
      final existingCode = CacheHelper.getData(key: 'referral_code');
      if (existingCode != null && existingCode.toString().isNotEmpty) return;
      
      // Also check if user is already authenticated (token exists)
      final existingToken = CacheHelper.getData(key: 'auth_token');
      if (existingToken != null && existingToken.toString().isNotEmpty) return;

      final ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
      final referrerUrl = referrerDetails.installReferrer;
      
      if (referrerUrl != null && referrerUrl.isNotEmpty) {
        debugPrint('Install Referrer URL: $referrerUrl');
        
        // Parse the referrer string (e.g., utm_source=referral&utm_content=HAMDY7K2)
        final uri = Uri.parse('http://localhost?$referrerUrl');
        final utmContent = uri.queryParameters['utm_content'];
        
        if (utmContent != null && utmContent.isNotEmpty) {
          _storeReferralCode(utmContent);
        }
      }
    } catch (e) {
      debugPrint('Failed to get install referrer: $e');
    }
  }

  static void _handleDeepLink(Uri uri) {
    try {
      // Check if user is already authenticated (token exists)
      final existingToken = CacheHelper.getData(key: 'auth_token');
      if (existingToken != null && existingToken.toString().isNotEmpty) {
        debugPrint('User is already authenticated. Ignoring referral deep link.');
        return;
      }

      // Check if we already have a referral code
      final existingCode = CacheHelper.getData(key: 'referral_code');
      if (existingCode != null && existingCode.toString().isNotEmpty) {
        debugPrint('Referral code already exists locally. Preserving existing code: $existingCode');
        return;
      }

      // Handle https://haderedu.com/r/HAMDY7K2
      if (uri.host == 'haderedu.com' && uri.pathSegments.isNotEmpty) {
        if (uri.pathSegments[0] == 'r' && uri.pathSegments.length > 1) {
          final referralCode = uri.pathSegments[1];
          if (referralCode.isNotEmpty) {
            _storeReferralCode(referralCode);
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  static void _storeReferralCode(String code) {
    // Only store if we don't have one
    final existingCode = CacheHelper.getData(key: 'referral_code');
    if (existingCode == null || existingCode.toString().isEmpty) {
      CacheHelper.saveData(key: 'referral_code', value: code);
      debugPrint('Referral code stored locally: $code');
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}
