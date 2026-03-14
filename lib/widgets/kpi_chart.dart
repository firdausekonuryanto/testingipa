import 'package:flutter/material.dart';
import 'dart:math' as math;

class KpiBarChartCustom extends StatelessWidget {
  final List<double> monthlyScores;
  final double maxY;
  final double barWidth;
  final double spacing;
  final double chartHeight;

  const KpiBarChartCustom({
    super.key,
    required this.monthlyScores,
    this.maxY = 120,
    this.barWidth = 30,
    this.spacing = 6,
    this.chartHeight = 200,
  });

  static const _defaultLabels = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
  ];

  @override
  Widget build(BuildContext context) {
    final labels = (monthlyScores.length <= _defaultLabels.length)
        ? _defaultLabels.sublist(0, monthlyScores.length)
        : List.generate(monthlyScores.length, (i) => 'M${i + 1}');

    return SizedBox(
      height: chartHeight + 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // === Skala Y di kiri ===
          SizedBox(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(9, (i) {
                final value = (maxY / 8) * (8 - i);
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),

          // === Chart Area ===
          Expanded(
            child: LayoutBuilder(builder: (ctx, constraints) {
              final totalWidth = monthlyScores.length * barWidth +
                  (monthlyScores.length - 1) * spacing;
              final startPadding = math
                  .max(0.0, (constraints.maxWidth - totalWidth) / 2)
                  .toDouble();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: startPadding, right: startPadding),
                  child: SizedBox(
                    width: totalWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: chartHeight,
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: GridLinesPainter(
                                      maxY: maxY, lineCount: 8),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(monthlyScores.length,
                                    (index) {
                                  final value =
                                      monthlyScores[index].clamp(0, maxY);
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        right: index == monthlyScores.length - 1
                                            ? 0
                                            : spacing),
                                    child: BarWidget(
                                      width: barWidth,
                                      height: chartHeight,
                                      value: value.toDouble(),
                                      maxValue: maxY,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Row(
                            children: List.generate(labels.length, (index) {
                              return SizedBox(
                                width: barWidth,
                                child: Center(
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class BarWidget extends StatelessWidget {
  final double width;
  final double height;
  final double value;
  final double maxValue;

  const BarWidget({
    super.key,
    required this.width,
    required this.height,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final filledRatio =
        (maxValue <= 0) ? 0.0 : (value / maxValue).clamp(0.0, 1.0).toDouble();
    final filledHeight = filledRatio * height;

    const borderRadius = 999.0;
    const dotSize = 12.0;
    const dotOffset = 10.0; // >>> diturunkan ke bawah

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Strip background
          ClipRRect(
            borderRadius: BorderRadius.circular(width),
            child: CustomPaint(
              size: Size(width, height),
              painter: StripedPainter(
                filledHeight: filledHeight,
                stripeColor: Colors.grey.shade600.withOpacity(0.3),
                stripeSpacing: 18,
                stripeThickness: 10,
              ),
            ),
          ),
          // Bar utama biru
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: math.max(6.0, filledHeight).toDouble(),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          // Lingkaran putih (sedikit diturunkan)
          if (filledHeight > 8)
            Positioned(
              bottom: filledHeight - (dotSize / 2) - dotOffset,
              left: ((width - dotSize) / 2).toDouble(),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StripedPainter extends CustomPainter {
  final double filledHeight;
  final Color stripeColor;
  final double stripeSpacing;
  final double stripeThickness;

  StripedPainter({
    required this.filledHeight,
    this.stripeColor = const Color(0x22000000),
    this.stripeSpacing = 16,
    this.stripeThickness = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = stripeThickness
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(size.width));
    canvas.save();
    canvas.clipRRect(rrect);

    final emptyTop = 0.0;
    final emptyBottom = math.max(0.0, size.height - filledHeight).toDouble();

    final emptyRect = Rect.fromLTWH(0, emptyTop, size.width, emptyBottom);
    canvas.clipRect(emptyRect);

    for (double i = -size.height; i < size.width; i += stripeSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripedPainter old) {
    return old.filledHeight != filledHeight ||
        old.stripeColor != stripeColor ||
        old.stripeSpacing != stripeSpacing;
  }
}

class GridLinesPainter extends CustomPainter {
  final double maxY;
  final int lineCount;
  final Color lineColor;

  GridLinesPainter({
    required this.maxY,
    this.lineCount = 8,
    this.lineColor = const Color(0x22000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (int i = 0; i <= lineCount; i++) {
      final y = size.height * (1 - i / lineCount).toDouble();
      const dashWidth = 6.0;
      const dashSpace = 6.0;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + dashWidth, size.width), y),
          paint,
        );
        x += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridLinesPainter old) => false;
}
