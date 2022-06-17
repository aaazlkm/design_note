import 'dart:math';

import 'package:flutter/material.dart';

class GlitchyTextPage extends StatefulWidget {
  const GlitchyTextPage({Key? key}) : super(key: key);

  @override
  GlitchyTextPageState createState() => GlitchyTextPageState();
}

class GlitchyTextPageState extends State<GlitchyTextPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color.alphaBlend(Colors.black.withOpacity(0.6), Colors.deepPurple.shade900),
        body: Center(
          child: GlitchyPrice(
            price: '\$40,503.42',
          ),
        ),
      );
}

class GlitchyPrice extends StatefulWidget {
  const GlitchyPrice({
    required this.price,
    this.baseTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 48,
    ),
    this.increaseColor = Colors.greenAccent,
    this.decreaseColor = Colors.pinkAccent,
    Key? key,
  }) : super(key: key);

  final String price;
  final TextStyle baseTextStyle;
  final Color increaseColor;
  final Color decreaseColor;

  @override
  State<GlitchyPrice> createState() => _GlitchyPriceState();
}

class _GlitchyPriceState extends State<GlitchyPrice> with SingleTickerProviderStateMixin {
  bool isIncrease = true;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future<void>.delayed(Duration(seconds: 1));
          animationController.forward(from: 0);
          setState(() {
            isIncrease = !isIncrease;
          });
          print("updated");
        }
      });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: (sin(Random().nextInt(3) * pi * sin(animationController.value * Random().nextInt(3) * pi))) * -8,
              child: Text(
                widget.price,
                style: widget.baseTextStyle.copyWith(
                  color: (isIncrease ? widget.increaseColor : widget.decreaseColor).withOpacity(
                      (1 - CurvedAnimation(parent: animationController, curve: Curves.easeInExpo).value) * 1),
                ),
              ),
            ),
            Positioned(
              left: (sin(Random().nextInt(3) * pi * sin(animationController.value * Random().nextInt(3) * pi))) * 8,
              child: Text(
                widget.price,
                style: widget.baseTextStyle.copyWith(
                  color: (isIncrease ? widget.increaseColor : widget.decreaseColor).withOpacity(
                      (1 - CurvedAnimation(parent: animationController, curve: Curves.easeInExpo).value) * 1),
                ),
              ),
            ),
            Text(
              widget.price,
              style: widget.baseTextStyle,
            ),
          ],
        ),
      );
}
