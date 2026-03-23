import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasDetected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _hasDetected = true;
    _controller.stop();
    Navigator.pop(context, barcode.rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Cámara ──
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // ── Overlay oscuro con recuadro transparente ──
          _buildScanOverlay(),

          // ── Botón Cerrar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildCircleButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // ── Texto de instrucción ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Escanear QR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ── Instrucción inferior ──
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Apunta al código QR del creador',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Controles inferiores ──
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flash
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, _) {
                    final torchOn = state.torchState == TorchState.on;
                    return _buildCircleButton(
                      icon: torchOn ? Icons.flash_on : Icons.flash_off,
                      onTap: () => _controller.toggleTorch(),
                      isActive: torchOn,
                    );
                  },
                ),
                const SizedBox(width: 48),
                // Cambiar cámara
                _buildCircleButton(
                  icon: Icons.cameraswitch_outlined,
                  onTap: () => _controller.switchCamera(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Overlay con máscara de escaneo ──
  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanSize) / 2;
        final top = (constraints.maxHeight - scanSize) / 2 - 30;

        return Stack(
          children: [
            // Fondo semitransparente con recuadro transparente
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanSize,
                      height: scanSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // Cualquier color, se recortará
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Esquinas decorativas
            Positioned(left: left, top: top, child: _buildCorner(0)),
            Positioned(right: left, top: top, child: _buildCorner(1)),
            Positioned(
              left: left,
              bottom: constraints.maxHeight - top - scanSize,
              child: _buildCorner(2),
            ),
            Positioned(
              right: left,
              bottom: constraints.maxHeight - top - scanSize,
              child: _buildCorner(3),
            ),
          ],
        );
      },
    );
  }

  // ── Esquina individual ──
  Widget _buildCorner(int position) {
    const size = 32.0;
    const thickness = 4.0;
    const color = Color(0xFF70C635);

    // 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          position: position,
          color: color,
          thickness: thickness,
        ),
      ),
    );
  }

  // ── Botón circular ──
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF70C635)
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// ── Custom Painter para esquinas ──
class _CornerPainter extends CustomPainter {
  final int position;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.position,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (position) {
      case 0: // top-left
        path.moveTo(0, size.height * 0.6);
        path.lineTo(0, 6);
        path.quadraticBezierTo(0, 0, 6, 0);
        path.lineTo(size.width * 0.6, 0);
        break;
      case 1: // top-right
        path.moveTo(size.width * 0.4, 0);
        path.lineTo(size.width - 6, 0);
        path.quadraticBezierTo(size.width, 0, size.width, 6);
        path.lineTo(size.width, size.height * 0.6);
        break;
      case 2: // bottom-left
        path.moveTo(0, size.height * 0.4);
        path.lineTo(0, size.height - 6);
        path.quadraticBezierTo(0, size.height, 6, size.height);
        path.lineTo(size.width * 0.6, size.height);
        break;
      case 3: // bottom-right
        path.moveTo(size.width * 0.4, size.height);
        path.lineTo(size.width - 6, size.height);
        path.quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - 6,
        );
        path.lineTo(size.width, size.height * 0.4);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
