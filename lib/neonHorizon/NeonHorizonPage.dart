import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NeonHorizonPage extends StatefulWidget {
  const NeonHorizonPage({Key? key}) : super(key: key);

  @override
  NeonHorizonPageState createState() => NeonHorizonPageState();
}

class NeonHorizonPageState extends State<NeonHorizonPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              width: constraints.maxWidth * 0.8,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Color.alphaBlend(Colors.black.withOpacity(0.6), Colors.deepPurple.shade900),
                borderRadius: BorderRadius.all(const Radius.circular(16)),
              ),
              child: NeonHorizon(
                lineColor: Colors.yellow.shade600,
              ),
            ),
          ),
        ),
      );
}

class NeonHorizon extends StatefulWidget {
  const NeonHorizon({
    required this.lineColor,
    this.isAnimating = true,
    Key? key,
  }) : super(key: key);

  final Color lineColor;
  final bool isAnimating;

  @override
  State<NeonHorizon> createState() => _NeonHorizonState();
}

class _NeonHorizonState extends State<NeonHorizon> with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  void onTick(Duration elapsedTime) {}

  @override
  void initState() {
    super.initState();
    ticker = createTicker(onTick);
    if (widget.isAnimating) {
      ticker.start();
    }
  }

  @override
  void didUpdateWidget(NeonHorizon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating  != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        ticker.start();
      } else {
        ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    ticker
      ..stop()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: NeonHorizonPainter(
          primaryColor: Colors.yellow.shade600,
        ),
      );
}

class NeonHorizonPainter extends CustomPainter {
  NeonHorizonPainter({
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintVerticalLine(canvas, size);
    _paintBackground(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          primaryColor.withOpacity(0.15),
          primaryColor.withOpacity(0.4),
        ],
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintVerticalLine(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    const spacing = 30;
    var deltaX = 0;
    while (centerX - deltaX > 0) {
      canvas
        ..drawLine(
          Offset(centerX + deltaX, 0),
          Offset(centerX + 2.5 * deltaX, size.height),
          linePaint,
        )
        ..drawLine(
          Offset(centerX - deltaX, 0),
          Offset(centerX - 2.5 * deltaX, size.height),
          linePaint,
        );

      deltaX += spacing;
    }
  }

  @override
  bool shouldRepaint(NeonHorizonPainter oldDelegate) => primaryColor != oldDelegate.primaryColor;
}
