import 'dart:math';
import 'package:flutter/material.dart';
import 'package:internusa_group/utils/theme.dart';

class WaveBackgroundPainter extends CustomPainter {
  final double value;
  final Color waveColor;

  WaveBackgroundPainter(this.value, this.waveColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.textLight, AppColors.textLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final wavePaint = Paint()
      ..color = waveColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    const amplitude = 30.0;
    final frequency = 2 * pi / size.width;

    path.moveTo(0, size.height * 0.6);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height * 0.6 + sin(x * frequency + value * 2 * pi) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant WaveBackgroundPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.waveColor != waveColor;
}
