class AuthUser {
  final int id;
  final String username;
  final String email;
  final String token;
  final String role;
  final String? profilePicture;
  final String? bio;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.role,
    this.profilePicture,
    this.bio,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      username: json['name'] ?? json['username'] ?? '', 
      email: json['email'],
      token: json['token'] ?? '',
      role: json['role'] ?? 'USER',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'role': role,
      'profilePicture': profilePicture,
      'bio': bio,
    };
  }

  AuthUser copyWith({
    String? username,
    String? email,
    String? token,
    String? role,
    String? profilePicture,
    String? bio,
  }) {
    return AuthUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
    );
  }
}