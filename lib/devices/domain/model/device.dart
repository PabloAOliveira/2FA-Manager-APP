class TotpAccount {
  const TotpAccount({
    required this.id,
    required this.email,
    required this.issuer,
    required this.secret,
  });

  final String id;
  final String email;
  final String issuer;
  final String secret;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'issuer': issuer,
      'secret': secret,
    };
  }

  factory TotpAccount.fromJson(Map<String, dynamic> json) {
    return TotpAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      issuer: json['issuer'] as String,
      secret: json['secret'] as String,
    );
  }
}

class TotpAccountView {
  const TotpAccountView({
    required this.account,
    required this.code,
    required this.remainingSeconds,
  });

  final TotpAccount account;
  final String code;
  final int remainingSeconds;
}
