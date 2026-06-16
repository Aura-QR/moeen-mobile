class RegisterResponse {
  final bool success;
  final String? message;
  final int? userId;

  RegisterResponse({required this.success, this.message, this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    int? uid;
    if (json['data'] != null && json['data'] is Map) {
      uid = json['data']['id'] ?? json['data']['user']?['id'];
    }
    uid ??= json['user_id'];

    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      userId: uid,
    );
  }
}
