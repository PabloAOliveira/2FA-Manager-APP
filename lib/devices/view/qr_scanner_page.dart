import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:managerapp/devices/controller/qr_scanner_controller.dart';
import 'package:managerapp/devices/domain/usecase/generate_totp_usecase.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasHandledScan = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasHandledScan) {
      return;
    }

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    _hasHandledScan = true;
    final controller = context.read<QrScannerController>();
    final account = await controller.handleScan(rawValue);

    if (!mounted) {
      return;
    }

    if (account != null) {
      final preview = context.read<GenerateTotpUseCase>()(account.secret);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta salva. Codigo atual: ${preview.code}'),
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    _hasHandledScan = false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear QR code'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
                CustomPaint(
                  painter: _ScannerOverlayPainter(
                    overlayColor: Colors.black.withValues(alpha: 0.55),
                    borderColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Consumer<QrScannerController>(
            builder: (context, controller, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isProcessing) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Processando QR code...',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ] else if (controller.error != null) ...[
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        controller.error!,
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Icon(
                        Icons.qr_code_scanner,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aponte a camera para o QR code exibido no site.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.overlayColor,
    required this.borderColor,
  });

  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 260.0;
    final left = (size.width - cutoutSize) / 2;
    final top = (size.height - cutoutSize) / 2;
    final cutoutRect = Rect.fromLTWH(left, top, cutoutSize, cutoutSize);

    final overlayPaint = Paint()..color = overlayColor;
    final backgroundPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path()..addRRect(
          RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)),
        );
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(overlayPath, overlayPaint);

    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const radius = 16.0;

    _drawCorner(canvas, cornerPaint, left, top, cornerLength, radius, true, true);
    _drawCorner(
      canvas,
      cornerPaint,
      left + cutoutSize,
      top,
      cornerLength,
      radius,
      false,
      true,
    );
    _drawCorner(
      canvas,
      cornerPaint,
      left,
      top + cutoutSize,
      cornerLength,
      radius,
      true,
      false,
    );
    _drawCorner(
      canvas,
      cornerPaint,
      left + cutoutSize,
      top + cutoutSize,
      cornerLength,
      radius,
      false,
      false,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double length,
    double radius,
    bool leftSide,
    bool topSide,
  ) {
    final horizontalStart = leftSide ? x : x - length;
    final horizontalEnd = leftSide ? x + length : x;
    final verticalStart = topSide ? y : y - length;
    final verticalEnd = topSide ? y + length : y;

    canvas.drawLine(
      Offset(horizontalStart, topSide ? y + radius : y - radius),
      Offset(horizontalEnd, topSide ? y + radius : y - radius),
      paint,
    );
    canvas.drawLine(
      Offset(leftSide ? x + radius : x - radius, verticalStart),
      Offset(leftSide ? x + radius : x - radius, verticalEnd),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
