import 'package:otp/otp.dart';

class TotpCodeResult {
  const TotpCodeResult({
    required this.code,
    required this.remainingSeconds,
  });

  final String code;
  final int remainingSeconds;
}

class GenerateTotpUseCase {
  TotpCodeResult call(String secret) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final code = OTP.generateTOTPCodeString(
      secret,
      now,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final elapsed = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 30;
    final remaining = 30 - elapsed;

    return TotpCodeResult(
      code: code,
      remainingSeconds: remaining == 0 ? 30 : remaining,
    );
  }
}
