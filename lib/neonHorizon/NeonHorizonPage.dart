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
  final List<Duration> addedLineTimes = [];
  List<double> distancePercents = [];
  final animationDuration = Duration(seconds: 3);

  void onTick(Duration elapsedTime) {
    final latestAddVerticalLIneTime = addedLineTimes.isEmpty ? null : addedLineTimes.last;
    if (latestAddVerticalLIneTime == null) {
      addedLineTimes.add(elapsedTime);
    }

    if (latestAddVerticalLIneTime != null &&
        (elapsedTime.inMilliseconds - latestAddVerticalLIneTime.inMilliseconds) >
            const Duration(milliseconds: 500).inMilliseconds) {
      addedLineTimes.add(elapsedTime);
    }

    setState(() {
      distancePercents = addedLineTimes
          .map((lineTime) => (elapsedTime.inMilliseconds - lineTime.inMilliseconds) / animationDuration.inMilliseconds)
          .where((element) => element <= 1.0)
          .toList();
    });
  }

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
    if (widget.isAnimating != oldWidget.isAnimating) {
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
          distancePercents: distancePercents,
        ),
      );
}

class NeonHorizonPainter extends CustomPainter {
  NeonHorizonPainter({
    required this.primaryColor,
    required this.distancePercents,
  });

  final Color primaryColor;
  final List<double> distancePercents;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2;

    _paintVerticalLine(canvas, size, linePaint);
    _paintBackground(canvas, size);

    for (final percent in distancePercents) {
      final y = size.height * (1 - percent);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
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

  void _paintVerticalLine(Canvas canvas, Size size, Paint linePaint) {
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
  bool shouldRepaint(NeonHorizonPainter oldDelegate) =>
      primaryColor != oldDelegate.primaryColor || distancePercents != oldDelegate.distancePercents;
}
