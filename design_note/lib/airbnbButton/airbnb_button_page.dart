import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// scale処理
// bounceの処理のパッケージがあったはずなので、そちら参考にしてみる
// tapしてる時のgradient処理をする

class AirbnbButtonPage extends StatefulWidget {
  const AirbnbButtonPage({Key? key}) : super(key: key);

  @override
  AirbnbButtonPageState createState() => AirbnbButtonPageState();
}

class AirbnbButtonPageState extends State<AirbnbButtonPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: AirbnbButton(),
        ),
      );
}

class AirbnbButton extends StatefulWidget {
  const AirbnbButton({Key? key}) : super(key: key);

  @override
  State<AirbnbButton> createState() => _AirbnbButtonState();
}

class _AirbnbButtonState extends State<AirbnbButton> with SingleTickerProviderStateMixin {
  List<Color> get colors => [
        Colors.pink.shade400,
        Colors.pink.shade500,
        Colors.pink.shade600,
      ];

  Alignment center = Alignment.center;

  num get baseStop => animationController
      .drive(
        CurveTween(
          curve: const Interval(0, 1, curve: Curves.linear),
        ),
      )
      .drive(
        Tween(begin: 0, end: 0.02),
      )
      .value;

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (details) {
          print("onTapDown");
          animationController.forward();
        },
        onTapUp: (details) {
          print("onTapUp");
          animationController.reverse();
        },
        onPanDown: (details) {
          print("onPanDown");
          final renderObject = context.findRenderObject() as RenderBox;
          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          setState(() {
            center = Alignment(
              2 * xPercent - 1,
              2 * yPercent - 1,
            );
          });
        },
        onPanStart: (details) {
          final renderObject = context.findRenderObject() as RenderBox;
          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          setState(() {
            center = Alignment(
              2 * xPercent - 1,
              2 * yPercent - 1,
            );
          });
        },
        onPanUpdate: (details) {
          print("onPanUpdate");
          print("onPanStart");
          final renderObject = context.findRenderObject() as RenderBox;

          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          setState(() {
            center = Alignment(
              2 * xPercent - 1,
              2 * yPercent - 1,
            );
          });
          print("baseStop: $baseStop");
        },
        onPanEnd: (details) {
          print("onPanEnd");
          animationController.reverse();
        },
        onPanCancel: () {
          print("onPanCancel");
        },
        child: ScaleTransition(
          scale: animationController
              .drive(
                CurveTween(
                  curve: const Interval(0, 1, curve: Curves.easeInOut),
                ),
              )
              .drive(
                Tween(begin: 1, end: 0.95),
              ),
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: center,
                  colors: colors,
                  radius: 4,
                  stops: colors
                      .mapIndexed(
                        (index, element) =>
                            baseStop + (1 - baseStop) * Curves.easeInExpo.transform(index / colors.length),
                      )
                      .toList(),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Text(
                  "airbnb button",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
}
