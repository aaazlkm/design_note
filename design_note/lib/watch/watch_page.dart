import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// - 丸を作る
// - 文字を配置する
// - 単身を描く
// - 長身を描く
// - 単身を現在の時刻通りに回す
// - 長身を現在の時刻通りに回す
// - 単身と長身を自分で回せるようにする
// -> viewにしないとできないわ
// -> viewにしてもtransformでview１をを変更できないから、タップ判定もできない
// -> 全体に対して、gestureDetectorするしかない
// -> 指定した中の枠の中をタップされたかどうか判定できれば、やれる気がするな
// - 縁を作成する

class WatchPage extends StatefulWidget {
  const WatchPage({Key? key}) : super(key: key);

  @override
  WatchPageState createState() => WatchPageState();
}

class WatchPageState extends State<WatchPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: WatchView(),
        ),
      );
}

class WatchView extends StatefulWidget {
  const WatchView({Key? key}) : super(key: key);

  @override
  State<WatchView> createState() => _WatchViewState();
}

enum TickType { hour, minute, second }

class _WatchViewState extends State<WatchView> with SingleTickerProviderStateMixin {
  double secondsInDay = 5 * Duration.secondsPerHour + 49 * Duration.secondsPerMinute + 3;

  double get hourPercent => (secondsInDay % (Duration.secondsPerHour * 12)) / (Duration.secondsPerHour * 12);

  double get minutesPercent => (secondsInDay % Duration.secondsPerHour) / Duration.secondsPerHour;

  double get secondsPercent => (secondsInDay % Duration.secondsPerMinute) / Duration.secondsPerMinute;

  double get hourAngle => 2 * pi * hourPercent;

  double get minuteAngle => 2 * pi * minutesPercent;

  double get secondsAngle => 2 * pi * secondsPercent;

  Ticker? ticker;

  Duration? prevElapsedTIme;

  TickType? selectedTickType;

  double? prevAngle;

  void _onTick(Duration elapsedTime) {
    // if (prevElapsedTIme == null) {
    //   prevElapsedTIme = elapsedTime;
    //   return;
    // }
    // final diffInSeconds = (elapsedTime - (prevElapsedTIme ?? elapsedTime)).inSeconds;
    // if (diffInSeconds < 1) {
    //   return;
    // }
    // print("diffInSeconds: $diffInSeconds");
    //
    // prevElapsedTIme = elapsedTime;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    secondsInDay =
        (now.hour * Duration.secondsPerHour + now.minute * Duration.secondsPerMinute + now.second).toDouble();
    ticker = createTicker(_onTick)..start();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsInDay += 1;
      });
    });
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
        size: Size.square(200),
        child: GestureDetector(
          onPanStart: (details) {
            print("onPanStart: $details");
            final center = Offset(100, 100);
            final potisionFromCenter = details.localPosition - center;
            final angle = (-atan2(-potisionFromCenter.dy, potisionFromCenter.dx) + 2 * pi + pi / 2) % (2 * pi);
            TickType? calculateNearlyTickType(double angle) {
              final nealyTickAngle = [hourAngle, minuteAngle, secondsAngle]
                  .mapIndexed((index, e) => MapEntry<int, double>(index, (e - angle).abs()))
                  .reduce(
                    (value, element) => (value.value > element.value) ? element : value,
                  );
              print("angle: $angle");
              print("hourAngle: $hourPercent");
              print("hourAngle: $hourAngle");
              print("minuteAngle: $minuteAngle");
              print("secondsAngle: $secondsAngle");
              print("diff: $nealyTickAngle");

              if (nealyTickAngle.value < pi / 10) {
                return TickType.values[nealyTickAngle.key];
              } else {
                return null;
              }
            }

            setState(() {
              selectedTickType = calculateNearlyTickType(angle);
              prevAngle = null;
            });
            print("selectedTickType: $selectedTickType");
          },
          onPanUpdate: (details) {
            // print("onPanUpdate: $details");
            final selectedTickType = this.selectedTickType;
            if (selectedTickType == null) {
              return;
            }
            print("selectedTickType: $selectedTickType");
            final center = Offset(100, 100);
            final potisionFromCenter = details.localPosition - center;
            final angle = (-atan2(-potisionFromCenter.dy, potisionFromCenter.dx) + 2 * pi + pi / 2) % (2 * pi);
            if (prevAngle == null) {
              prevAngle = angle;
              return;
            }
            // print("angle: $angle");
            // print("hourAngle: $hourAngle");
            // print("minuteAngle: $minuteAngle");
            // print("secondsAngle: $secondsAngle");
            int calSecondsInDay(TickType tickType) {
              switch (tickType) {
                case TickType.hour:
                  return 12 * Duration.secondsPerHour;
                case TickType.minute:
                  return 60 * Duration.secondsPerMinute;
                case TickType.second:
                  return Duration.secondsPerMinute;
              }
            }

            final seconds = calSecondsInDay(selectedTickType);
            print("angle: $angle");
            print("prevAngle: $prevAngle");
            double dAngle;
            if ((angle - prevAngle!).abs() > pi) {
              // 0 <-> 2 * pi に変換される境界線
              dAngle = angle + (angle > prevAngle! ? 0 : 2 * pi) - (prevAngle! + (angle > prevAngle! ? 2 * pi : 0));
            } else {
              dAngle = angle - prevAngle!;
            }
            // %するとマイナスにならない
            final percent = dAngle / (2 * pi);
            setState(() {
              secondsInDay += seconds * percent;
            });
            prevAngle = angle;
          },
          onPanDown: (details) {
            print("onPanDown: $details");
            setState(() {
              selectedTickType = null;
              prevAngle = null;
            });
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: WatchBackground(),
              ),
              Positioned.fill(
                child: HourTexts(),
              ),
              HourTick(
                angle: hourAngle,
              ),
              MinuteTick(
                angle: minuteAngle,
              ),
              SecondTick(
                angle: secondsAngle,
              )
            ],
          ),
        ),
      );
}

class WatchBackground extends StatelessWidget {
  const WatchBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
            )
          ],
        ),
      );
}

class HourTick extends StatelessWidget {
  const HourTick({
    required this.angle,
    this.strokeWidth = 4,
    Key? key,
  }) : super(key: key);

  final double angle;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final radius = 0.4 * min(constraints.maxWidth, constraints.maxHeight) / 2;
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          return Transform.rotate(
            angle: angle - pi / 2,
            origin: center,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: center,
              child: GestureDetector(
                onTap: () {
                  print("hour: ");
                },
                onPanUpdate: (details) {
                  print("hour: $details");
                },
                child: Container(
                  height: strokeWidth,
                  width: radius,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class MinuteTick extends StatelessWidget {
  const MinuteTick({
    required this.angle,
    this.strokeWidth = 4,
    Key? key,
  }) : super(key: key);

  final double angle;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final radius = 0.7 * min(constraints.maxWidth, constraints.maxHeight) / 2;
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          return Transform.rotate(
            angle: angle - pi / 2,
            origin: center,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: center + Offset(0, strokeWidth / 2),
              child: Container(
                height: strokeWidth,
                width: radius,
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class SecondTick extends StatelessWidget {
  const SecondTick({
    required this.angle,
    Key? key,
  }) : super(key: key);

  final double angle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final radius = 0.7 * min(constraints.maxWidth, constraints.maxHeight) / 2;
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          return Transform.rotate(
            angle: angle - pi / 2,
            origin: center,
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: center,
              child: Container(
                height: 2,
                width: radius,
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class HourTexts extends StatelessWidget {
  const HourTexts({
    this.maxHour = 12,
    Key? key,
  }) : super(key: key);

  final int maxHour;
  final Size textSize = const Size.square(16);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            ...List.generate(maxHour, (index) => index).map(
              (e) {
                final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                final radius = min(constraints.maxWidth, constraints.maxHeight) / 2 * 0.85;
                return Transform.translate(
                  offset: center +
                      Offset(
                        radius * cos(pi / 2 - e * 2 * pi / maxHour - 2 * pi / maxHour),
                        -radius * sin(pi / 2 - e * 2 * pi / maxHour - 2 * pi / maxHour),
                      ) -
                      Offset(
                        textSize.width / 2,
                        textSize.height / 2,
                      ),
                  child: SizedBox.fromSize(
                    size: textSize,
                    child: Text(
                      "${e + 1}",
                      textAlign: TextAlign.center,
                      style: TextStyle().copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
}

class WatchPainter extends CustomPainter {
  WatchPainter({
    this.maxHour = 12,
  });

  final int maxHour;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = max(size.width, size.height) / 2;
    _drawWatchBackground(canvas, size);
    _drawLongTick(canvas, size, 120);
    _drawShortTick(canvas, size, 39);
    final hourRadius = radius - 12;
    for (final hourIndex in List.generate(maxHour, (hourIndex) => hourIndex)) {
      _drawWatchText(
        canvas,
        "${hourIndex + 1}",
        size.center(
          Offset(
            hourRadius * cos(pi / 2 - hourIndex * 2 * pi / maxHour - 2 * pi / maxHour),
            -hourRadius * sin(pi / 2 - hourIndex * 2 * pi / maxHour - 2 * pi / maxHour),
          ),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void _drawWatchBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade100;
    final shadowPaint = Paint()
      ..color = Colors.grey.shade300
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 16);
    final radius = max(size.width, size.height) / 2;
    canvas
      ..drawCircle(size.center(Offset.zero), radius, shadowPaint)
      ..drawCircle(size.center(Offset.zero), radius, paint);
    // ..drawArc(
    //   Rect.fromCenter(
    //     center: Offset(size.height * 0.5, size.width * 0.5),
    //     height: size.height,
    //     width: size.width,
    //   ),
    //   0,
    //   pi,
    //   true,
    //   paint..color = Colors.blueGrey.shade100.withOpacity(0.6),
    // );
  }

  void _drawLongTick(Canvas canvas, Size size, double angle) {
    final radius = 0.6 * max(size.width, size.height) / 2;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      size.center(Offset.zero),
      size.center(
        Offset(
          radius * cos(pi / 2 + 2 * pi * angle / 360),
          radius * sin(pi / 2 + 2 * pi * angle / 360),
        ),
      ),
      paint,
    );
  }

  void _drawShortTick(Canvas canvas, Size size, double angle) {
    final radius = 0.4 * max(size.width, size.height) / 2;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      size.center(Offset.zero),
      size.center(
        Offset(
          radius * cos(pi / 2 + 2 * pi * angle / 360),
          radius * sin(pi / 2 + 2 * pi * angle / 360),
        ),
      ),
      paint,
    );
  }

  void _drawWatchText(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
  }
}
