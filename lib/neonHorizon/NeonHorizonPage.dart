import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class NeonHorizonPage extends StatefulWidget {
  const NeonHorizonPage({Key? key}) : super(key: key);

  @override
  NeonHorizonPageState createState() => NeonHorizonPageState();
}

class NeonHorizonPageState extends State<NeonHorizonPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              width: constraints.maxWidth * 0.8,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Color.alphaBlend(Colors.black.withOpacity(0.6), Colors.deepPurple.shade900),
                borderRadius: BorderRadius.all(const Radius.circular(16)),
              ),
              child: const NeonHorizon(),
            ),
          ),
        ),
      );
}

class NeonHorizon extends StatefulWidget {
  const NeonHorizon({Key? key}) : super(key: key);

  @override
  State<NeonHorizon> createState() => _NeonHorizonState();
}

class _NeonHorizonState extends State<NeonHorizon> {
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: NeonHorizonPainter(primaryColor: Colors.yellow.shade600),
      );
}

class NeonHorizonPainter extends CustomPainter {
  NeonHorizonPainter({
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          primaryColor.withOpacity(0.15),
          primaryColor.withOpacity(0.4),
        ],
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(NeonHorizonPainter oldDelegate) => primaryColor != oldDelegate.primaryColor;
}
