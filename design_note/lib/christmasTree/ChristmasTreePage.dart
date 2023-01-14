import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChristmasTreePage extends StatefulWidget {
  const ChristmasTreePage({Key? key}) : super(key: key);

  @override
  ChristmasTreePageState createState() => ChristmasTreePageState();
}

final treeRingAngle = pi * 0.6;
final backgroundColor = Colors.blueGrey.shade900;
final colors = [
  Colors.red.shade300,
  Colors.yellow.shade300,
  Colors.green.shade300,
  Colors.blue.shade300,
  Colors.purple.shade300,
];

class ChristmasTreePageState extends State<ChristmasTreePage> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  final ringCount = 10;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final treeHeight = constraints.maxHeight * 0.6;
              return Container(
                height: treeHeight,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) => Column(
                    children: [
                      StarView(size: 40),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...List.generate(ringCount, (index) => ringCount - index - 1).map(
                            (index) {
                              final mexRingWidth = (constraints.maxWidth * 0.6);
                              final ringWidth = lerpDouble(20, constraints.maxWidth * 0.6, index / ringCount)!;
                              final ringOffset = lerpDouble(0, treeHeight - mexRingWidth / 2 * sin(treeRingAngle),
                                  Curves.easeOut.transform(index / ringCount))!;
                              return Transform.translate(
                                offset: Offset(0, ringOffset),
                                child: TreeRing(
                                  index: index,
                                  value: animationController.value,
                                  size: Size.square(ringWidth),
                                  offset: index % colors.length,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
}

// 回すようにする
// iconを載せる
class TreeRing extends StatelessWidget {
  const TreeRing({
    required this.index,
    required this.value,
    required this.size,
    required this.offset,
    this.starSize = 20,
    Key? key,
  }) : super(key: key);

  final int index;
  final double value;
  final Size size;
  final int offset;
  final double starSize;

  int get starCount => index;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Transform(
            transform: Matrix4.rotationX(treeRingAngle)
              ..multiply(
                Matrix4.rotationZ(2 * pi * value),
              ),
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: List.generate(
                        colors.length,
                        (index) => colors[(offset + index) % colors.length].withOpacity(0.9),
                      ),
                    ),
                    width: 6,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Transform(
              transform: Matrix4.rotationX(treeRingAngle)
                ..multiply(
                  Matrix4.rotationZ(2 * pi * value),
                ),
              alignment: Alignment.center,
              child: Stack(
                children: [
                  ...List.generate(
                    starCount,
                    (index) => Transform.translate(
                      offset: Offset(
                        size.center(Offset.zero).dx +
                            0.6 * size.width * cos(2 * pi * index / starCount + offset * 0.08 * pi),
                        size.center(Offset.zero).dx +
                            0.6 * size.height * sin(2 * pi * index / starCount + offset * 0.08 * pi),
                      ),
                      child: const StarView(size: 24),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      );
}

class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  final Gradient gradient;
  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    switch (shape) {
      case BoxShape.circle:
        assert(borderRadius == null, 'A borderRadius can only be given for rectangular boxes.');
        _paintCircle(canvas, rect);
        break;
      case BoxShape.rectangle:
        break;
    }
  }

  void _paintCircle(Canvas canvas, Rect rect) {
    final paint = _getPaint(rect);
    final radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  ShapeBorder scale(double t) => this;

  Paint _getPaint(Rect rect) => Paint()
    ..strokeWidth = width
    ..shader = gradient.createShader(rect)
    ..style = PaintingStyle.stroke;
}

class StarView extends StatelessWidget {
  const StarView({
    required this.size,
    Key? key,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StarPainter(
          starSize: size.toInt(),
          startColor: Colors.yellow,
        ),
        size: Size(size, size),
      );
}

class StarPainter extends CustomPainter {
  StarPainter({
    required this.starSize,
    required this.startColor,
  });

  final Color startColor;
  final int starSize;

  late final startPaint = Paint()
    ..color = startColor
    ..maskFilter = MaskFilter.blur(BlurStyle.solid, 12);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..extendWithPath(
        createStarPath(starSize),
        size.center(Offset.zero),
      );
    canvas.drawPath(path, startPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Path createStarPath(int size) {
  final starPath = Path();
  final outerCircleRadius = size * 0.5;
  final innerCircleRadius = outerCircleRadius * 0.4;
  const starPointAngleUnit = 2 * pi / 10;
  const baseAngle = -pi / 2;
  starPath.moveTo(outerCircleRadius * cos(baseAngle), outerCircleRadius * sin(baseAngle));
  for (final i in List.generate(10, (index) => index + 1)) {
    final radius = i.isEven ? outerCircleRadius : innerCircleRadius;
    starPath.lineTo(
      radius * cos(baseAngle - starPointAngleUnit * i),
      radius * sin(baseAngle - starPointAngleUnit * i),
    );
  }
  return starPath;
}
