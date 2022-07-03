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
  }

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_handleTicker)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
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

  late final Canvas _canvas;

  late final Size _size;

  final Function(Sketch)? _setup;

  final Function(Sketch)? _draw;

  late Paint _fillPaint;

  late Paint _strokePaint;

  Random _random = Random();

  bool hasSetup = false;

  void _doOnSetup(Canvas canvas, Size size) {
    if (hasSetup) {
      return;
    }
    hasSetup = true;
    _canvas = canvas;
    _size = size;

    background(color: const Color(0xffC5C5C5));
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

  void draw() {
    _draw?.call(this);
  }

  void background({
    required Color color,
  }) {
    final paint = Paint()..color = color;
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
      .._doOnSetup(canvas, size)
      ..draw();
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
