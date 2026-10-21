import 'package:flutter/material.dart';

class MaterialThumbnail extends StatelessWidget {
  const MaterialThumbnail({super.key, required this.stone});
  final bool stone;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ilustrasi material',
    image: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        size: const Size(64, 72),
        painter: _PilePainter(stone),
      ),
    ),
  );
}

class _PilePainter extends CustomPainter {
  const _PilePainter(this.stone);
  final bool stone;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEAF0E9), BlendMode.srcOver);
    final paint = Paint()
      ..color = stone ? const Color(0xFF89968E) : const Color(0xFFC9AF83);
    final path = Path()
      ..moveTo(4, 60)
      ..quadraticBezierTo(16, 45, 28, 27)
      ..quadraticBezierTo(33, 22, 39, 33)
      ..lineTo(62, 60)
      ..close();
    canvas.drawPath(path, paint);
    paint.color = stone ? const Color(0xFF65776B) : const Color(0xFFA88A61);
    for (var i = 0; i < 18; i++) {
      final x = 15.0 + (i * 13 % 36);
      final y = 47.0 + (i * 7 % 12);
      canvas.drawCircle(Offset(x, y), stone ? 3.4 : 1.2, paint);
    }
    canvas.drawOval(
      const Rect.fromLTWH(6, 61, 53, 3),
      Paint()..color = const Color(0xFFCBD8CA),
    );
  }

  @override
  bool shouldRepaint(covariant _PilePainter oldDelegate) =>
      stone != oldDelegate.stone;
}
