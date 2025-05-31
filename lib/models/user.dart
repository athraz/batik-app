class User {
  final String? id;
  final String email;
  final String password;
  final String username;
  final String role;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });
}
