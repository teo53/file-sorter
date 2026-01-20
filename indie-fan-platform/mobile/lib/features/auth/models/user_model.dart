enum UserRole { fan, artist, admin }

class User {
  final String id;
  final String email;
  final String? nickname;
  final String? profileImage;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.nickname,
    this.profileImage,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      profileImage: json['profileImage'] as String?,
      role: _parseRole(json['role'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'ARTIST':
        return UserRole.artist;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.fan;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profileImage': profileImage,
      'role': role.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? nickname,
    String? profileImage,
  }) {
    return User(
      id: id,
      email: email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      role: role,
      createdAt: createdAt,
    );
  }
}
