import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class Processing extends StatefulWidget {
  const Processing({
    required this.sketch,
    Key? key,
  }) : super(key: key);

  final Sketch sketch;

  @override
  State<Processing> createState() => _ProcessingState();
}

class _ProcessingState extends State<Processing> with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  void _handleTicker(Duration elapsed) {
    setState(() {});
    widget.sketch._elapsedTime = elapsed;
  }

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_handleTicker)..start();
    widget.sketch._loop = _loop;
    widget.sketch._noLoop = _noLoop;
  }

  @override
  void didUpdateWidget(covariant Processing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      oldWidget.sketch._loop = null;
      oldWidget.sketch._noLoop = null;
      widget.sketch._loop = _loop;
      widget.sketch._noLoop = _noLoop;

      _noLoop();
      if (widget.sketch.isLooping) {
        _loop();
      }
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void _loop() {
    ticker.start();
  }

  void _noLoop() {
    ticker.stop();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(widget.sketch._desiredWidth, widget.sketch._desiredHeight),
        painter: _SketchPainter(
          sketch: widget.sketch,
        ),
      );
}

class Sketch {
  Sketch.simple({
    Function(Sketch)? setup,
    Function(Sketch)? draw,
  })  : _setup = setup,
        _draw = draw;

  late Canvas _canvas;

  late Size _size;

  final Function(Sketch)? _setup;

  final Function(Sketch)? _draw;

  late Paint _fillPaint;

  late Paint _strokePaint;

  Color _backgroundColor = const Color(0xffC5C5C5);

  Random _random = Random();

  bool _hasSetup = false;

  Duration _elapsedTime = Duration.zero;

  int _frameCount = 0;

  int get frameCount => _frameCount;

  int _actualFrameRate = 10;

  int get frameRate => _actualFrameRate;

  Duration desiredFrameTimeInMilliseconds = Duration(milliseconds: (1000 / 60).floor());

  set frameRate(int value) {
    desiredFrameTimeInMilliseconds = Duration(milliseconds: (1000 / value).floor());
  }

  Duration? _lastDrawTime;

  double _desiredWidth = 100;

  double _desiredHeight = 100;

  int get width => _size.width.toInt();

  int get height => _size.height.toInt();

  bool isLooping = false;

  VoidCallback? _loop;

  VoidCallback? _noLoop;

  void loop() {
    isLooping = true;
    _loop?.call();
  }

  void noLoop() {
    isLooping = false;
    _noLoop?.call();
  }

  void _doOnSetup() {
    if (_hasSetup) {
      return;
    }
    _hasSetup = true;

    setup();

    _fillPaint = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.fill;
    _strokePaint = Paint()
      ..color = const Color(0xff000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
  }

  void setup() {
    _setup?.call(this);
  }

  void _doOnDraw() {
    background(color: _backgroundColor);
    final lastDrawTime = _lastDrawTime;
    if (lastDrawTime != null) {
      if (_elapsedTime - lastDrawTime < desiredFrameTimeInMilliseconds) {
        return;
      }
    }

    draw();

    _frameCount++;
    _lastDrawTime = _elapsedTime;
    final secondsFraction = _elapsedTime.inMilliseconds / 1000;
    _actualFrameRate = secondsFraction > 0 ? (frameCount / secondsFraction).round() : _actualFrameRate;
  }

  void draw() {
    _draw?.call(this);
  }

  void size({
    required double width,
    required double height,
  }) {
    _desiredWidth = width;
    _desiredHeight = height;
  }

  void translate({
    required double x,
    required double y,
  }) {
    _canvas.translate(x, y);
  }

  void background({
    required Color color,
  }) {
    final paint = Paint()..color = color;
    _backgroundColor = color;
    _canvas.drawRect(Offset.zero & _size, paint);
  }

  void fill({
    required Color color,
  }) {
    _fillPaint.color = color;
  }

  void noFill() {
    _fillPaint.color = const Color(0x00000000);
  }

  void stroke({
    required Color color,
  }) {
    _strokePaint.color = color;
  }

  void noStroke() {
    _strokePaint.color = const Color(0x00000000);
  }

  void point({
    required double x,
    required double y,
  }) {
    _canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y), width: 1, height: 1),
      _strokePaint,
    );
  }

  void line(
    Offset p1,
    Offset p2,
  ) {
    _canvas.drawLine(p1, p2, _strokePaint);
  }

  void circle({
    required Offset center,
    required double diameter,
  }) {
    _canvas
      ..drawCircle(center, diameter / 2, _fillPaint)
      ..drawCircle(center, diameter / 2, _strokePaint);
  }

  void ellipse({
    required Ellipse ellipse,
  }) {
    _canvas
      ..drawOval(ellipse.rect, _fillPaint)
      ..drawOval(ellipse.rect, _strokePaint);
  }

  void arc({
    required Ellipse ellipse,
    required double startAngle,
    required double endAngle,
    ArcMode arcMode = ArcMode.openStrokePiFill,
  }) {
    switch (arcMode) {
      case ArcMode.openStrokePiFill:
        _canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _strokePaint);
        break;
      case ArcMode.open:
        _canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _strokePaint);
        break;
      case ArcMode.chord:
        final chordPath = Path()
          ..addArc(ellipse.rect, startAngle, endAngle - startAngle)
          ..close();
        _canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, false, _fillPaint)
          ..drawPath(chordPath, _strokePaint);
        break;
      case ArcMode.pie:
        _canvas
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _fillPaint)
          ..drawArc(ellipse.rect, startAngle, endAngle - startAngle, true, _strokePaint);
        break;
    }
  }

  void square({
    required Square square,
  }) {
    _canvas
      ..drawRect(square.rect, _fillPaint)
      ..drawRect(square.rect, _strokePaint);
  }

  void rect({
    required Rect rect,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    final rrect = RRect.fromLTRBAndCorners(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    _canvas
      ..drawRRect(rrect, _fillPaint)
      ..drawRRect(rrect, _strokePaint);
  }

  void triangle({
    required Offset p1,
    required Offset p2,
    required Offset p3,
  }) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    _canvas
      ..drawPath(path, _fillPaint)
      ..drawPath(path, _strokePaint);
  }

  void quad({
    required Offset p1,
    required Offset p2,
    required Offset p3,
    required Offset p4,
  }) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    _canvas
      ..drawPath(path, _fillPaint)
      ..drawPath(path, _strokePaint);
  }

  void randomSeed(int? seed) {
    _random = Random(seed);
  }

  double random(int bound1, [int? bound2]) {
    final lowerBound = bound2 == null ? 0 : bound1;
    final upperBound = bound2 == null ? bound1 : bound2;

    if (upperBound < lowerBound) {
      throw Exception('Upper bound must be greater than or equal to lower bound');
    }

    return _random.nextDouble() * (upperBound - lowerBound) + lowerBound;
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter({
    required this.sketch,
  });

  final Sketch sketch;

  @override
  void paint(Canvas canvas, Size size) {
    sketch
      .._canvas = canvas
      .._size = size
      .._doOnSetup()
      .._doOnDraw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Square {
  Square.fromLTE({
    required Offset leftTop,
    required double extent,
  }) : _rect = Rect.fromLTWH(
          leftTop.dx,
          leftTop.dy,
          extent,
          extent,
        );

  Square.fromCenter({
    required Offset center,
    required double extent,
  }) : _rect = Rect.fromCenter(
          center: center,
          width: extent,
          height: extent,
        );

  final Rect _rect;

  Rect get rect => _rect;
}

class Ellipse {
  Ellipse.fromLTWH({
    required Offset leftTop,
    required double width,
    required double height,
  }) : _rect = Rect.fromLTWH(
          leftTop.dx,
          leftTop.dy,
          width,
          height,
        );

  Ellipse.fromLTRB({
    required Offset leftTop,
    required Offset rightBottom,
  }) : _rect = Rect.fromLTRB(
          leftTop.dx,
          leftTop.dy,
          rightBottom.dx,
          rightBottom.dy,
        );

  Ellipse.fromCenter({
    required Offset center,
    required double width,
    required double height,
  }) : _rect = Rect.fromCenter(
          center: center,
          width: width,
          height: height,
        );

  Ellipse.fromCenterWithRadius({
    required Offset center,
    required double radiusX,
    required double radiusY,
  }) : _rect = Rect.fromCenter(
          center: center,
          width: radiusX * 2,
          height: radiusY * 2,
        );

  final Rect _rect;

  Rect get rect => _rect;
}

enum ArcMode {
  openStrokePiFill,
  chord,
  open,
  pie,
}
