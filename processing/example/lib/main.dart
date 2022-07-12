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
                const width = 800.0;
                const height = 800.0;
                s
                  ..size(width: width, height: height)
                  ..background(
                    color: Colors.black,
                  );

                for (var i = 0; i < 500; i++) {
                  droplets.add(
                    Droplet(
                      x: s.random(width.toInt()),
                      y: s.random(-height.toInt(), 0),
                      z: s.random(0, 1),
                      length: 15,
                    ),
                  );
                }
              },
              draw: (s) {
                for (final star in droplets) {
                  star
                    ..fall(s)
                    ..paint(s);
                }
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
