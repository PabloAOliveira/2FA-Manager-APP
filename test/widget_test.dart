import 'package:flutter_test/flutter_test.dart';
import 'package:managerapp/devices/domain/usecase/generate_totp_usecase.dart';
import 'package:managerapp/devices/domain/usecase/parse_otpauth_usecase.dart';

void main() {
  test('parse otpauth uri extracts secret issuer and email', () {
    const raw =
        'otpauth://totp/Meu%202FA:eu@email.com?secret=KGLH2IIVTOKKJ66N7VWIGJZX3I3UNGDI&issuer=Meu%202FA';

    final account = ParseOtpauthUseCase()(raw);

    expect(account.secret, 'KGLH2IIVTOKKJ66N7VWIGJZX3I3UNGDI');
    expect(account.issuer, 'Meu 2FA');
    expect(account.email, 'eu@email.com');
  });

  test('generate totp returns 6 digit code', () {
    const secret = 'KGLH2IIVTOKKJ66N7VWIGJZX3I3UNGDI';

    final result = GenerateTotpUseCase()(secret);

    expect(result.code.length, 6);
    expect(result.remainingSeconds, greaterThan(0));
    expect(result.remainingSeconds, lessThanOrEqualTo(30));
  });
}
