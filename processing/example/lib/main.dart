import 'dart:math';

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

class Page extends StatelessWidget {
  const Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: const Size.square(100),
            child: Processing(
              sketch: Sketch.simple(
                draw: (s) {
                  s
                    ..arc(
                      ellipse: Ellipse.fromCenter(
                        center: Offset(50, 55),
                        width: 50,
                        height: 50,
                      ),
                      startAngle: 0,
                      endAngle: pi / 2,
                    )
                    ..arc(
                      ellipse: Ellipse.fromCenter(
                        center: Offset(50, 55),
                        width: 60,
                        height: 60,
                      ),
                      startAngle: pi / 2,
                      endAngle: pi,
                      arcMode: ArcMode.pie,
                    )
                    ..arc(
                      ellipse: Ellipse.fromCenter(
                        center: Offset(50, 55),
                        width: 70,
                        height: 70,
                      ),
                      startAngle: pi,
                      endAngle: pi + pi / 4,
                      arcMode: ArcMode.chord,
                    )
                    ..arc(
                      ellipse: Ellipse.fromCenter(
                        center: Offset(50, 55),
                        width: 80,
                        height: 80,
                      ),
                      startAngle: pi + pi / 4,
                      endAngle: pi * 2,
                      arcMode: ArcMode.open,
                    );
                },
              ),
            ),
          ),
        ),
      );
}
