import 'package:flutter/foundation.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/devices/data/repositories/device_repository.dart';
import 'package:managerapp/devices/data/repositories/totp_api_repository.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';

class RecoverController extends ChangeNotifier {
  RecoverController({
    required TotpApiRepository totpApiRepository,
    required DeviceRepository deviceRepository,
  })  : _totpApiRepository = totpApiRepository,
        _deviceRepository = deviceRepository;

  final TotpApiRepository _totpApiRepository;
  final DeviceRepository _deviceRepository;

  bool isLoading = false;
  String? error;

  Future<bool> recover({
    required TotpCredential credential,
    required String recoveryCode,
  }) async {
    final trimmedCode = recoveryCode.trim();
    if (trimmedCode.isEmpty) {
      error = 'Informe um recovery code.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _totpApiRepository.recoverTotp(trimmedCode);
      final account = TotpAccount(
        id: '${credential.issuer}_${credential.account}_${DateTime.now().millisecondsSinceEpoch}',
        email: credential.account,
        issuer: credential.issuer,
        secret: response.secret,
      );
      await _deviceRepository.addAccount(account);
      return true;
    } on AppException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Nao foi possivel restaurar o autenticador.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
