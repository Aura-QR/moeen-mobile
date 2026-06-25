import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moean/core/models/madrasati_session_data.dart';

/// Secure storage keys
const _kAuthToken = 'secure_auth_token';
const _kMadrasatiSession = 'secure_madrasati_session';

/// A secure wrapper around [FlutterSecureStorage] for sensitive app data.
/// Use this for tokens and Madrasati session instead of [CacheHelper].
class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper(this._storage);

  // ─── Auth Token ────────────────────────────────────────────────

  /// Saves the Bearer token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _kAuthToken, value: token);
  }

  /// Returns the saved Bearer token, or null if not found.
  Future<String?> getToken() async {
    return await _storage.read(key: _kAuthToken);
  }

  /// Deletes the saved token (used on logout / 401).
  Future<void> deleteToken() async {
    await _storage.delete(key: _kAuthToken);
  }

  // ─── Madrasati Session ─────────────────────────────────────────

  /// Saves Madrasati school session data securely.
  Future<void> saveMadrasatiSession(MadrasatiSessionData session) async {
    await _storage.write(key: _kMadrasatiSession, value: session.encode());
  }

  /// Returns the saved Madrasati session, or null if not found.
  Future<MadrasatiSessionData?> getMadrasatiSession() async {
    final raw = await _storage.read(key: _kMadrasatiSession);
    return MadrasatiSessionData.decode(raw);
  }

  /// Deletes the saved Madrasati session (used on disconnect).
  Future<void> deleteMadrasatiSession() async {
    await _storage.delete(key: _kMadrasatiSession);
  }

  // ─── Misc ──────────────────────────────────────────────────────

  /// Clears all secure data (logout).
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
