import 'package:flutter/material.dart';

class Lesson3Page extends StatefulWidget {
  const Lesson3Page({Key? key}) : super(key: key);

  @override
  _Lesson3PageState createState() => _Lesson3PageState();
}

class _Lesson3PageState extends State<Lesson3Page> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                    /// Use [Axis.vertical] to scroll vertically.
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    children: const <Widget>[
                      Center(
                        child: Text('First Page'),
                      ),
                      Center(
                        child: Text('Second Page'),
                      ),
                      Center(
                        child: Text('Third Page'),
                      ),
                      Center(
                        child: Text('4 Page'),
                      ),
                    ],
                  ),
                ),
                ColoredBox(
                  color: Colors.blueGrey[500]!,
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) => CustomPaint(
                      painter: PageIndicatorPainter(
                        pageCount: 4,
                        dotRadius: 10,
                        dotOutlineThickness: 2,
                        spacing: 25,
                        scrollPosition:
                            _pageController.hasClients && _pageController.page != null ? _pageController.page! : 0,
                        dotFillColor: const Color(0x0F000000),
                        dotOutlineColor: const Color(0x20000000),
                        indicatorColor: const Color(0xFF444444),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class PageIndicatorPainter extends CustomPainter {
  PageIndicatorPainter({
    required this.pageCount,
    required this.dotRadius,
    required this.dotOutlineThickness,
    required this.spacing,
    required Color dotFillColor,
    required Color dotOutlineColor,
    required Color indicatorColor,
    this.scrollPosition = 0.0,
  })  : dotFillPaint = Paint()..color = dotFillColor,
        dotOutlinePaint = Paint()..color = dotOutlineColor,
        indicatorPaint = Paint()..color = indicatorColor;

  final int pageCount;
  final double dotRadius;
  final double dotOutlineThickness;
  final double spacing;
  final double scrollPosition;
  final Paint dotFillPaint;
  final Paint dotOutlinePaint;
  final Paint indicatorPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final totalWidth = (pageCount * dotRadius * 2) + (pageCount - 1) * spacing;
    _drawDots(canvas, center, totalWidth);
    _drawPageIndicator(canvas, center, totalWidth);
  }

  void _drawPageIndicator(Canvas canvas, Offset center, double totalWidth) {
    final padeIndexToLeft = scrollPosition.floor();
    final leftDotX = (center.dx - (totalWidth / 2)) + padeIndexToLeft * (2 * dotRadius + spacing);
    final transitionPercent = scrollPosition - padeIndexToLeft;
    final laggingLeftPositionPercent = (transitionPercent - 0.3).clamp(0, 1.0) / 0.7;
    final acceleratedRightPositionPercent = (transitionPercent / 0.5).clamp(0, 1);
    final indicatorLeftX = leftDotX + (2 * dotRadius + spacing) * laggingLeftPositionPercent;
    final indicatorRightX = leftDotX + (2 * dotRadius + spacing) * acceleratedRightPositionPercent + 2 * dotRadius;
    canvas.drawRRect(
      RRect.fromLTRBR(
        indicatorLeftX,
        -dotRadius,
        indicatorRightX,
        dotRadius,
        Radius.circular(dotRadius),
      ),
      indicatorPaint,
    );
  }

  void _drawDots(Canvas canvas, Offset center, double totalWidth) {
    final leftDotCenter = center.translate(-totalWidth / 2 + dotRadius, 0);
    for (var i = 0; i < pageCount; i++) {
      final dotCenter = leftDotCenter.translate(((2 * dotRadius) + spacing) * i, 0);
      _drawDot(canvas, dotCenter);
    }
  }

  void _drawDot(Canvas canvas, Offset dotCenter) {
    canvas.drawCircle(dotCenter, dotRadius - dotOutlineThickness, dotFillPaint);
    final outlinePath = Path()
      ..addOval(Rect.fromCircle(center: dotCenter, radius: dotRadius))
      ..addOval(Rect.fromCircle(center: dotCenter, radius: dotRadius - dotOutlineThickness))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(outlinePath, dotOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
