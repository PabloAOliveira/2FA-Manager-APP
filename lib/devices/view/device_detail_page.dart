import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:managerapp/devices/domain/model/device.dart';
import 'package:managerapp/devices/domain/usecase/generate_totp_usecase.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key, required this.account});

  final TotpAccount account;

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  Timer? _timer;
  TotpCodeResult? _result;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    _refreshCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_refreshCode);
      }
    });
  }

  void _refreshCode() {
    final generateTotpUseCase = context.read<GenerateTotpUseCase>();
    _result = generateTotpUseCase(widget.account.secret);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = result.remainingSeconds / 30;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.issuer),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                widget.account.email,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      result.code,
                      style: textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Renova em ${result.remainingSeconds}s',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Codigo gerado offline. Nao e enviado para a API.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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
