import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AirbnbFadeLoadingPage extends StatefulWidget {
  const AirbnbFadeLoadingPage({Key? key}) : super(key: key);

  @override
  State<AirbnbFadeLoadingPage> createState() => _AirbnbFadeLoadingPageState();
}

class _AirbnbFadeLoadingPageState extends State<AirbnbFadeLoadingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _loadingAnimationController;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: Center(
            child: AnimatedBuilder(
              animation: _loadingAnimationController,
              builder: (context, child) => CustomPaint(
                painter: _AirbnbFadeLoadingPainter(
                  percent: _loadingAnimationController.drive(CurveTween(curve: Curves.linear)).value,
                ),
                size: const Size(100, 100),
              ),
            ),
          ),
        ),
      );
}

class _AirbnbFadeLoadingPainter extends CustomPainter {
  _AirbnbFadeLoadingPainter({
    required this.percent,
  });

  final double percent;
  final double radius = 5;
  final double space = 14;
  final double offset = pi / 3;
  final Paint _paint = Paint()..color = Colors.grey.shade900;

  @override
  void paint(Canvas canvas, Size size) {
    final start = size.center(Offset.zero) - Offset(space + radius / 2, 0);
    for (var i = 0; i < 3; i++) {
      final opacity = lerpDouble(0.72, 1.0, sin(2 * pi * (percent - i * 0.3)))!;
      final _radius = radius * lerpDouble(0.98, 1.0, sin(2 * pi * (percent - i * 0.3)))!;
      canvas.drawCircle(
        start + Offset((radius / 2 + space) * i, 0),
        _radius,
        _paint..color = _paint.color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AirbnbFadeLoadingPainter oldDelegate) => percent != oldDelegate.percent;
}
