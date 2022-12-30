import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 星をタップできるようにする
// -> そのためにはviewをクリップする必要がある...?
// -> クリップするためには、pathが存在すればいける気がする
// 小さい星をばら撒く方法
// stackでposition使う
// canvasでやる -> canvasでやったほうが描画効率良さそうだからこれでやるか
//
// たまにタップがちゃんと動かないのなんだろうな

class StarFlashPage extends StatefulWidget {
  const StarFlashPage({Key? key}) : super(key: key);

  @override
  StarFlashPageState createState() => StarFlashPageState();
}

class StarFlashPageState extends State<StarFlashPage> with SingleTickerProviderStateMixin {
  late final StarsController _starsController = StarsController();
  Ticker? ticker;
  Duration? prevTime;

  void _onTick(Duration elapsedTime) {
    setState(() {
      _starsController.move(elapsedTime);
    });
    prevTime = elapsedTime;
  }

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: Stack(
          children: [
            ..._starsController.stars.map(
              (star) => Positioned(
                left: star.x,
                top: star.y,
                child: Transform.rotate(
                  angle: star.angle,
                  child: CustomPaint(
                    painter: StarPainter(
                      starSize: star.size.toInt(),
                      startColor: star.color,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              child: GestureDetector(
                onTap: () {
                  print("onTap");
                  _starsController.start(MediaQuery.of(context).size.center(Offset.zero));
                },
                child: CustomPaint(
                  painter: StarPainter(
                    starSize: 80,
                    startColor: Colors.yellow,
                  ),
                  size: Size(80, 80),
                ),
              ),
            ),
          ],
        ),
      );
}

class StarsController {
  List<Star> stars = [];

  void start(Offset offset) {
    // 新しく作成したいけど、リストの内容が途中で変わるのあまり上手くないんだよな
    // view構築中に死ぬ気がする
    stars = [
      ...stars,
      ...List.generate(30, (index) => Star()..init(offset)),
    ];
    print("starSize: ${stars.length}");
    for (final star in stars) {
      print("x: ${star.x}");
      print("y: ${star.y}");
    }
  }

  void move(Duration elapsedTime) {
    for (final star in stars) {
      star.move(elapsedTime);
    }
  }
}

class Star {
  Star() {
    init(Offset.zero);
  }

  double size = 0;
  double x = 0;

  /**
   * 重力計算でyを計算する
   * 単位時間あたりの移動量を計算する
   */
  double y = 0;
  double x0 = 0;
  double y0 = 0;
  double v0x = 0;
  double v0y = 0;
  double angle = 0;
  double angleV = 0;
  Color color = Colors.yellow;
  Duration? generatedAt;

  void init(Offset startPosition) {
    size = lerpDouble(10, 20, Random().nextDouble())!;
    x0 = startPosition.dx;
    y0 = startPosition.dy;
    x = x0;
    y = y0;
    v0x = (Random().nextBool() ? 1 : -1) * lerpDouble(10, 150, Random().nextDouble())!;
    v0y = (Random().nextBool() ? -1 : -1) * lerpDouble(150, 500, Random().nextDouble())!;
    angle = lerpDouble(0, 2 * pi, Random().nextDouble())!;
    angleV = lerpDouble(0, 2 * pi, Random().nextDouble())!;
    color = Colors.yellow;
  }

  void move(Duration elapsedTime) {
    generatedAt ??= elapsedTime;
    final time = (elapsedTime - generatedAt!).inMilliseconds / 1000;
    x = x0 + v0x * time;
    y = y0 + v0y * time + 750 * time * time / 2;
    angle = (angle + pi * 0.03) % (2 * pi);
  }
}

class StarPainter extends CustomPainter {
  StarPainter({
    required this.starSize,
    required this.startColor,
  });

  final Color startColor;
  final int starSize;

  late final startPaint = Paint()
    ..color = startColor
    ..maskFilter = MaskFilter.blur(BlurStyle.solid, 12);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..extendWithPath(
        createStarPath(starSize),
        size.center(Offset.zero),
      );
    canvas.drawPath(path, startPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Path createStarPath(int size) {
  final starPath = Path();
  final outerCircleRadius = size * 0.5;
  final innerCircleRadius = outerCircleRadius * 0.4;
  const starPointAngleUnit = 2 * pi / 10;
  const baseAngle = -pi / 2;
  starPath.moveTo(outerCircleRadius * cos(baseAngle), outerCircleRadius * sin(baseAngle));
  for (final i in List.generate(10, (index) => index + 1)) {
    final radius = i.isEven ? outerCircleRadius : innerCircleRadius;
    starPath.lineTo(
      radius * cos(baseAngle - starPointAngleUnit * i),
      radius * sin(baseAngle - starPointAngleUnit * i),
    );
  }
  return starPath;
}

class StarClipper extends CustomClipper<Path> {
  StarClipper();

  @override
  Path getClip(Size size) => Path()
    ..extendWithPath(
      createStarPath(
        min(size.width.toInt(), size.height.toInt()),
      ),
      Offset(size.width / 2, size.height / 2),
    );

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
