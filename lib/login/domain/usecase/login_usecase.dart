import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/login/data/repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw AppException('Informe email e senha.');
    }

    await _authRepository.login(
      email: trimmedEmail,
      password: trimmedPassword,
    );
  }
}
