import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:managerapp/app.dart';
import 'package:managerapp/core/utils/token_storage.dart';
import 'package:managerapp/devices/controller/device_list_controller.dart';
import 'package:managerapp/devices/controller/qr_scanner_controller.dart';
import 'package:managerapp/devices/controller/recover_controller.dart';
import 'package:managerapp/devices/data/repositories/device_repository.dart';
import 'package:managerapp/devices/data/repositories/totp_api_repository.dart';
import 'package:managerapp/devices/domain/usecase/generate_totp_usecase.dart';
import 'package:managerapp/devices/domain/usecase/parse_otpauth_usecase.dart';
import 'package:managerapp/login/controller/login_controller.dart';
import 'package:managerapp/login/data/repositories/auth_repository.dart';
import 'package:managerapp/login/domain/usecase/login_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final authRepository = AuthRepository(tokenStorage: tokenStorage);
  final deviceRepository = DeviceRepository();
  final totpApiRepository = TotpApiRepository(tokenStorage: tokenStorage);
  final loginUseCase = LoginUseCase(authRepository);
  final parseOtpauthUseCase = ParseOtpauthUseCase();
  final generateTotpUseCase = GenerateTotpUseCase();

  final isLoggedIn = await authRepository.isLoggedIn();
  final initialRoute = isLoggedIn ? '/devices' : '/login';

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<DeviceRepository>.value(value: deviceRepository),
        Provider<TotpApiRepository>.value(value: totpApiRepository),
        Provider<ParseOtpauthUseCase>.value(value: parseOtpauthUseCase),
        Provider<GenerateTotpUseCase>.value(value: generateTotpUseCase),
        ChangeNotifierProvider(
          create: (_) => LoginController(loginUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceListController(
            deviceRepository: deviceRepository,
            totpApiRepository: totpApiRepository,
            generateTotpUseCase: generateTotpUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => QrScannerController(
            parseOtpauthUseCase: parseOtpauthUseCase,
            deviceRepository: deviceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RecoverController(
            totpApiRepository: totpApiRepository,
            deviceRepository: deviceRepository,
          ),
        ),
      ],
      child: App(initialRoute: initialRoute),
    ),
  );
}
