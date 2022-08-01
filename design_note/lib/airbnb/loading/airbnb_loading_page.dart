import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AirbnbLoadingPage extends StatefulWidget {
  const AirbnbLoadingPage({Key? key}) : super(key: key);

  @override
  State<AirbnbLoadingPage> createState() => _AirbnbLoadingPageState();
}

class _AirbnbLoadingPageState extends State<AirbnbLoadingPage> with SingleTickerProviderStateMixin {
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
                painter: _AirbnbLoadingPainter(
                  percent: _loadingAnimationController.drive(CurveTween(curve: Curves.linear)).value,
                ),
                size: const Size(100, 100),
              ),
            ),
          ),
        ),
      );
}

class _AirbnbLoadingPainter extends CustomPainter {
  _AirbnbLoadingPainter({
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
      canvas.drawCircle(
        start + Offset((radius / 2 + space) * i, 5 * sin(2 * pi * percent - offset * i)),
        radius,
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AirbnbLoadingPainter oldDelegate) => percent != oldDelegate.percent;
}
