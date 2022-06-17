import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextScrollPage extends StatefulWidget {
  const TextScrollPage({Key? key}) : super(key: key);

  @override
  _TextScrollPageState createState() => _TextScrollPageState();
}

class _TextScrollPageState extends State<TextScrollPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final animationCurve = Interval(0.3, 0.7, curve: Curves.easeInOut);

  List<String> _labels = [
    "label1",
    "label2",
    "label3",
    "label4",
    "label5",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.forward(from: 0);
          _switchLabel();
        }
      })
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchLabel() {
    _labels = [..._labels.getRange(1, _labels.length), _labels.first];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ColoredBox(
          color: Colors.blueGrey[500]!,
          child: Center(
            child: ColoredBox(
              color: Colors.blueGrey[700]!,
              child: CustomPaint(
                size: Size(Size.infinite.width, 30),
                painter: TextScrollPainter(
                  labels: _labels,
                  scrollPosition: animationCurve.transform(_animationController.value),
                ),
              ),
            ),
          ),
        ),
      );
}

class TextScrollPainter extends CustomPainter {
  TextScrollPainter({
    required this.labels,
    required this.scrollPosition,
  }) : fadeGradient = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white,
            Colors.white,
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.05, 0.3, 0.7, 0.95],
        );

  final List<String> labels;
  final double scrollPosition;
  final LinearGradient fadeGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final fadeShader = fadeGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fadePaint = Paint()..shader = fadeShader;

    final paragraph1 = _buildParagraph(labels.first, size, fadePaint);
    final lineHeight1 = paragraph1.height;
    final linePosition1 = Offset(0, (size.height - lineHeight1) / 2 + size.height * scrollPosition);
    canvas.drawParagraph(paragraph1, linePosition1);

    labels.getRange(1, labels.length).forEachIndexed((index, label) {
      final paragraph2 = _buildParagraph(label, size, fadePaint);
      final linePosition2 = linePosition1.translate(0, -size.height * (index + 1));
      canvas.drawParagraph(paragraph2, linePosition2);
    });
  }

  ui.Paragraph _buildParagraph(String label, Size availableSpace, Paint paint) {
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(ui.TextStyle(foreground: paint))
      ..addText(label);
    return paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: availableSpace.width));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
