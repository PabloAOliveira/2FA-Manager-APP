import 'package:flutter/foundation.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/devices/data/repositories/device_repository.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/usecase/parse_otpauth_usecase.dart';

class QrScannerController extends ChangeNotifier {
  QrScannerController({
    required ParseOtpauthUseCase parseOtpauthUseCase,
    required DeviceRepository deviceRepository,
  })  : _parseOtpauthUseCase = parseOtpauthUseCase,
        _deviceRepository = deviceRepository;

  final ParseOtpauthUseCase _parseOtpauthUseCase;
  final DeviceRepository _deviceRepository;

  bool isProcessing = false;
  String? error;
  TotpAccount? savedAccount;

  Future<TotpAccount?> handleScan(String rawValue) async {
    if (isProcessing) {
      return null;
    }

    isProcessing = true;
    error = null;
    savedAccount = null;
    notifyListeners();

    try {
      final account = _parseOtpauthUseCase(rawValue);
      savedAccount = await _deviceRepository.addAccount(account);
      return savedAccount;
    } on AppException catch (e) {
      error = e.message;
      return null;
    } on FormatException {
      error = 'QR code invalido.';
      return null;
    } catch (_) {
      error = 'Nao foi possivel salvar a conta.';
      return null;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  void reset() {
    error = null;
    savedAccount = null;
    notifyListeners();
  }
}
