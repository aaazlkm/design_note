import 'package:flutter/material.dart';

class ListProgressPage extends StatefulWidget {
  const ListProgressPage({Key? key}) : super(key: key);

  @override
  ListProgressPageState createState() => ListProgressPageState();
}

class ListProgressPageState extends State<ListProgressPage> {
  double progress = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              child: ListView(
                children: [
                  ...List.generate(10, (index) => index).map(
                    (e) => ListItem(),
                  ),
                ],
              ),
              onNotification: (t) {
                print("piexels: ${t.metrics.pixels}");
                print("maxScrollExtent: ${t.metrics.maxScrollExtent}");
                final metrics = t.metrics;
                setState(() {
                  progress = (metrics.pixels / metrics.maxScrollExtent).clamp(0, 1.0);
                });
                print("progress: ${progress}");
                return false;
              },
            ),
            Align(
              alignment: Alignment(0, 0.8),
              child: Progress(
                progress: progress,
              ),
            )
          ],
        ),
      );
}

class Progress extends StatelessWidget {
  const Progress({
    required this.progress,
    Key? key,
  }) : super(key: key);

  final double progress;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text("${(progress * 100).toInt()}"),
              ),
              SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth * progress,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade500,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
}

class ListItem extends StatelessWidget {
  const ListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(16).copyWith(bottom: 16),
        child: Container(
          padding: EdgeInsets.all(16),
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-0.7, -0.7),
              end: Alignment(0.7, 0.7),
              colors: [
                Colors.blueGrey.shade100,
                Colors.blueGrey.shade200,
              ],
            ),
          ),
        ),
      );
}
