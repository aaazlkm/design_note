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
          child: Processing(
            sketch: Sketch.simple(
              setup: (s) {
                print('setup');
                s.size(width: 200, height: 200);
              },
              draw: (s) {
                print('draw ${s.frameRate}');

                s
                  ..noStroke()
                  ..background(color: Colors.black)
                  ..rect(rect: Rect.fromLTWH(40, 0, 20, s.height.toDouble()))
                  ..rect(rect: Rect.fromLTWH(60, 0, 20, s.height / 2));
              },
            ),
          ),
        ),
      );
}
