import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../app/theme/app_tokens.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});
  @override
  State<BarcodeScanScreen> createState() => _State();
}

class _State extends State<BarcodeScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              final code = capture.barcodes
                  .map((b) => b.rawValue)
                  .firstWhere((v) => v != null && v.isNotEmpty,
                      orElse: () => null);
              if (code != null) {
                _handled = true;
                Navigator.of(context).pop(code);
              }
            },
          ),
          const _ScanOverlay(),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final frameSize = constraints.maxWidth * 0.65;
      final frameTop = (constraints.maxHeight - frameSize) * 0.40;

      return Stack(
        children: [
          // Semi-transparent mask — four panels around the frame
          Positioned.fill(
            child: CustomPaint(
              painter: _MaskPainter(
                frameSize: frameSize,
                frameTop: frameTop,
              ),
            ),
          ),
          // Corner frame
          Positioned(
            left: (constraints.maxWidth - frameSize) / 2,
            top: frameTop,
            width: frameSize,
            height: frameSize,
            child: const _CornerFrame(),
          ),
          // Hint label below frame
          Positioned(
            left: 0,
            right: 0,
            top: frameTop + frameSize + AppTokens.space16,
            child: const Text(
              'Align barcode within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MaskPainter extends CustomPainter {
  const _MaskPainter({required this.frameSize, required this.frameTop});
  final double frameSize;
  final double frameTop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final frameLeft = (size.width - frameSize) / 2;
    final frameRight = frameLeft + frameSize;
    final frameBottom = frameTop + frameSize;

    // Top
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, frameTop), paint);
    // Bottom
    canvas.drawRect(
        Rect.fromLTRB(0, frameBottom, size.width, size.height), paint);
    // Left
    canvas.drawRect(
        Rect.fromLTRB(0, frameTop, frameLeft, frameBottom), paint);
    // Right
    canvas.drawRect(
        Rect.fromLTRB(frameRight, frameTop, size.width, frameBottom), paint);
  }

  @override
  bool shouldRepaint(_MaskPainter old) =>
      old.frameSize != frameSize || old.frameTop != frameTop;
}

class _CornerFrame extends StatelessWidget {
  const _CornerFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CornerPainter());
  }
}

class _CornerPainter extends CustomPainter {
  static const double _arm = 24;
  static const double _stroke = 3.5;
  static const double _r = AppTokens.radiusSm;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(0, _arm + _r)
          ..arcToPoint(Offset(_r, _r),
              radius: const Radius.circular(_r), clockwise: false)
          ..lineTo(_arm, 0),
        paint);

    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(w - _arm, 0)
          ..lineTo(w - _r, 0)
          ..arcToPoint(Offset(w, _r),
              radius: const Radius.circular(_r), clockwise: true)
          ..lineTo(w, _arm),
        paint);

    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(w, h - _arm)
          ..lineTo(w, h - _r)
          ..arcToPoint(Offset(w - _r, h),
              radius: const Radius.circular(_r), clockwise: true)
          ..lineTo(w - _arm, h),
        paint);

    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(_arm, h)
          ..lineTo(_r, h)
          ..arcToPoint(Offset(0, h - _r),
              radius: const Radius.circular(_r), clockwise: true)
          ..lineTo(0, h - _arm),
        paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
