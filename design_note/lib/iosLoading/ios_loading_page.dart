import 'dart:math';

import 'package:flutter/material.dart';

// 形を描く
// 0 360で天が動くように
// 点に近いものから色を徐々に薄くする処理をする

class IosLoadingPage extends StatefulWidget {
  const IosLoadingPage({Key? key}) : super(key: key);

  @override
  IosLoadingPageState createState() => IosLoadingPageState();
}

class IosLoadingPageState extends State<IosLoadingPage> with SingleTickerProviderStateMixin {
  late final AnimationController loadingAnimationController;

  @override
  void initState() {
    super.initState();
    loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: loadingAnimationController,
            builder: (context, child) => CustomPaint(
              size: const Size(70, 70),
              painter: IosLoadingPainter(
                progress: loadingAnimationController.value,
              ),
            ),
          ),
        ),
      );
}

class IosLoadingPainter extends CustomPainter {
  IosLoadingPainter({
    required this.progress,
    this.barCount = 8,
    this.barWidth = 7,
    this.innerRadiusPercent = 0.5,
    this.loadingColor = Colors.grey,
  });

  final double progress;
  final int barCount;
  final double barWidth;
  final Color loadingColor;
  final double innerRadiusPercent;

  @override
  void paint(Canvas canvas, Size size) {
    final loadingPaint = Paint()
      ..color = loadingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final outerRadius = min(size.height, size.width) / 2;
    final innerRadius = outerRadius * innerRadiusPercent;
    final center = size.center(Offset.zero);

    const offesetRadians = pi / 8;
    final mostHightBarIndex = (progress * barCount).floor();
    for (var i = 0; i < barCount; i++) {
      final radians = (2 * pi * i / barCount) + offesetRadians;
      final start = center +
          Offset(
            cos(radians) * innerRadius,
            sin(radians) * innerRadius,
          );
      final end = center +
          Offset(
            cos(radians) * outerRadius,
            sin(radians) * outerRadius,
          );
      final distanceFromMostToI = ((mostHightBarIndex - i) + barCount) % barCount;
      loadingPaint.color = loadingColor.withOpacity(
        Tween<double>(begin: 0.3, end: 1).transform(distanceFromMostToI / barCount),
      );
      canvas.drawLine(start, end, loadingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => this != oldDelegate;
}
