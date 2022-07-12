import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:processing/processing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Page(),
      );
}

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final stars = <Star>[];

  @override
  void reassemble() {
    super.reassemble();
    stars.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Processing(
            sketch: Sketch.simple(
              setup: (s) {
                const width = 800.0;
                const height = 800.0;
                s
                  ..size(width: width, height: height)
                  ..background(
                    color: Colors.black,
                  );

                for (var i = 0; i < 500; i++) {
                  stars.add(
                    Star(
                      x: width / 2 + s.random(-width.toInt(), width.toInt()),
                      y: s.random(-height.toInt(), height.toInt()),
                      z: s.random(width.toInt()),
                    ),
                  );
                }
              },
              draw: (s) {
                for (final star in stars) {
                  star.update(s);
                }

                for (final star in stars) {
                  star.paintStroke(s);
                }

                for (final star in stars) {
                  star.paintStar(s);
                }
              },
            ),
          ),
        ),
      );
}

class Star {
  Star({
    required this.x,
    required this.y,
    required this.z,
  }) : strokeStartZ = 0 {
    strokeStartZ = z;
  }

  double x;
  double y;
  double z;
  double strokeStartZ;

  void update(Sketch s) {
    z -= 10;
    strokeStartZ -= 5;

    if (z < 0) {
      x = s.random(-s.width.toInt(), s.width.toInt());
      y = s.random(-s.height.toInt(), s.height.toInt());
      z = s.random(s.width.toInt());
      strokeStartZ = z;
    }
  }

  void paintStroke(Sketch s) {
    final center = Offset(
      s.width / 2,
      s.height / 2,
    );
    final perspectiveOffsetStart = Offset(
      lerpDouble(0, s.width, x / strokeStartZ)!,
      lerpDouble(0, s.height, y / strokeStartZ)!,
    );
    final perspectiveOffset = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );
    s
      ..stroke(color: Colors.white.withOpacity(0.3))
      ..line(perspectiveOffsetStart + center, perspectiveOffset + center);
  }

  void paintStar(Sketch s) {
    final center = Offset(
      s.width / 2,
      s.height / 2,
    );
    final perspectiveOffset = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );
    final diameter = lerpDouble(12, 0, z / s.width)!;

    s
      ..noStroke()
      ..fill(
        color: Colors.white,
      )
      ..circle(
        center: center + perspectiveOffset,
        diameter: diameter,
      );
  }
}
