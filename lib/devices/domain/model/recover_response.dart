class RecoverResponse {
  const RecoverResponse({
    required this.secret,
    required this.otpauthUri,
  });

  final String secret;
  final String otpauthUri;

  factory RecoverResponse.fromJson(Map<String, dynamic> json) {
    return RecoverResponse(
      secret: json['secret'] as String,
      otpauthUri: json['otpauth_uri'] as String,
    );
  }
}
