import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:managerapp/core/constants/app_config.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/core/utils/token_storage.dart';
import 'package:managerapp/devices/domain/model/recover_response.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';

class TotpApiRepository {
  TotpApiRepository({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _tokenStorage;

  Future<List<TotpCredential>> getCredentials() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return [];
      }

      final uri =
          Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.totpCredentialsPath}');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 401 || response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => TotpCredential.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<RecoverResponse> recoverTotp(String recoveryCode) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw AppException('Sessao expirada. Faca login novamente.');
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.totpRecoverPath}');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'recovery_code': recoveryCode}),
    );

    if (response.statusCode != 200) {
      throw AppException(_extractErrorMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final secret = body['secret'] as String?;
    final otpauthUri = body['otpauth_uri'] as String?;

    if (secret == null || secret.isEmpty || otpauthUri == null) {
      throw AppException('Resposta de recovery invalida.');
    }

    return RecoverResponse.fromJson(body);
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final message = first['msg'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      }
    } catch (_) {
      // Ignore parse errors and fall back to status code.
    }
    return 'Erro ${response.statusCode} ao comunicar com a API.';
  }
}
