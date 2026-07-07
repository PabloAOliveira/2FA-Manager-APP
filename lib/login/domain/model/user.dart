class User {
  const User({
    required this.email,
    required this.name,
    required this.totpEnrolled,
    required this.totpStatus,
  });

  final String email;
  final String name;
  final bool totpEnrolled;
  final String totpStatus;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      totpEnrolled: json['totp_enrolled'] as bool? ?? false,
      totpStatus: json['totp_status'] as String? ?? 'none',
    );
  }
}
