import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/devices/data/repositories/device_repository.dart';
import 'package:managerapp/devices/data/repositories/totp_api_repository.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';
import 'package:managerapp/devices/domain/usecase/generate_totp_usecase.dart';

class DeviceListController extends ChangeNotifier {
  DeviceListController({
    required DeviceRepository deviceRepository,
    required TotpApiRepository totpApiRepository,
    required GenerateTotpUseCase generateTotpUseCase,
  })  : _deviceRepository = deviceRepository,
        _totpApiRepository = totpApiRepository,
        _generateTotpUseCase = generateTotpUseCase;

  final DeviceRepository _deviceRepository;
  final TotpApiRepository _totpApiRepository;
  final GenerateTotpUseCase _generateTotpUseCase;

  List<TotpAccountView> accounts = [];
  List<TotpCredential> missingCredentials = [];
  bool isLoading = false;
  String? error;
  Timer? _timer;

  Future<void> loadAccounts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _deviceRepository.getAccounts(),
        _totpApiRepository.getCredentials(),
      ]);

      final storedAccounts = results[0] as List<TotpAccount>;
      final serverCredentials = results[1] as List<TotpCredential>;

      accounts = storedAccounts.map(_buildView).toList();
      missingCredentials = _findMissingCredentials(
        serverCredentials: serverCredentials,
        localAccounts: storedAccounts,
      );
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Nao foi possivel carregar as contas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<TotpCredential> _findMissingCredentials({
    required List<TotpCredential> serverCredentials,
    required List<TotpAccount> localAccounts,
  }) {
    return serverCredentials.where((credential) {
      if (credential.status != 'active') {
        return false;
      }

      final hasLocalSecret = localAccounts.any(
        (account) =>
            account.email == credential.account &&
            account.issuer == credential.issuer,
      );

      return !hasLocalSecret;
    }).toList();
  }

  void startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (accounts.isEmpty) {
        return;
      }
      accounts = accounts
          .map((view) => _buildView(view.account))
          .toList();
      notifyListeners();
    });
  }

  Future<void> deleteAccount(String id) async {
    await _deviceRepository.deleteAccount(id);
    await loadAccounts();
  }

  TotpAccountView _buildView(TotpAccount account) {
    final result = _generateTotpUseCase(account.secret);
    return TotpAccountView(
      account: account,
      code: result.code,
      remainingSeconds: result.remainingSeconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
