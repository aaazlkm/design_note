import 'package:flutter/material.dart';

class CircleColorToRectanglePage extends StatefulWidget {
  const CircleColorToRectanglePage({Key? key}) : super(key: key);

  @override
  CircleColorToRectanglePageState createState() => CircleColorToRectanglePageState();
}

class CircleColorToRectanglePageState extends State<CircleColorToRectanglePage> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ClipRect(
            child: SizedBox.fromSize(
              size: Size.square(200),
              child: Center(
                child: InkWell(
                  onTap: () => setState(() => expanded = !expanded),
                  child: AnimatedContainer(
                    height: expanded ? 200 : 50,
                    width: expanded ? 200 : 50,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOutBack,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(expanded ? 8 : 25),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade800,
                          Colors.purple.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
