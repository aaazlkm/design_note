import 'package:flutter/widgets.dart';

class Processing extends StatelessWidget {
  const Processing({
    required this.sketch,
    Key? key,
  }) : super(key: key);

  final Sketch sketch;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.infinite,
        painter: _SketchPainter(
          sketch: sketch,
        ),
      );
}

class Sketch {
  Sketch.simple({
    Function(Sketch)? setup,
    Function(Sketch)? draw,
  })  : _setup = setup,
        _draw = draw;

  final Function(Sketch)? _setup;

  final Function(Sketch)? _draw;

  void setup() {
    _setup?.call(this);
  }

  void draw() {
    _draw?.call(this);
  }

  late final Canvas canvas;

  late final Size size;

  void background({
    required Color color,
  }) {
    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
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
      ..canvas = canvas
      ..size = size
      ..setup()
      ..draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}