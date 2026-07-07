import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:managerapp/devices/controller/device_list_controller.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';
import 'package:managerapp/login/data/repositories/auth_repository.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DeviceListController>();
      controller.loadAccounts();
      controller.startTicker();
    });
  }

  Future<void> _openRecover(TotpCredential credential) async {
    final restored = await Navigator.of(context).pushNamed(
      '/recover',
      arguments: credential,
    );
    if (restored == true && mounted) {
      await context.read<DeviceListController>().loadAccounts();
    }
  }

  Future<void> _openScanner() async {
    final added = await Navigator.of(context).pushNamed('/scan');
    if (added == true && mounted) {
      await context.read<DeviceListController>().loadAccounts();
    }
  }

  Future<void> _logout() async {
    await context.read<AuthRepository>().logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu 2FA'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear QR'),
      ),
      body: Consumer<DeviceListController>(
        builder: (context, controller, _) {
          if (controller.isLoading &&
              controller.accounts.isEmpty &&
              controller.missingCredentials.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null &&
              controller.accounts.isEmpty &&
              controller.missingCredentials.isEmpty) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Erro ao carregar',
              subtitle: controller.error!,
            );
          }

          if (controller.accounts.isEmpty &&
              controller.missingCredentials.isEmpty) {
            return _EmptyState(
              icon: Icons.qr_code_scanner,
              title: 'Nenhuma conta cadastrada',
              subtitle:
                  'Toque em "Escanear QR" para adicionar seu autenticador.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final credential in controller.missingCredentials) ...[
                _MissingCredentialCard(
                  credential: credential,
                  onRestore: () => _openRecover(credential),
                ),
                const SizedBox(height: 12),
              ],
              if (controller.accounts.isNotEmpty) ...[
                _InfoBanner(
                  icon: Icons.info_outline,
                  title: 'Confirme no site',
                  subtitle:
                      'Volte ao site e digite este codigo para ativar o 2FA.',
                ),
                const SizedBox(height: 12),
              ],
              for (final item in controller.accounts) ...[
                _AccountCard(
                  item: item,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/device-detail',
                      arguments: item.account,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingCredentialCard extends StatelessWidget {
  const _MissingCredentialCard({
    required this.credential,
    required this.onRestore,
  });

  final TotpCredential credential;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.issuer,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      Text(
                        credential.account,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer
                              .withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '2FA ativo no servidor. Restaure com um recovery code.',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onRestore,
                child: const Text('Restaurar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.item,
    required this.onTap,
  });

  final TotpAccountView item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = item.remainingSeconds / 30;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      item.account.issuer.isNotEmpty
                          ? item.account.issuer[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.account.issuer,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.account.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  item.code,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Renova em ${item.remainingSeconds}s',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
