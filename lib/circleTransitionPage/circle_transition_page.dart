import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_animations/simple_animations.dart';

class CircleTransitionPage {
  CircleTransitionPage({required this.backgroundColor});

  final Color backgroundColor;
}

class _CircleTransitionPage extends StatefulWidget {
  const _CircleTransitionPage({Key? key}) : super(key: key);

  @override
  _CircleTransitionPageState createState() => _CircleTransitionPageState();
}

class _CircleTransitionPageState extends State<_CircleTransitionPage> with SingleTickerProviderStateMixin {
  final List<CircleTransitionPage> pages = [
    CircleTransitionPage(backgroundColor: Colors.red),
    CircleTransitionPage(backgroundColor: Colors.yellow),
    CircleTransitionPage(backgroundColor: Colors.blue),
  ];

  double transitionPercent = 0;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    transitionPercent = 0;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
      ..addListener(() {
        setState(() {
          transitionPercent = _animationController.value;
        });
      })
      ..addStatusListener((status) {
        setState(() {});
        if (status == AnimationStatus.completed) {
          _animationController.forward(from: 0);
        }
      });
    // _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: AnimationDeveloperTools(
            child: PlayAnimation<double>(
              tween: Tween<double>(begin: 0.0, end: 1),
              duration: const Duration(milliseconds: 1500),
              developerMode: true, // enable developer mode
              builder: (context, child, value) => CustomPaint(
                size: Size.infinite,
                painter: CircleTransitionPainter(
                  backgroundColor: pages[0].backgroundColor,
                  currentCircleColor: pages[1].backgroundColor,
                  nextCircleColor: pages[2].backgroundColor,
                  transitionPercent: value,
                ),
                child: const Center(
                  child: Text('empty page'),
                ),
              ),
            ),
          ),
        ),
      );
}

class CircleTransitionPainter extends CustomPainter {
  CircleTransitionPainter({
    required Color backgroundColor,
    required Color currentCircleColor,
    required Color nextCircleColor,
    this.transitionPercent = 0,
  })  : backgroundPaint = Paint()..color = backgroundColor,
        currentCirclePaint = Paint()..color = currentCircleColor,
        nextCirclePaint = Paint()..color = nextCircleColor;

  final double baseCircleRadius = 36;
  final Paint backgroundPaint;
  final Paint currentCirclePaint;
  final Paint nextCirclePaint;
  final double transitionPercent;

  @override
  void paint(Canvas canvas, Size size) {
    if (transitionPercent < 0.5) {
      final expansionPercent = transitionPercent / 0.5;
      _drawExpansion(canvas, size, expansionPercent);
    } else {
      final contractionPercent = (transitionPercent - 0.5) / 0.5;
      _drawContraction(canvas, size, contractionPercent);
    }
  }

  void _drawExpansion(Canvas canvas, Size size, double expansionPercent) {
    canvas.drawPaint(backgroundPaint);

    final maxRadius = size.height * 200;
    final baseCircleCenterPosition = Offset(size.width / 2, size.height * 0.76);
    final circleLeftBound = baseCircleCenterPosition.dx - baseCircleRadius;
    final slowedExpansionPercent = pow(expansionPercent, 8);

    final currentRadius = baseCircleRadius + maxRadius * slowedExpansionPercent;
    final currentCirclePosition = Offset(circleLeftBound + currentRadius, baseCircleCenterPosition.dy);

    canvas.drawCircle(
      currentCirclePosition,
      currentRadius,
      currentCirclePaint,
    );

    if (expansionPercent < 0.1) {
      _drawChevron(canvas, baseCircleCenterPosition, backgroundPaint.color);
    }
  }

  void _drawContraction(Canvas canvas, Size size, double contractionPercent) {
    canvas.drawPaint(currentCirclePaint);

    final maxRadius = size.height * 200;
    final baseCircleCenterPosition = Offset(size.width / 2, size.height * 0.76);
    final startCircleRightSide = baseCircleCenterPosition.dx - baseCircleRadius;
    final endCircleRightSide = baseCircleCenterPosition.dx + baseCircleRadius;

    final easedContractionPercent = Curves.easeInOut.transform(contractionPercent);
    final inverseContractionPercent = 1.0 - contractionPercent;
    final slowedInverseContractionPercent = pow(inverseContractionPercent, 8);

    final currentRadius = baseCircleRadius + maxRadius * slowedInverseContractionPercent;
    final currentCircleRightSide =
        startCircleRightSide + (endCircleRightSide - startCircleRightSide) * easedContractionPercent;
    final currentCirclePosition = Offset(currentCircleRightSide - currentRadius, baseCircleCenterPosition.dy);

    canvas.drawCircle(
      currentCirclePosition,
      currentRadius,
      backgroundPaint,
    );

    if (easedContractionPercent > 0.9) {
      final newCircleExpansionPercent = (easedContractionPercent - 0.9) / 0.1;
      final newCircleRadius = baseCircleRadius * newCircleExpansionPercent;
      canvas.drawCircle(
        currentCirclePosition,
        newCircleRadius,
        nextCirclePaint,
      );
    }

    if (contractionPercent > 0.95) {
      _drawChevron(canvas, baseCircleCenterPosition, currentCirclePaint.color);
    }
  }

  void _drawChevron(ui.Canvas canvas, Offset circleCenterPosition, Color color) {
    final chevronIconData = Icons.arrow_forward_ios;
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: chevronIconData.fontFamily,
        fontSize: 24,
        textAlign: TextAlign.center,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(String.fromCharCode(chevronIconData.codePoint));
    final paragraph = paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: baseCircleRadius));
    canvas.drawParagraph(paragraph, circleCenterPosition - Offset(paragraph.width / 2, paragraph.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
