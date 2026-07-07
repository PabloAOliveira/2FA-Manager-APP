import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:managerapp/core/constants/app_config.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/core/errors/error_translator.dart';
import 'package:managerapp/core/utils/token_storage.dart';
import 'package:managerapp/login/domain/model/user.dart';

class AuthRepository {
  AuthRepository({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _tokenStorage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.authLoginPath}');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw AppException(_extractErrorMessage(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = body['access_token'] as String?;
    final refreshToken = body['refresh_token'] as String?;

    if (accessToken == null || refreshToken == null) {
      throw AppException('Resposta de login invalida.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<User> getMe() async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw AppException('Sessao expirada. Faca login novamente.');
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.usersMePath}');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw AppException(_extractErrorMessage(response));
    }

    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasAccessToken();

  Future<void> logout() => _tokenStorage.clear();

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];

      if (detail is String && detail.isNotEmpty) {
        return ErrorTranslator.translate(detail, response.statusCode);
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final message = first['msg'];
          if (message is String && message.isNotEmpty) {
            return ErrorTranslator.translate(message, response.statusCode);
          }
        }
      }
    } catch (_) {
      // Ignore parse errors and fall back to status code.
    }
    return ErrorTranslator.translate('', response.statusCode);
  }
}
