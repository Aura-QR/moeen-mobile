import 'dart:convert';

class MadrasatiSessionData {
  final String sessionCookie;
  final String schoolId;
  final DateTime? expiresAt;

  const MadrasatiSessionData({
    required this.sessionCookie,
    required this.schoolId,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'session_cookie': sessionCookie,
        'school_id': schoolId,
        'expires_at': expiresAt?.toIso8601String(),
      };

  factory MadrasatiSessionData.fromJson(Map<String, dynamic> json) {
    return MadrasatiSessionData(
      sessionCookie: json['session_cookie'] as String? ?? '',
      schoolId: json['school_id'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
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
}
