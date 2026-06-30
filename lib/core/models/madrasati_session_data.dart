import 'dart:convert';

class MadrasatiSessionData {
  final String sessionCookie;
  final String schoolId;
  final DateTime? expiresAt;

  /// The Microsoft OAuth refresh_token used for silent session renewal.
  /// Stored securely so the interceptor can use it without user interaction.
  final String? refreshToken;

  const MadrasatiSessionData({
    required this.sessionCookie,
    required this.schoolId,
    this.expiresAt,
    this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
        'session_cookie': sessionCookie,
        'school_id': schoolId,
        'expires_at': expiresAt?.toIso8601String(),
        'refresh_token': refreshToken,
      };

  factory MadrasatiSessionData.fromJson(Map<String, dynamic> json) {
    return MadrasatiSessionData(
      sessionCookie: json['session_cookie'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  /// Encode to JSON string for secure storage
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string
  static MadrasatiSessionData? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return MadrasatiSessionData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.isNotEmpty;
}
