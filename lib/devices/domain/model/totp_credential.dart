class TotpCredential {
  const TotpCredential({
    required this.issuer,
    required this.account,
    required this.status,
    this.enrolledAt,
    this.activatedAt,
  });

  final String issuer;
  final String account;
  final String status;
  final String? enrolledAt;
  final String? activatedAt;

  factory TotpCredential.fromJson(Map<String, dynamic> json) {
    return TotpCredential(
      issuer: json['issuer'] as String,
      account: json['account'] as String,
      status: json['status'] as String,
      enrolledAt: json['enrolled_at'] as String?,
      activatedAt: json['activated_at'] as String?,
    );
  }
}
