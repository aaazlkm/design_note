import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

class FloatingStars extends StatefulWidget {
  const FloatingStars({Key? key}) : super(key: key);

  @override
  State<FloatingStars> createState() => _FloatingStarsState();
}

class _FloatingStarsState extends State<FloatingStars> with SingleTickerProviderStateMixin {
  late final StarSystem startSystem;
  late final Ticker ticker;
  Duration? _previousFrameTime = null;

  void onTick(Duration elapsedTime) {
    _previousFrameTime = elapsedTime;
  }

  @override
  void initState() {
    super.initState();
    startSystem = StarSystem(maxStarCount: 50);
    ticker = createTicker(onTick);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 500,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.yellow.shade700,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: CustomPaint(
            painter: SystemStarsPainter(
              starSystem: startSystem,
            ),
            size: Size.infinite,
          ),
        ),
      );
}

class SystemStarsPainter extends CustomPainter {
  SystemStarsPainter({
    required this.starSystem,
  });

  final StarSystem starSystem;

  @override
  void paint(Canvas canvas, Size size) {
    starSystem.init(size);

    starSystem.stars.forEach((star) {
      final starPaint = Paint()..color = star.color;
      final starTemplate = StarTemplate(
        outerRadius: star.radius,
        innerRadius: star.radius * 0.5,
      );

      canvas
        ..save()
        ..translate(star.position.dx, star.position.dy)
        ..rotate(star.rotation)
        ..drawPath(starTemplate.toPath(), starPaint)
        ..restore();
    });
  }

  @override
  bool shouldRepaint(covariant SystemStarsPainter oldDelegate) => starSystem != oldDelegate.starSystem;
}

class StarSystem {
  StarSystem({
    required this.maxStarCount,
  });

  bool _isInitialized = false;
  final int maxStarCount;
  final List<StarParticle> stars = [];

  void init(Size worldSize) {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    final random = Random();
    for (var i = 0; i < maxStarCount; i++) {
      stars.add(
        StarParticle(
          position: Offset(
            random.nextDouble() * worldSize.width,
            random.nextDouble() * worldSize.height,
          ),
          radius: lerpDouble(10.0, 30.0, random.nextDouble())!,
          color: Color.lerp(
            Colors.yellow.shade300,
            Colors.yellow.shade700,
            random.nextDouble(),
          )!,
          rotation: lerpDouble(0, 2 * pi, random.nextDouble())!,
        ),
      );
    }
  }
}

class StarParticle {
  StarParticle({
    required this.position,
    required this.radius,
    required this.color,
    this.velocity = Offset.zero,
    this.rotation = 0,
    this.radialVelocity = 0,
  });

  final Offset position;
  final double radius;
  final Color color;
  final Offset velocity;
  final double rotation;
  final double radialVelocity;

  void onTick(Duration elapsedTime) {
    // TODO
  }
}

class StarTemplate {
  StarTemplate({
    required this.outerRadius,
    required this.innerRadius,
    this.pointCount = 5,
  });

  final double outerRadius;
  final double innerRadius;
  final double pointCount;

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
