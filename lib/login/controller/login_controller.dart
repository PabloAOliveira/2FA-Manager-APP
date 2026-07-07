import 'package:flutter/foundation.dart';
import 'package:managerapp/core/errors/app_exception.dart';
import 'package:managerapp/login/domain/usecase/login_usecase.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._loginUseCase);

  final LoginUseCase _loginUseCase;

  bool isLoading = false;
  String? error;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _loginUseCase(email: email, password: password);
      return true;
    } on AppException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Nao foi possivel fazer login. Tente novamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
