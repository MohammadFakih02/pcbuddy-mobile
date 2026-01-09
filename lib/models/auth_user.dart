class AuthUser {
  final int id;
  final String username;
  final String email;
  final String token;
  final String role;
  final String? profilePicture;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.role,
    this.profilePicture,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      token: json['token'],
      role: json['role'], // "USER" or "ADMIN"
      profilePicture: json['profilePicture'],
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
    };
  }
}