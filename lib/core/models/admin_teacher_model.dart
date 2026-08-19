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
  final bool isInTrial;
  final bool isSubscribed;
  final String? subscriptionEndsAt;
  final String? trialEndsAt;
  final int trialDaysRemaining;
  final AdminTeacherUserModel user;
  final AdminTeacherSubscriptionModel? subscription;

  const AdminTeacherModel({
    required this.id,
    required this.active,
    this.isInTrial = false,
    this.isSubscribed = false,
    this.subscriptionEndsAt,
    this.trialEndsAt,
    this.trialDaysRemaining = 0,
    required this.user,
    this.subscription,
  });

  factory AdminTeacherModel.fromJson(Map<String, dynamic> json) {
    return AdminTeacherModel(
      id: json['id'] as int? ?? 0,
      active: json['active'] == true || json['active'] == 1 || json['is_active'] == true || json['is_active'] == 1,
      isInTrial: json['is_in_trial'] as bool? ?? false,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      subscriptionEndsAt: json['subscription_ends_at'] as String?,
      trialEndsAt: json['trial_ends_at'] as String?,
      trialDaysRemaining: json['trial_days_remaining'] as int? ?? 0,
      user: json['user'] != null
          ? AdminTeacherUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : const AdminTeacherUserModel(id: 0, name: '', email: '', role: 'teacher', active: true),
      subscription: json['subscription'] != null
          ? AdminTeacherSubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  DateTime? get parsedSubscriptionEndsAt =>
      subscriptionEndsAt != null ? DateTime.tryParse(subscriptionEndsAt!) : null;

  DateTime? get parsedTrialEndsAt =>
      trialEndsAt != null ? DateTime.tryParse(trialEndsAt!) : null;

  DateTime? get effectiveEndsAt {
    if (isSubscribed) return parsedSubscriptionEndsAt;
    if (isInTrial) return parsedTrialEndsAt;
    return parsedSubscriptionEndsAt ?? parsedTrialEndsAt;
  }

  int get dynamicDaysRemaining {
    final endsAt = effectiveEndsAt;
    if (endsAt == null) return trialDaysRemaining > 0 ? trialDaysRemaining : 0;
    final now = DateTime.now();
    if (endsAt.isBefore(now)) return 0;
    return (endsAt.difference(now).inHours / 24).ceil();
  }

  bool get isExpired {
    if (isSubscribed) {
      final ends = parsedSubscriptionEndsAt;
      return ends != null && ends.isBefore(DateTime.now());
    }
    if (isInTrial) {
      final ends = parsedTrialEndsAt;
      if (ends != null && ends.isBefore(DateTime.now())) return true;
      return dynamicDaysRemaining <= 0;
    }
    if (parsedTrialEndsAt != null && parsedTrialEndsAt!.isBefore(DateTime.now())) {
      return true;
    }
    if (parsedSubscriptionEndsAt != null && parsedSubscriptionEndsAt!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  bool get isTrialExpired => !isSubscribed && (isExpired || (!isInTrial && parsedTrialEndsAt != null));

  bool get isFreePlan =>
      subscription == null ||
      subscription?.slug == 'free' ||
      subscription?.name == 'مجاني' ||
      subscription?.name == 'الخطة المجانية';

  String get planTitle {
    if (isSubscribed && subscription != null && !isFreePlan) {
      return subscription!.name;
    }
    if (isInTrial && !isExpired) {
      return 'تجربة مجانية';
    }
    if (isTrialExpired) {
      return 'انتهت التجربة';
    }
    if (subscription != null && !isFreePlan) {
      return subscription!.name;
    }
    return 'مجاني';
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
