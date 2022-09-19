import 'dart:math';

import 'package:flutter/material.dart';

class FlippingSearchPage extends StatelessWidget {
  const FlippingSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search),
                FlippingSearchView(),
              ],
            ),
          ),
        ),
      );
}

class FlippingSearchView extends StatefulWidget {
  const FlippingSearchView({Key? key}) : super(key: key);

  @override
  State<FlippingSearchView> createState() => _FlippingSearchViewState();
}

class _FlippingSearchViewState extends State<FlippingSearchView> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  double rotation = 0;
  int index = 0;
  List<String> texts = ["ここから検索する1", "ここから検索する2", "ここから検索する3"];
  bool isGoToLatterHalf = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this)..repeat(period: Duration(milliseconds: 2000));
    animationController.addListener(() {
      final rotationPercent = animationController.value;
      // indexを更新する
      if (rotationPercent < 0.5) {
        isGoToLatterHalf = true;
      } else {
        if (isGoToLatterHalf) {
          index = (index + 1) % texts.length;
          isGoToLatterHalf = false;
        }
      }

      if (rotationPercent < 0.5) {
        rotation = (pi / 2 * (rotationPercent / 0.5));
      } else {
        rotation = (pi / 2 * (rotationPercent / 0.5)) + pi;
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) => Container(
          child: Transform(
            transform: Matrix4.identity()..rotateX(rotation),
            alignment: Alignment.center,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SearchCustomPainter(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4).copyWith(left: 8 + 4),
                  child: Text(texts[index]),
                ),
              ],
            ),
          ),
        ),
      );
}

class SearchCustomPainter extends CustomPainter {
  final Paint strokePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const leftOffset = 4.0;
    final triangleHeight = size.height / 3;

    final path = Path()
      ..moveTo(leftOffset, (size.height - triangleHeight) / 2)
      ..lineTo(leftOffset, (size.height + triangleHeight) / 2)
      ..lineTo(0, size.height / 2)
      ..lineTo(leftOffset, (size.height - triangleHeight) / 2)
      ..close();

    canvas.drawPath(
      Path.combine(
          PathOperation.union,
          Path()
            ..addRRect(
              RRect.fromLTRBR(
                leftOffset,
                0,
                size.width,
                size.height,
                const Radius.circular(8),
              ),
            ),
          path),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
