class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final String? role;
  final String? avatarUrl;
  final bool isBanned;

  UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.createdAt,
    this.role,
    this.avatarUrl,
    this.isBanned = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isBanned: json['is_banned'] as bool? ?? false,
    );
  }
}
