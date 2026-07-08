class AdminTeacherUserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool active;
  final String? createdAt;

  const AdminTeacherUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.active,
    this.createdAt,
  });

  factory AdminTeacherUserModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'teacher',
      active: json['active'] == true || json['active'] == 1,
      createdAt: json['created_at'] as String?,
    );
  }
}

class AdminTeacherSubscriptionModel {
  final int id;
  final String name;
  final String slug;

  const AdminTeacherSubscriptionModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AdminTeacherSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherSubscriptionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class AdminTeacherModel {
  final int id;
  final bool active;
  final String? subscriptionEndsAt;
  final AdminTeacherUserModel user;
  final AdminTeacherSubscriptionModel? subscription;

  const AdminTeacherModel({
    required this.id,
    required this.active,
    this.subscriptionEndsAt,
    required this.user,
    this.subscription,
  });

  factory AdminTeacherModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherModel(
      id: json['id'] as int,
      active: json['active'] == true || json['active'] == 1,
      subscriptionEndsAt: json['subscription_ends_at'] as String?,
      user: AdminTeacherUserModel.fromJson(json['user']),
      subscription: json['subscription'] != null
          ? AdminTeacherSubscriptionModel.fromJson(json['subscription'])
          : null,
    );
  }
}

class AdminTeacherPaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<AdminTeacherModel> data;

  const AdminTeacherPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.data,
  });

  factory AdminTeacherPaginationModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherPaginationModel(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AdminTeacherModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
