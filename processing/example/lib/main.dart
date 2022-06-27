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
                  s.ellipse(
                    ellipse: Ellipse.fromCenterWithRadius(
                      center: Offset(50, 50),
                      radiusX: 70,
                      radiusY: 38,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
}
