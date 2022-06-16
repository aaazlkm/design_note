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
    final dt = elapsedTime - (_previousFrameTime ?? elapsedTime);
    startSystem.update(elapsedTime);
    _previousFrameTime = elapsedTime;
  }

  @override
  void initState() {
    super.initState();
    startSystem = StarSystem(maxStarCount: 100);
    ticker = createTicker(onTick)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Container(
          width: constraints.maxWidth * 0.8,
          height: constraints.maxWidth * 0.8 * 0.6,
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
        ),
      );
}

class SystemStarsPainter extends CustomPainter {
  SystemStarsPainter({
    required this.starSystem,
  }) : super(repaint: starSystem);

  final StarSystem starSystem;

  @override
  void paint(Canvas canvas, Size size) {
    starSystem.init(size);

    for (final star in starSystem.stars) {
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
    }
  }

  @override
  bool shouldRepaint(covariant SystemStarsPainter oldDelegate) => starSystem != oldDelegate.starSystem;
}

class StarSystem extends ChangeNotifier {
  StarSystem({
    required this.maxStarCount,
  });

  bool _isInitialized = false;
  final int maxStarCount;
  final List<StarParticle> stars = [];
  late final Size _worldSize;

  void init(Size worldSize) {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _worldSize = worldSize;

    _generateStars(Duration.zero);
  }

  void update(Duration dt) {
    if (!_isInitialized) {
      return;
    }
    _cullOffsetStars();
    _generateStars(dt);
    for (final star in stars) {
      star.update(dt);
    }
    notifyListeners();
  }

  void _cullOffsetStars() {
    if (!_isInitialized) {
      return;
    }
    for (var i = stars.length - 1; i >= 0; i--) {
      if (stars[i].position.dx > _worldSize.width) {
        stars.removeAt(i);
      }
    }
  }

  void _generateStars(Duration dt) {
    if (!_isInitialized) {
      return;
    }
    final random = Random();
    for (var i = 0; i < maxStarCount - stars.length; i++) {
      stars.add(
        StarParticle(
          position: Offset(
            (random.nextDouble() * _worldSize.width * 0.3) - _worldSize.width * 0.3,
            random.nextDouble() * _worldSize.height,
          ),
          radius: lerpDouble(5.0, 20.0, random.nextDouble())!,
          color: Color.lerp(
            Colors.yellow.shade300,
            Colors.yellow.shade700,
            random.nextDouble(),
          )!,
          velocity: lerpDouble(20, 200, random.nextDouble())!,
          acceleration: lerpDouble(20, 200, random.nextDouble())!,
          rotation: lerpDouble(0, 2 * pi, random.nextDouble())!,
          radialVelocity: lerpDouble(0, pi / 8, random.nextDouble())!,
          initializeDurtion: dt,
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
    required this.initializeDurtion,
    this.velocity = 0,
    this.acceleration = 0,
    this.rotation = 0,
    this.radialVelocity = 0,
  });

  Offset position;
  final double radius;
  final Color color;
  final double velocity;
  final double acceleration;
  double rotation;
  final double radialVelocity;
  final Duration initializeDurtion;

  Duration? duration;

  void update(Duration dt) {
    final aaa = dt - initializeDurtion;
    position = Offset(
        (velocity * (aaa.inMilliseconds / 1000)).toDouble() +
            acceleration * pow(aaa.inMilliseconds / 1000, 2).toDouble(),
        position.dy);
    rotation += radialVelocity * (((aaa - (duration ?? aaa)).inMilliseconds) / 1000);
    duration = aaa;
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
