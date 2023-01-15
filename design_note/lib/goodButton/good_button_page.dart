import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// やること
//
// - アイコンを用意する
// - アイコンのサイズ調整　小→大
// - アイコンの傾き調整
// - アイコンの色味調整
// - ラインeffect作成
// - くるくるのeffect作成
//
// 気づき
//
// - アニメーションは大胆に変化したほうが楽しいな

class GoodButtonPage extends StatefulWidget {
  const GoodButtonPage({Key? key}) : super(key: key);

  @override
  GoodButtonPageState createState() => GoodButtonPageState();
}

class GoodButtonPageState extends State<GoodButtonPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: GoodButton(),
        ),
      );
}

List<Color> get goodButtonColors => [
      Colors.greenAccent.shade200,
      Colors.purpleAccent.shade200,
      Colors.orangeAccent.shade200,
      Colors.pinkAccent.shade200,
    ];

class FireWorksInfo {
  FireWorksInfo({
    required this.mainColor,
    required this.subColor,
    required this.strokeWidth,
    required this.circleCount,
    required this.needFireWorks,
    required this.endLineTime,
  });

  final Color mainColor;
  final Color subColor;
  final double strokeWidth;
  final int circleCount;
  final bool needFireWorks;
  final double endLineTime;
}

List<FireWorksInfo> _generateFireWorksInfo() {
  final colorOffset = Random().nextInt(4);
  return List.generate(
    ([6, 8, 10]..shuffle()).first,
    (index) => FireWorksInfo(
      mainColor: goodButtonColors[(colorOffset + index) % goodButtonColors.length],
      subColor: goodButtonColors[(colorOffset + index + 1) % goodButtonColors.length],
      strokeWidth: lerpDouble(7, 8, Random().nextDouble())!,
      circleCount: ([4, 5, 6, 7, 8]..shuffle()).first,
      needFireWorks: (index % 2) == 0,
      endLineTime: 0.5,
    ),
  );
}

class GoodButton extends StatefulWidget {
  const GoodButton({Key? key}) : super(key: key);

  @override
  State<GoodButton> createState() => _GoodButtonState();
}

class _GoodButtonState extends State<GoodButton> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  final Animatable<Color?> colorsTween = _createColorsTween(
    [
      Colors.grey,
      ...goodButtonColors,
      Colors.grey,
    ],
  );

  List<FireWorksInfo> fireWorksInfos = _generateFireWorksInfo();

  double angleOffset = Random().nextDouble() * pi;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Animation<Color?> get color => animationController.drive(colorsTween);

  Animation<double?> get angle => animationController.drive(
        TweenSequence<double?>(
          [
            TweenSequenceItem(
              weight: 0.3,
              tween: Tween<double>(begin: 0, end: pi * 0.25),
            ),
            TweenSequenceItem(
              weight: 1,
              tween: Tween<double>(begin: pi * 0.25, end: -pi * 0.2).chain(CurveTween(curve: Curves.easeOutCirc)),
            ),
            TweenSequenceItem(
              weight: 2,
              tween: Tween<double>(begin: -pi * 0.2, end: 0).chain(CurveTween(curve: Curves.easeOutExpo)),
            ),
          ],
        ),
      );

  Animation<double?> get scale => animationController.drive(
        TweenSequence<double?>(
          [
            TweenSequenceItem(
              weight: 0.3,
              tween: Tween<double>(begin: 1, end: 0.2),
            ),
            TweenSequenceItem(
              weight: 1,
              tween: Tween<double>(begin: 0.2, end: 1.2).chain(CurveTween(curve: Curves.easeOutCirc)),
            ),
            TweenSequenceItem(
              weight: 1,
              tween: Tween<double>(begin: 1.2, end: 1).chain(CurveTween(curve: Curves.easeOutExpo)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (animationController.status == AnimationStatus.forward) {
            return;
          }
          setState(() {
            fireWorksInfos = _generateFireWorksInfo();
            angleOffset = Random().nextDouble() * pi / 4;
          });
          animationController.forward(from: 0);
        },
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) => Stack(
            children: [
              Center(
                child: Transform.rotate(
                  angle: pi / 4 * animationController.value,
                  child: CustomPaint(
                    painter: FireWorksPainter(
                      fireWorksInfos: fireWorksInfos,
                      angleOffset: angleOffset,
                      value: animationController.value,
                    ),
                    size: Size.square(110),
                  ),
                ),
              ),
              Center(
                child: Transform.scale(
                  scale: scale.value ?? 1,
                  child: Transform.rotate(
                    angle: angle.value ?? 0,
                    child: Center(
                      child: Icon(
                        Icons.thumb_up,
                        color: color.value,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

Animatable<Color?> _createColorsTween(List<Color> colors) => TweenSequence<Color?>(
      [
        ...List.generate(
          colors.length - 1,
          (index) => TweenSequenceItem(
            weight: 1,
            tween: ColorTween(begin: colors[index], end: colors[index + 1]),
          ),
        ),
      ],
    );

class FireWorksPainter extends CustomPainter {
  FireWorksPainter({
    required this.fireWorksInfos,
    required this.angleOffset,
    required this.value,
  });

  final List<FireWorksInfo> fireWorksInfos;
  final double angleOffset;
  final double value;

  final double animationStartTime = 0.1;
  final double animationEndTime = 0.99;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final insideCircleRadius = (size.longestSide / 2) * 0.3;
    final outsideCircleRadius = (size.longestSide / 2) * 0.9;

    fireWorksInfos.forEachIndexed((index, fireWorksInfo) {
      final angle = 2 * pi * (index / fireWorksInfos.length) + angleOffset;
      drawFireWorks(
        canvas,
        value,
        Offset(center.dx + insideCircleRadius * cos(angle), center.dy + insideCircleRadius * sin(angle)),
        Offset(center.dx + outsideCircleRadius * cos(angle), center.dy + outsideCircleRadius * sin(angle)),
        fireWorksInfo,
      );
    });
  }

  void drawFireWorks(
    Canvas canvas,
    double value,
    Offset start,
    Offset end,
    FireWorksInfo fireWorksInfo,
  ) {
    _drawFireWorksLine(
      canvas,
      value,
      start,
      end,
      fireWorksInfo,
    );
    _drawFireWorksFires(
      canvas,
      value,
      start,
      end,
      fireWorksInfo,
    );
  }

  // fireworksを作る
  // scale
  // 数
  // fadein fade out
  // move
  void _drawFireWorksFires(
    Canvas canvas,
    double value,
    Offset start,
    Offset end,
    FireWorksInfo fireWorksInfo,
  ) {
    if (!fireWorksInfo.needFireWorks) {
      return;
    }
    final circleStartTime = (fireWorksInfo.endLineTime - 0.5).clamp(animationStartTime, animationEndTime);
    if (value < circleStartTime || value > animationEndTime) {
      return;
    }
    final _circleValue = (value - circleStartTime / (animationEndTime - circleStartTime)).clamp(0.0, 1.0);
    final circleOpacityValue = Curves.easeInOut.transform(sin(pi * _circleValue));
    final circlePaint = Paint()..color = fireWorksInfo.subColor.withOpacity(circleOpacityValue);
    const circleRadius = 3.0;
    const radiusAtMiniCircle = 12;
    final circleTransitionValue = Curves.easeOutExpo.transform(_circleValue);
    for (final index in List.generate(fireWorksInfo.circleCount, (index) => index)) {
      final center = end +
          Offset(
            circleTransitionValue *
                radiusAtMiniCircle *
                cos(
                  value * pi + 2 * pi * (index / fireWorksInfo.circleCount),
                ),
            circleTransitionValue *
                radiusAtMiniCircle *
                sin(
                  value * pi + 2 * pi * (index / fireWorksInfo.circleCount),
                ),
          );
      canvas.drawCircle(center, circleRadius, circlePaint);
    }
  }

  void _drawFireWorksLine(
    Canvas canvas,
    double value,
    Offset start,
    Offset end,
    FireWorksInfo fireWorksInfo,
  ) {
    if (animationStartTime < animationStartTime || value > animationEndTime) {
      return;
    }
    final _value = ((value - animationStartTime) / (fireWorksInfo.endLineTime - animationStartTime)).clamp(0.0, 1.0);
    final colorOpacityValue = Curves.easeOutExpo.transform(1 - value);

    final startOffset = Offset(
      lerpDouble(start.dx, end.dx, Curves.easeOutSine.transform(_value))!,
      lerpDouble(start.dy, end.dy, Curves.easeOutSine.transform(_value))!,
    );
    final endOffset = Offset(
      lerpDouble(start.dx, end.dx, Curves.easeOutExpo.transform(_value))!,
      lerpDouble(start.dy, end.dy, Curves.easeOutExpo.transform(_value))!,
    );
    final paint = Paint()
      ..color = fireWorksInfo.mainColor.withOpacity(colorOpacityValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = fireWorksInfo.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(startOffset, endOffset, paint);
  }

  @override
  bool shouldRepaint(FireWorksPainter oldDelegate) => oldDelegate.value != value;
}
