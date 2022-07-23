import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WavePage extends StatefulWidget {
  const WavePage({Key? key}) : super(key: key);

  @override
  _WavePageState createState() => _WavePageState();
}

class _WavePageState extends State<WavePage> with TickerProviderStateMixin {
  double waveYPercent = 0.8;

  late final AnimationController _waveYAnimationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 3000),
  )..repeat();

  late final AnimationController _waveAnimationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 3000),
  )..repeat();

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _waveYAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey[50],
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(60)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey[900]!.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blueGrey[50],
                child: LayoutBuilder(
                  builder: (context, constraints) => AnimatedBuilder(
                    animation: _waveAnimationController,
                    builder: (context, child) => Stack(
                      children: [
                        ClipPath(
                          clipper: WaveClipper(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            waveXPercent: _waveAnimationController.value,
                            waveYPercent: Tween(begin: 0.0, end: 1.0).lerp(1 - _waveYAnimationController.value),
                            offset: 0,
                          ),
                          child: Container(
                            color: Colors.blueGrey[500]!.withOpacity(0.3),
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                        ClipPath(
                          clipper: WaveClipper(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            waveXPercent: _waveAnimationController.value,
                            waveYPercent: Tween(begin: 0.0, end: 1.0).lerp(1 - _waveYAnimationController.value),
                            offset: 0.4,
                          ),
                          child: Container(
                            color: Colors.blueGrey[500]!.withOpacity(0.3),
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                        ClipPath(
                          clipper: WaveClipper(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            waveXPercent: _waveAnimationController.value,
                            waveYPercent: Tween(begin: 0.0, end: 1.0).lerp(1 - _waveYAnimationController.value),
                            offset: 0.7,
                          ),
                          child: Container(
                            color: Colors.blueGrey[500]!.withOpacity(0.3),
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class WaveClipper extends CustomClipper<Path> {
  WaveClipper({
    required this.waveXPercent,
    required this.waveYPercent,
    required double height,
    required double width,
    required double offset,
  }) : wavePoints = _generateWavePoints(height, width, waveXPercent, waveYPercent, offset);

  static List<Offset> _generateWavePoints(
      double height, double width, double percent, double waveYPercent, double offset) {
    final wavePoints = <Offset>[];
    const splittedCount = 4;
    final waveHeight = height * 0.09;

    for (var i = 0; i <= width / splittedCount; i++) {
      final x = (i / width) - percent;
      // print("percent: ${percent}");
      // print("i / width: ${i / width}");
      print("x: $x");
      wavePoints.add(
        Offset(
          i.toDouble() * splittedCount,
          sin(2 * pi * (x - offset)) * waveHeight + height * waveYPercent,
        ),
      );
    }

    // for (var i = 0; i < wavePointCount; i++) {
    //   final wavePoint = Offset(
    //     width * (i / wavePointCount) + percent * (width / wavePointCount),
    //     (height * 0.2),
    //   );
    //   wavePoints.add(wavePoint);
    // }
    return wavePoints;
  }

  final double waveXPercent;
  final double waveYPercent;
  final List<Offset> wavePoints;

  @override
  Path getClip(Size size) => Path()
    ..addPolygon(wavePoints, false)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..lineTo(wavePoints.first.dx, wavePoints.first.dy)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => this != oldClipper;
}
