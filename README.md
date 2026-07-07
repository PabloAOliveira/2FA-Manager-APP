# Meu 2FA — App Mobile

App Flutter para autenticação em duas etapas (TOTP). Funciona em conjunto com o site web e a API Meu 2FA: o site gera o QR code e confirma o setup; o app escaneia o QR, guarda o secret localmente e gera códigos TOTP offline (RFC 6238).

## Funcionalidades

- Login com email e senha (`POST /auth/login`)
- Escaneamento de QR code (`otpauth://totp/...`)
- Geração de códigos TOTP offline (SHA1, 6 dígitos, 30s)
- Lista de contas com countdown visual
- Sincronização com servidor via `GET /totp/credentials`
- Restauração após reinstalação com recovery code (`POST /totp/recover`)
- Mensagens de erro da API traduzidas para português
- Tema dark Material 3 (Indigo)

## Fluxo site + app

```
[SITE] Register / Login
[SITE] Habilitar 2FA → POST /totp/setup → exibe QR (otpauth_uri)
[APP]  Login → escaneia QR → salva secret localmente
[APP]  Exibe código TOTP (offline, renova a cada 30s)
[SITE] Usuário digita o código → POST /totp/verify-setup → 2FA ativo
```

Após reinstalar o app:

```
[APP]  Login → GET /totp/credentials (servidor tem 2FA active, app sem secret)
[APP]  Restaurar com recovery code → POST /totp/recover → secret salvo localmente
[APP]  Volta a gerar códigos TOTP offline
```

## O que o app NÃO faz

- Não chama `POST /totp/setup` nem `POST /totp/verify-setup` (responsabilidade do site)
- Não envia o secret de volta para a API
- Não gera código TOTP via rede (100% offline após o secret estar salvo)

## Requisitos

- Flutter SDK ^3.11.5
- Android (minSdk 21) ou iOS
- Câmera (para escanear QR code)

## Configuração

Edite a URL da API em [`lib/core/constants/app_config.dart`](lib/core/constants/app_config.dart):

```dart
// Produção (Render)
static const String apiBaseUrl = 'https://totp-server-gqoo.onrender.com';

// Dev emulador Android
// static const String apiBaseUrl = 'http://10.0.2.2:7070';
```

Documentação da API: [Swagger](https://totp-server-gqoo.onrender.com/docs)

## Como rodar

```bash
flutter pub get
flutter run
```

Testes:

```bash
flutter test
flutter analyze
```

## Endpoints usados pelo app

| Método | Rota | Uso |
|--------|------|-----|
| `POST` | `/auth/login` | Login, salva tokens |
| `GET` | `/users/me` | Perfil (opcional) |
| `GET` | `/totp/credentials` | Metadados do 2FA no servidor (sem secret) |
| `POST` | `/totp/recover` | Restaurar secret com recovery code |

## Arquitetura

Organização por módulo (MVC + Clean Architecture):

```
lib/
├── main.dart / app.dart
├── core/
│   ├── constants/     # AppConfig (base URL)
│   ├── errors/        # AppException, ErrorTranslator
│   ├── theme/         # AppTheme (dark indigo)
│   └── utils/         # TokenStorage
├── login/
│   ├── view/          # LoginPage
│   ├── controller/    # LoginController (Provider)
│   ├── domain/        # User, LoginUseCase
│   └── data/          # AuthRepository
└── devices/
    ├── view/          # Lista, detalhe, scanner, recovery
    ├── controller/    # DeviceList, QrScanner, Recover
    ├── domain/        # Models, use cases (parse QR, gerar TOTP)
    └── data/          # DeviceRepository (local), TotpApiRepository
```

- **State management:** Provider + ChangeNotifier
- **Storage local:** `flutter_secure_storage` (tokens + secrets TOTP)
- **TOTP:** pacote `otp` (RFC 6238)
- **Scanner:** `mobile_scanner`

## Segurança

- Secrets TOTP e tokens JWT ficam apenas no secure storage do dispositivo
- O secret nunca trafega para a API após o scan (exceto recovery, que exige recovery code válido)
- Recovery codes são de uso único

## Licença

Projeto privado (`publish_to: 'none'`).
