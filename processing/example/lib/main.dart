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
  Offset _circularOffset = Offset.zero;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: const Size.square(100),
            child: Processing(
              sketch: Sketch.simple(
                setup: (s) {
                  print('setup');
                  s.frameRate = 60;
                },
                draw: (s) {
                  print('draw ${s.frameRate}');

                  if (s.frameCount % 15 == 0) {
                    final x = s.random(0, 100);
                    final y = s.random(0, 100);
                    _circularOffset = Offset(x, y);
                  }
                  s.circle(center: _circularOffset, diameter: 10);

                  // s
                  //   ..arc(
                  //     ellipse: Ellipse.fromCenter(
                  //       center: Offset(50, 55),
                  //       width: 50,
                  //       height: 50,
                  //     ),
                  //     startAngle: 0,
                  //     endAngle: pi / 2,
                  //   )
                  //   ..arc(
                  //     ellipse: Ellipse.fromCenter(
                  //       center: Offset(50, 55),
                  //       width: 60,
                  //       height: 60,
                  //     ),
                  //     startAngle: pi / 2,
                  //     endAngle: pi,
                  //     arcMode: ArcMode.pie,
                  //   )
                  //   ..arc(
                  //     ellipse: Ellipse.fromCenter(
                  //       center: Offset(50, 55),
                  //       width: 70,
                  //       height: 70,
                  //     ),
                  //     startAngle: pi,
                  //     endAngle: pi + pi / 4,
                  //     arcMode: ArcMode.chord,
                  //   )
                  //   ..arc(
                  //     ellipse: Ellipse.fromCenter(
                  //       center: Offset(50, 55),
                  //       width: 80,
                  //       height: 80,
                  //     ),
                  //     startAngle: pi + pi / 4,
                  //     endAngle: pi * 2,
                  //     arcMode: ArcMode.open,
                  //   );
                  //
                  // s.randomSeed(2);
                  // final random = s.random(2);
                  // print("random$random");
                  //
                  // final ramdoms = s.random(2, 45);
                  // print("random$ramdoms");
                },
              ),
            ),
          ),
        ),
      );
}
