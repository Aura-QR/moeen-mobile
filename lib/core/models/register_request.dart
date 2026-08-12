class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phone;
  final String? referralCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phone,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
    };
    
    if (referralCode != null && referralCode!.isNotEmpty) {
      data['referral_code'] = referralCode;
    }
    
    return data;
  }
}
