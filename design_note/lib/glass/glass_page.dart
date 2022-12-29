import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GlassPage extends StatefulWidget {
  const GlassPage({Key? key}) : super(key: key);

  @override
  GlassPageState createState() => GlassPageState();
}

class GlassPageState extends State<GlassPage> {
  Offset? dragStartPosition = null;
  Offset? dragUpdatePosition = null;
  double? orientation = null;

  double navigationWidth = 0;

  double percent = 0;

  double get sigma => 8 * percent;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onHorizontalDragStart: (details) {
              dragStartPosition = details.localPosition;
            },
            onHorizontalDragUpdate: (details) {
              dragUpdatePosition = details.localPosition;
              final dragStartPosition = this.dragStartPosition;
              if (dragStartPosition == null) {
                return;
              }

              orientation ??= details.delta.dx < 0 ? -1 : 1;

              if (orientation! == -1 && dragStartPosition.dx < details.localPosition.dx) {
                return;
              }

              if (orientation! == 1 && dragStartPosition.dx > details.localPosition.dx) {
                return;
              }

              final baseWidth = constraints.maxWidth * 0.6;
              final pecent = (details.localPosition.dx - dragStartPosition.dx).abs().clamp(0, baseWidth) / baseWidth;
              setState(() {
                percent = pecent;
                navigationWidth = (details.localPosition.dx - dragStartPosition.dx).abs();
              });
            },
            onHorizontalDragEnd: (details) {
              dragStartPosition = null;
              dragUpdatePosition = null;
              orientation = null;
            },
            onHorizontalDragCancel: () {
              dragStartPosition = null;
              dragUpdatePosition = null;
              orientation = null;
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                Positioned.fill(
                  child: _SnowsView(
                    screenHeight: constraints.maxHeight.toInt(),
                    screenWidth: constraints.maxWidth.toInt(),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: sigma,
                      sigmaY: sigma,
                    ),
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class DraggingGlassView extends StatelessWidget {
  const DraggingGlassView({
    required this.screenHeight,
    required this.screenWidth,
    Key? key,
  }) : super(key: key);

  final int screenHeight;
  final int screenWidth;

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Container(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
          ),
        ),
      );
}

class _SnowsView extends StatefulWidget {
  const _SnowsView({
    required this.screenWidth,
    required this.screenHeight,
    Key? key,
  }) : super(key: key);

  final int screenWidth;
  final int screenHeight;

  @override
  State<_SnowsView> createState() => _SnowsViewState();
}

class _SnowsViewState extends State<_SnowsView> with SingleTickerProviderStateMixin {
  late final _SnowsController _snowsController;
  Ticker? _ticker;
  Duration? _prevElapsed = null;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _snowsController = _SnowsController(screenWidth: widget.screenWidth, screenHeight: widget.screenHeight);
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
  Widget build(BuildContext context) => CustomPaint(
        painter: _SnowsPainter(
          snows: _snowsController.snows,
        ),
      );
}

class _SnowsPainter extends CustomPainter {
  _SnowsPainter({
    required this.snows,
  });

  final Paint snowPaint = Paint()..color = Colors.white;

  final List<_Snow> snows;

  @override
  void paint(Canvas canvas, Size size) {
    for (final snow in snows) {
      _drawSnow(canvas, snow);
    }
  }

  void _drawSnow(Canvas canvas, _Snow snow) {
    snowPaint..color = Colors.white.withOpacity(snow.opacity);
    // ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1.0);
    canvas.drawCircle(Offset(snow.x, snow.y), snow.size, snowPaint);
  }

  @override
  bool shouldRepaint(covariant _SnowsPainter oldDelegate) => true; // 毎回snowインスタンスが変わるはずなため
}

class _SnowsController {
  _SnowsController({
    required this.screenWidth,
    required this.screenHeight,
  });

  final snowsCount = 500;
  final int screenWidth;
  final int screenHeight;
  final List<_Snow> snows = [];
  final List<_Snow> queueSnows = [];

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

  _Snow _createSnow() => _Snow(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      )..reset();
}

class _Snow {
  _Snow({
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
