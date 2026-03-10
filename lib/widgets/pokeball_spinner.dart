import 'package:flutter/material.dart';
import 'dart:math';

/// Loading spinner รูป Pokéball หมุน
/// ใช้ CustomPainter วาดรูป + AnimationController หมุน
class PokeballSpinner extends StatefulWidget {
  final double size;
  const PokeballSpinner({super.key, this.size = 60});

  @override
  State<PokeballSpinner> createState() => _PokeballSpinnerState();
}

class _PokeballSpinnerState extends State<PokeballSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PokeballPainter(),
          ),
        );
      },
    );
  }
}

class _PokeballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ครึ่งบน - แดง
    final topPaint = Paint()..color = const Color(0xFFEE1515);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      true,
      topPaint,
    );

    // ครึ่งล่าง - ขาว
    final bottomPaint = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi,
      true,
      bottomPaint,
    );

    // เส้นกลาง
    final linePaint =
        Paint()
          ..color = const Color(0xFF222224)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06;
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );

    // ขอบนอก
    final borderPaint =
        Paint()
          ..color = const Color(0xFF222224)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06;
    canvas.drawCircle(center, radius, borderPaint);

    // วงกลมกลาง - outer
    final outerCirclePaint = Paint()..color = const Color(0xFF222224);
    canvas.drawCircle(center, radius * 0.25, outerCirclePaint);

    // วงกลมกลาง - inner (ขาว)
    final innerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.18, innerCirclePaint);

    // จุดกลางสุด
    final dotPaint = Paint()..color = const Color(0xFF222224);
    canvas.drawCircle(center, radius * 0.08, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
