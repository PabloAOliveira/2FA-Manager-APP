class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = 'https://totp-server-gqoo.onrender.com';

  /// Dev emulador'http://10.0.2.2:7070'
  static const String authLoginPath = '/auth/login';
  static const String usersMePath = '/users/me';
  static const String totpCredentialsPath = '/totp/credentials';
  static const String totpRecoverPath = '/totp/recover';
}
