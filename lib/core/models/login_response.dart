class LoginResponse {
  final bool success;
  final String? message;
  final String? token;

  LoginResponse({
    required this.success,
    this.message,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      token:
          json['token'] as String?, // assuming the response might have a token
    );
  }
}
