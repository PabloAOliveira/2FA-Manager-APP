import 'package:flutter/material.dart';
import 'package:managerapp/core/theme/app_theme.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';
import 'package:managerapp/devices/view/device_detail_page.dart';
import 'package:managerapp/devices/view/device_list_page.dart';
import 'package:managerapp/devices/view/qr_scanner_page.dart';
import 'package:managerapp/devices/view/recover_page.dart';
import 'package:managerapp/login/view/login_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2FA Manager',
      theme: AppTheme.dark,
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginPage(),
        '/devices': (_) => const DeviceListPage(),
        '/scan': (_) => const QrScannerPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/device-detail') {
          final account = settings.arguments as TotpAccount;
          return MaterialPageRoute(
            builder: (_) => DeviceDetailPage(account: account),
          );
        }
        if (settings.name == '/recover') {
          final credential = settings.arguments as TotpCredential;
          return MaterialPageRoute(
            builder: (_) => RecoverPage(credential: credential),
          );
        }
        return null;
      },
    );
  }
}
