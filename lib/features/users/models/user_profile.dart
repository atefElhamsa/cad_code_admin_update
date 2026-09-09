class UserProfile {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final String? role;
  final String? avatarUrl;
  final bool isBanned;
  final List<String> unlockedFolders;

  UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.createdAt,
    this.role,
    this.avatarUrl,
    this.isBanned = false,
    this.unlockedFolders = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<String> folders = [];
    if (json['user_unlocked_folders'] != null) {
      final List unlockedList = json['user_unlocked_folders'] as List;
      for (var item in unlockedList) {
        if (item['course_folders'] != null && item['course_folders']['title'] != null) {
          folders.add(item['course_folders']['title'] as String);
        }
      }
    } else if (json['unlocked_folders_injected'] != null) {
      folders = List<String>.from(json['unlocked_folders_injected']);
    }

    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isBanned: json['is_banned'] as bool? ?? false,
      unlockedFolders: folders,
    );
  }
}
