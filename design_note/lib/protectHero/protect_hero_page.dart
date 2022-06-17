import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ProtectHeroPage extends StatefulWidget {
  const ProtectHeroPage({Key? key}) : super(key: key);

  @override
  ProtectHeroPageState createState() => ProtectHeroPageState();
}

class ProtectHeroPageState extends State<ProtectHeroPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: ProtectHero(
                protectStatus: ProtectStatus.emergency,
              ),
            ),
          ),
        ),
      );
}

enum ProtectStatus {
  offline,
  idle,
  warning,
  emergency,
}

class GlowConfig {
  factory GlowConfig.fromStatus(ProtectStatus status) {
    switch (status) {
      case ProtectStatus.offline:
        return GlowConfig._();
      case ProtectStatus.idle:
        return GlowConfig._(
          primaryGlowColor: _idlePrimaryGlowColorBase,
          secondaryGlowColor: _idleSecondaryGlowColorBase,
        );
      case ProtectStatus.warning:
        return GlowConfig._(
          primaryGlowColor: _warningPrimaryGlowColorBase,
          secondaryGlowColor: _warningSecondaryGlowColorBase,
          pulsePeriod: const Duration(milliseconds: 3000),
        );
      case ProtectStatus.emergency:
        return GlowConfig._(
          primaryGlowColor: _emergencyPrimaryGlowColorBase,
          secondaryGlowColor: _emergencySecondaryGlowColorBase,
          pulsePeriod: const Duration(milliseconds: 1500),
        );
    }
  }

  GlowConfig._({
    this.primaryGlowColor,
    this.secondaryGlowColor,
    this.pulsePeriod,
  });

  static const Color _idlePrimaryGlowColorBase = Colors.lightGreen;
  static const Color _idleSecondaryGlowColorBase = Colors.lightGreenAccent;
  static const Color _warningPrimaryGlowColorBase = Colors.yellow;
  static const Color _warningSecondaryGlowColorBase = Colors.yellowAccent;
  static const Color _emergencyPrimaryGlowColorBase = Colors.red;
  static const Color _emergencySecondaryGlowColorBase = Colors.redAccent;

  final Color? primaryGlowColor;
  final Color? secondaryGlowColor;
  final Duration? pulsePeriod;

  bool get isPulsing => pulsePeriod != null;

  bool get isGlowing => primaryGlowColor != null && secondaryGlowColor != null;
}

class ProtectHero extends StatefulWidget {
  ProtectHero({
    required this.protectStatus,
    Key? key,
  }) : super(key: key);

  final ProtectStatus protectStatus;

  @override
  _ProtectHeroState createState() => _ProtectHeroState();
}

class _ProtectHeroState extends State<ProtectHero> with SingleTickerProviderStateMixin {
  final double maxGlowOpacity = 1.0;
  final double minGlowOpacity = 0.2;

  late final AnimationController glowAnimationController;
  GlowConfig? glowConfig;

  @override
  void initState() {
    super.initState();
    glowAnimationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          glowAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          glowAnimationController.forward();
        }
      });
    _configureGlowConfig();
  }

  @override
  void didUpdateWidget(ProtectHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.protectStatus != oldWidget.protectStatus) {
      _configureGlowConfig();
    }
  }

  @override
  void dispose() {
    glowAnimationController.dispose();
    super.dispose();
  }

  void _configureGlowConfig() {
    final _glowConfig = GlowConfig.fromStatus(widget.protectStatus);
    glowConfig = _glowConfig;
    if (_glowConfig.isPulsing) {
      glowAnimationController.duration = _glowConfig.pulsePeriod;
      if (!glowAnimationController.isAnimating) {
        glowAnimationController.forward();
      }
    } else {
      glowAnimationController
        ..stop()
        ..value = 0;
    }
  }

  Color? primaryColor() => glowConfig?.primaryGlowColor?.withOpacity(glowOpacity());

  Color? secondaryColor() => glowConfig?.secondaryGlowColor?.withOpacity(glowOpacity());

  double glowOpacity() {
    final glowConfig = this.glowConfig!;
    if (!glowConfig.isGlowing) {
      return 0.0;
    } else if (!glowConfig.isPulsing) {
      return 1.0;
    } else {
      return lerpDouble(maxGlowOpacity, minGlowOpacity, glowAnimationController.value)!;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: glowAnimationController,
        builder: (context, child) => CustomPaint(
          size: Size.infinite,
          painter: ProtectPatternPainter(
            primaryColor: primaryColor(),
            secondaryColor: secondaryColor(),
          ),
        ),
      );
}

class ProtectPatternPainter extends CustomPainter {
  ProtectPatternPainter({
    this.primaryColor,
    this.secondaryColor,
  })  : primaryGlowPaint = Paint()..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2, tileMode: TileMode.decal),
        secondaryGlowPaint = Paint()..imageFilter = ImageFilter.blur(sigmaX: 15, sigmaY: 15, tileMode: TileMode.decal) {
    if (primaryColor != null && secondaryColor != null) {
      primaryGlowPaint.color = primaryColor!;
      secondaryGlowPaint.color = secondaryColor!;
    }
  }

  final double centerRingToDotsGap = 20;
  final ringGap = 7;
  final double dotsPerRing = 64;
  final double startDotRadius = 2.5;
  final double endDotRadius = 5;
  final double startDotOpacity = 0.08;
  final double endDotOpacity = 0.005;
  final Paint dotPaint = Paint()..color = Colors.black.withOpacity(0.08);
  final Paint shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.4)
    ..imageFilter = ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.decal);
  final double primaryGlowThickness = 6;
  final double secondaryGlowThickness = 7;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Paint primaryGlowPaint;
  final Paint secondaryGlowPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final ringCenter = size.center(Offset.zero);
    final centerCircleRadius = size.width / 6;

    drawGlowAndShadow(
      canvas: canvas,
      drawableArea: size,
      ringRadius: centerCircleRadius,
    );

    final firstRingRadius = centerCircleRadius + centerRingToDotsGap;
    final finalRingRadius = size.width / 2;
    final ringCount = ((finalRingRadius - firstRingRadius) / ringGap).floor();

    for (var i = 0; i < ringCount; ++i) {
      final halfDotRotation = (2 * pi / dotsPerRing) / 2;
      final ringRadius = firstRingRadius + i * ringGap;
      final ringPercent = i / ringCount;
      drawDotRing(
        canvas: canvas,
        ringCenter: ringCenter,
        ringRadius: ringRadius,
        centerCircleRadius: centerCircleRadius,
        dotRadius: lerpDouble(startDotRadius, endDotRadius, ringPercent) ?? startDotRadius,
        dotOpacity: lerpDouble(startDotOpacity, endDotOpacity, ringPercent) ?? startDotOpacity,
        ringRotation: i.isEven ? halfDotRotation : 0,
      );
    }
  }

  void drawGlowAndShadow({
    required Canvas canvas,
    required Size drawableArea,
    required double ringRadius,
  }) {
    final center = drawableArea.center(Offset.zero);
    final maskPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, drawableArea.width, drawableArea.height))
      ..addOval(Rect.fromCircle(center: center, radius: ringRadius))
      ..fillType = PathFillType.evenOdd;

    canvas
      ..clipPath(maskPath)
      ..drawCircle(center, ringRadius, shadowPaint);

    if (primaryColor != null && secondaryColor != null) {
      canvas
        ..drawCircle(center, ringRadius + secondaryGlowThickness, secondaryGlowPaint)
        ..drawCircle(center, ringRadius + primaryGlowThickness, primaryGlowPaint);
    }
  }

  void drawDotRing({
    required Canvas canvas,
    required Offset ringCenter,
    required double ringRadius,
    required double centerCircleRadius,
    required double ringRotation,
    required double dotRadius,
    required double dotOpacity,
  }) {
    final deltaAngle = 2 * pi / dotsPerRing;
    final dotCirclePath = Path();
    for (var i = 0; i < dotsPerRing; ++i) {
      dotCirclePath.addOval(
        Rect.fromCircle(
          center: ringCenter + _rotateVector(Offset(0, -ringRadius), deltaAngle * i + ringRotation),
          radius: dotRadius,
        ),
      );
    }
    canvas.drawPath(dotCirclePath, Paint()..color = dotPaint.color.withOpacity(dotOpacity));
  }

  Offset _rotateVector(Offset vector, double angleInRadians) => Offset(
        cos(angleInRadians) * vector.dx - sin(angleInRadians) * vector.dy,
        sin(angleInRadians) * vector.dx - cos(angleInRadians) * vector.dy,
      );

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
