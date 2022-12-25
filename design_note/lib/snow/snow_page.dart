import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SnowPage extends StatefulWidget {
  const SnowPage({Key? key}) : super(key: key);

  @override
  SnowPageState createState() => SnowPageState();
}

class SnowPageState extends State<SnowPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.blueGrey.shade900,
                ),
              ),
              Positioned.fill(
                child: SnowsView(
                  screenWidth: constraints.maxWidth.toInt(),
                  screenHeight: constraints.maxHeight.toInt(),
                ),
              ),
            ],
          ),
        ),
      );
}

class SnowsView extends StatefulWidget {
  const SnowsView({
    required this.screenWidth,
    required this.screenHeight,
    Key? key,
  }) : super(key: key);

  final int screenWidth;
  final int screenHeight;

  @override
  State<SnowsView> createState() => _SnowsViewState();
}

class _SnowsViewState extends State<SnowsView> with SingleTickerProviderStateMixin {
  late final SnowsController _snowsController;
  Ticker? _ticker;
  Duration? _prevElapsed = null;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _snowsController = SnowsController(screenWidth: widget.screenWidth, screenHeight: widget.screenHeight);
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _prevElapsed ??= elapsed;
    setState(() {
      _snowsController.move(elapsed - _prevElapsed!);
    });
    _prevElapsed = elapsed;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          final timeAt = _prevElapsed;
          if (timeAt == null) {
            return;
          }
          // TODO フリックで雪の向きを変えたい...
        },
        child: CustomPaint(
          painter: SnowsPainter(
            snows: _snowsController.snows,
          ),
        ),
      );
}

class SnowsPainter extends CustomPainter {
  SnowsPainter({
    required this.snows,
  });

  final Paint snowPaint = Paint()..color = Colors.white;

  final List<Snow> snows;

  @override
  void paint(Canvas canvas, Size size) {
    for (final snow in snows) {
      _drawSnow(canvas, snow);
    }
  }

  void _drawSnow(Canvas canvas, Snow snow) {
    snowPaint..color = Colors.white.withOpacity(snow.opacity);
    // ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1.0);
    canvas.drawCircle(Offset(snow.x, snow.y), snow.size, snowPaint);
  }

  @override
  bool shouldRepaint(covariant SnowsPainter oldDelegate) => true; // 毎回snowインスタンスが変わるはずなため
}

class SnowsController {
  SnowsController({
    required this.screenWidth,
    required this.screenHeight,
  });

  final snowsCount = 500;
  final int screenWidth;
  final int screenHeight;
  final List<Snow> snows = [];
  final List<Snow> queueSnows = [];

  void move(Duration elapsed) {
    final sub = snowsCount - snows.length;
    if (sub != 0) {
      for (var _ in List.generate(sub, (index) => index)) {
        final snow = queueSnows.isNotEmpty ? queueSnows.removeAt(0) : _createSnow()
          ..y = screenHeight * Random().nextDouble();
        snows.add(snow);
      }
    }

    final elapsedInSeconds = elapsed.inMilliseconds / 1000;
    for (final snow in snows) {
      snow.move(elapsedInSeconds);
    }
  }

  Snow _createSnow() => Snow(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      )..reset();
}

class Snow {
  Snow({
    required this.screenWidth,
    required this.screenHeight,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
    this.vX = 0.0,
    this.vY = 0.0,
    this.vZ = 0.0,
    this.horizontalOrientation = 0,
    this.defaultSize = 0,
    this.defaultOpacity = 0,
  });

  final int screenWidth;
  final int screenHeight;

  double x;
  double y;

  // 0 - 1
  // 大きさと色の薄さを決める
  double z;

  double vX;
  double vY;
  double vZ;

  // -1 or 1
  double horizontalOrientation;

  double defaultSize;
  double defaultOpacity;

  double get size => defaultSize * z;

  double get opacity => lerpDouble(0.2, 1.0, z)!;

  void move(double elapsedInSeconds) {
    x = x + vX * horizontalOrientation * elapsedInSeconds;
    x = x % screenWidth;
    y = y + vY * elapsedInSeconds;

    if (y > screenHeight + 50) {
      reset();
    }
  }

  void reset() {
    x = screenWidth * Random().nextDouble();
    y = -20;
    z = Random().nextDouble();
    vX = lerpDouble(1, 20, Random().nextDouble())!;
    vY = lerpDouble(20, 80, Random().nextDouble())!;
    vZ = Random().nextDouble();
    horizontalOrientation = Random().nextBool() ? 1 : -1;
    defaultSize = lerpDouble(1, 5, Random().nextDouble())!;
    defaultOpacity = lerpDouble(0.8, 1.0, Random().nextDouble())!;
  }
}

// 色 -> z *
