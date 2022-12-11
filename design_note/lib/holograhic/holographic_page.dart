import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HolographicPage extends StatefulWidget {
  const HolographicPage({Key? key}) : super(key: key);

  @override
  State<HolographicPage> createState() => _HolographicPageState();
}

class _HolographicPageState extends State<HolographicPage> {
  double _xValue = 0;
  double _yValue = 0;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((event) {
      _xValue = (_xValue + event.x * 1.5) % 180;
      _yValue = (_yValue + event.y).clamp(0, 180) % 180;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => Material(
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HolographicView(
                xPercent: _xValue / 180,
                yPercent: _yValue / 180,
              ),
            ],
          ),
        ),
      );
}

class HolographicView extends StatelessWidget {
  HolographicView({
    required this.xPercent,
    required this.yPercent,
    Key? key,
  }) : super(key: key);

  double get offset => 20;

  HSLColor get baseColor => const HSLColor.fromAHSL(1, 0, 1, 0.9);

  final double xPercent;
  final double yPercent;

  late final Color topRightColor = baseColor.withHue((xPercent * 360 + offset) % 360).toColor();

  late final Color centerColor = baseColor.withHue(xPercent * 360).toColor();

  late final Color bottomLeftColor = baseColor.withHue((xPercent * 360 - offset) % 360).toColor();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [topRightColor, centerColor, bottomLeftColor],
              begin: Alignment((yPercent * 2) - 1, -1),
              end: Alignment((1 - yPercent) * 2 - 1, 1),
            ).createShader(bounds),
            blendMode: BlendMode.srcATop,
            child: const Icon(
              Icons.adb,
              size: 200,
            ),
          ),
        ),
      );
}
