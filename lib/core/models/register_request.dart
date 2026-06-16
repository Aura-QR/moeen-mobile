class RegisterRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String nationalId;
  final String dateOfBirth;
  final String gender;

  RegisterRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.nationalId,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'national_id': nationalId,
    'date_of_birth': dateOfBirth,
    'gender': gender,
  };
}
