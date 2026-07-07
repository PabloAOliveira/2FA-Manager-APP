import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/devices/domain/model/device.dart';

class DeviceRepository {
  DeviceRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accountsKey = 'totp_accounts';

  final FlutterSecureStorage _storage;

  Future<List<TotpAccount>> getAccounts() async {
    final raw = await _storage.read(key: _accountsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TotpAccount.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TotpAccount> addAccount(TotpAccount account) async {
    final accounts = await getAccounts();
    final alreadyExists = accounts.any(
      (item) => item.email == account.email && item.issuer == account.issuer,
    );

    if (alreadyExists) {
      throw AppException('Esta conta ja foi adicionada.');
    }

    accounts.add(account);
    await _saveAccounts(accounts);
    return account;
  }

  Future<void> deleteAccount(String id) async {
    final accounts = await getAccounts();
    accounts.removeWhere((item) => item.id == id);
    await _saveAccounts(accounts);
  }

  Future<void> _saveAccounts(List<TotpAccount> accounts) async {
    final encoded = jsonEncode(accounts.map((item) => item.toJson()).toList());
    await _storage.write(key: _accountsKey, value: encoded);
  }
}
