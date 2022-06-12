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

    final starTemplate = StarTemplate(
      outerRadius: 100,
      innerRadius: 40,
    );

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..drawPath(starTemplate.toPath(), starPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarTemplate {
  StarTemplate({
    this.pointCount = 6,
    required this.outerRadius,
    required this.innerRadius,
  });

  final double pointCount;
  final double outerRadius;
  final double innerRadius;

  Path toPath() {
    const startAngle = -pi / 2;
    final angleIncrement = 2 * pi / (pointCount * 2);

    final starPath = Path()
      ..moveTo(
        outerRadius * cos(startAngle),
        outerRadius * sin(startAngle),
      );

    for (var i = 1; i < pointCount * 2; i += 2) {
      final innerAngle = i * angleIncrement;
      final outerAngle = (i + 1) * angleIncrement;
      starPath
        ..lineTo(
          innerRadius * cos(startAngle + innerAngle),
          innerRadius * sin(startAngle + innerAngle),
        )
        ..lineTo(
          outerRadius * cos(startAngle + outerAngle),
          outerRadius * sin(startAngle + outerAngle),
        );
    }
    starPath.close();
    return starPath;
  }
}
