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
  final droplets = <Droplet>[];

  @override
  void reassemble() {
    super.reassemble();
    droplets.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Processing(
            sketch: Sketch.simple(
              setup: (s) {
                const width = 100.0;
                const height = 100.0;
                s
                  ..size(width: width, height: height)
                  ..background(
                    color: Colors.black,
                  );
              },
              draw: (s) {
                s
                  ..translate(x: 20, y: 40)
                  ..rect(rect: Rect.fromCenter(center: Offset(10, 10), width: 10, height: 10));
              },
            ),
          ),
        ),
      );
}

class Droplet {
  Droplet({
    required this.x,
    required this.y,
    required this.z,
    required this.length,
  });

  double x;
  double y;
  double z;
  double length;

  void fall(Sketch s) {
    y += lerpDouble(6, 10, z)!;
    if (y + length > s.height) {
      y = 0;
    }
  }

  void paint(Sketch s) {
    final colorOpacity = lerpDouble(0.4, 1, z)!;
    final perspectiveLength = lerpDouble(length * 0.2, length, z)!;
    s
      ..stroke(color: Colors.white.withOpacity(colorOpacity))
      ..line(Offset(x, y), Offset(x, y + perspectiveLength));
  }
}
