import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/devices/domain/model/device.dart';

class ParseOtpauthUseCase {
  TotpAccount call(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      throw AppException('QR code invalido.');
    }

    final uri = Uri.parse(trimmed);
    if (uri.scheme != 'otpauth' || !uri.host.contains('totp')) {
      throw AppException('QR code nao e um otpauth TOTP valido.');
    }

    final secret = uri.queryParameters['secret'];
    if (secret == null || secret.isEmpty) {
      throw AppException('Secret nao encontrado no QR code.');
    }

    final issuer = uri.queryParameters['issuer'] ?? 'Meu 2FA';
    final email = _extractEmail(uri);

    return TotpAccount(
      id: '${issuer}_${email}_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      issuer: issuer,
      secret: secret,
    );
  }

  String _extractEmail(Uri uri) {
    final label = Uri.decodeComponent(uri.path.replaceFirst('/', ''));
    if (label.contains(':')) {
      return label.split(':').last;
    }
    return label.isEmpty ? 'conta' : label;
  }
}
