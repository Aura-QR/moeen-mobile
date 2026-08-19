class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.isActive = true,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == null,
      isEmailVerified: json['is_email_verified'] == true || json['is_email_verified'] == 1,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
    'is_active': isActive,
    'is_email_verified': isEmailVerified,
    'email_verified_at': emailVerifiedAt?.toIso8601String(),
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}
