import 'dart:math';

import 'package:flutter/material.dart';

class StarbucksStartsPage extends StatefulWidget {
  const StarbucksStartsPage({Key? key}) : super(key: key);

  @override
  StarbucksStartsPageState createState() => StarbucksStartsPageState();
}

class StarbucksStartsPageState extends State<StarbucksStartsPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: FloatingStars(),
        ),
      );
}

class FloatingStars extends StatelessWidget {
  const FloatingStars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        width: 500,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Center(
          child: CustomPaint(
            painter: SystemStarsPainter(),
            size: Size.infinite,
          ),
        ),
      );
}

class SystemStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.black;
    final center = size.center(Offset.zero);

    const outerRadius = 100;
    const innerRadius = 40;
    var angle = -pi / 2;

    final starPath = Path()
      ..moveTo(
        outerRadius * cos(angle) + center.dx,
        outerRadius * sin(angle) + center.dy,
      );

    angle += (2 * pi) / 10;
    starPath.lineTo(
      innerRadius * cos(angle) + center.dx,
      innerRadius * sin(angle) + center.dy,
    );

    for (var i = 1; i < 5; i++) {
      angle += (2 * pi) / 10;
      starPath.lineTo(
        outerRadius * cos(angle) + center.dx,
        outerRadius * sin(angle) + center.dy,
      );
      angle += (2 * pi) / 10;
      starPath.lineTo(
        innerRadius * cos(angle) + center.dx,
        innerRadius * sin(angle) + center.dy,
      );
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
