import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the teacher signed in to Madrasati between app launches.
///
/// Madrasati and the Microsoft sign-in it delegates to both issue *session*
/// cookies — no `Expires`, so the cookie store drops them when the WebView goes
/// away. In a browser that is fine, because the browser outlives any one page.
/// Here the WebView is the browser, and it dies with the screen, so every visit
/// started signed out and sent the teacher back through a Microsoft login that
/// Madrasati itself starts refusing after a few rounds.
///
/// So the cookies are copied out while the teacher is signed in and written
/// back on the next launch with a real expiry, which turns a session cookie
/// into a persistent one. That is exactly what "remember me" does; Madrasati
/// simply never offers it.
class MadrasatiSessionStore {
  static const String _key = 'hader_madrasati_cookies_v1';

  /// How long a restored cookie is given. Madrasati invalidates its own
  /// sessions server-side well before this, and a stale cookie costs one
  /// redirect to the sign-in page — the same place an absent cookie lands. So
  /// the risk of being generous is nil and the benefit is not re-authenticating
  /// every single morning.
  static const Duration _lifetime = Duration(days: 30);

  /// Every origin the sign-in chain touches. Madrasati's own cookie is the one
  /// that matters, but restoring it alone would still bounce through Microsoft
  /// when Madrasati decides to re-validate, so the identity cookies come too.
  static const List<String> _origins = [
    'https://schools.madrasati.sa',
    'https://external.madrasati.sa',
    'https://sts.madrasati.sa',
    'https://login.microsoftonline.com',
    'https://login.live.com',
  ];

  /// Copies the current cookies into storage.
  ///
  /// Call this while the teacher is known to be signed in — a snapshot taken
  /// from a signed-out page would persist the *absence* of a session and
  /// overwrite a good one.
  static Future<void> save() async {
    try {
      final manager = CookieManager.instance();
      final saved = <Map<String, dynamic>>[];

      for (final origin in _origins) {
        final cookies = await manager.getCookies(url: WebUri(origin));
        for (final cookie in cookies) {
          final value = cookie.value?.toString() ?? '';
          if (cookie.name.isEmpty || value.isEmpty) continue;

          saved.add({
            'origin': origin,
            'name': cookie.name,
            'value': value,
            'domain': cookie.domain,
            'path': cookie.path ?? '/',
            'secure': cookie.isSecure ?? true,
            'httpOnly': cookie.isHttpOnly ?? false,
          });
        }
      }

      if (saved.isEmpty) return; // nothing to remember; keep what we have

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(saved));
      debugPrint('[MadrasatiSession] saved ${saved.length} cookies');
    } catch (error) {
      // Persistence is a convenience. Losing it costs a login, not the feature.
      debugPrint('[MadrasatiSession] save failed: $error');
    }
  }

  /// Writes the stored cookies back, with an expiry so they survive the next
  /// launch too.
  ///
  /// Must run *before* the WebView's first request, or the first navigation
  /// goes out unauthenticated and Madrasati redirects to sign-in regardless of
  /// what is restored afterwards.
  static Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final expiry = DateTime.now().add(_lifetime).millisecondsSinceEpoch;
      final manager = CookieManager.instance();
      var restored = 0;

      for (final entry in decoded) {
        if (entry is! Map) continue;
        final origin = entry['origin'] as String?;
        final name = entry['name'] as String?;
        final value = entry['value'] as String?;
        if (origin == null || name == null || value == null) continue;

        await manager.setCookie(
          url: WebUri(origin),
          name: name,
          value: value,
          // A stored cookie without a domain belongs to its origin's host, and
          // passing an empty one would scope it wrongly.
          domain: (entry['domain'] as String?)?.isNotEmpty == true
              ? entry['domain'] as String
              : null,
          path: (entry['path'] as String?) ?? '/',
          // The expiry is the whole point: without it the cookie goes back in
          // as a session cookie and dies again with this WebView.
          expiresDate: expiry,
          isSecure: (entry['secure'] as bool?) ?? true,
          isHttpOnly: (entry['httpOnly'] as bool?) ?? false,
        );
        restored++;
      }

      debugPrint('[MadrasatiSession] restored $restored cookies');
    } catch (error) {
      debugPrint('[MadrasatiSession] restore failed: $error');
    }
  }

  /// Drops the stored session. For an explicit sign-out — nothing else should
  /// clear it, since a redirect to the login page is often transient.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (error) {
      debugPrint('[MadrasatiSession] clear failed: $error');
    }
  }
}
