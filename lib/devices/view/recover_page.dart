import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:managerapp/devices/controller/recover_controller.dart';
import 'package:managerapp/devices/domain/model/totp_credential.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key, required this.credential});

  final TotpCredential credential;

  @override
  State<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final _formKey = GlobalKey<FormState>();
  final _recoveryCodeController = TextEditingController();

  @override
  void dispose() {
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<RecoverController>();
    final success = await controller.recover(
      credential: widget.credential,
      recoveryCode: _recoveryCodeController.text,
    );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurar autenticador'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Consumer<RecoverController>(
                builder: (context, controller, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          size: 56,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Recovery code',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Digite um recovery code para restaurar seu autenticador.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Card(
                          color: colorScheme.surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text(
                                    widget.credential.issuer.isNotEmpty
                                        ? widget.credential.issuer[0]
                                            .toUpperCase()
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.credential.issuer,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        widget.credential.account,
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
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _recoveryCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Recovery code',
                            hintText: 'xxxx-xxxx',
                            prefixIcon: Icon(Icons.key_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o recovery code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cada recovery code so pode ser usado uma vez.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: controller.isLoading ? null : _submit,
                          child: controller.isLoading
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Text('Restaurar'),
                        ),
                        if (controller.error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.error!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
