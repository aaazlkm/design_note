import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// scale処理
// bounceの処理のパッケージがあったはずなので、そちら参考にしてみる
// tapしてる時のgradient処理をする

class AirbnbButtonPage extends StatefulWidget {
  const AirbnbButtonPage({Key? key}) : super(key: key);

  @override
  AirbnbButtonPageState createState() => AirbnbButtonPageState();
}

class AirbnbButtonPageState extends State<AirbnbButtonPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: GradientAirbnbButton(),
        ),
      );
}

class GradientAirbnbButton extends StatefulWidget {
  const GradientAirbnbButton({Key? key}) : super(key: key);

  @override
  State<GradientAirbnbButton> createState() => _GradientAirbnbButtonState();
}

class _GradientAirbnbButtonState extends State<GradientAirbnbButton> with TickerProviderStateMixin {
  num get baseStop => buttonScaleAnimationController
      .drive(
        CurveTween(
          curve: const Interval(0, 1, curve: Curves.linear),
        ),
      )
      .drive(
        Tween(begin: 0, end: 0.02),
      )
      .value;

  bool isPanning = false;

  late final AnimationController centerAnimationController;

  late final AnimationController buttonScaleAnimationController;

  late final AnimationController gradientAnimationController;

  Alignment center = Alignment.topLeft;

  Alignment? nextCenter = null;

  @override
  void initState() {
    super.initState();
    centerAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            center = nextCenter!;
            nextCenter = null;
          });
        }
      });
    buttonScaleAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !isPanning) {
          buttonScaleAnimationController.reverse();
        }
      });
    gradientAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    centerAnimationController.dispose();
    buttonScaleAnimationController.dispose();
    gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (details) {
          print("onTapDown");
          buttonScaleAnimationController.forward();
          gradientAnimationController.forward();
        },
        onTapUp: (details) {
          print("onTapUp");
          HapticFeedback.lightImpact();

          if (!buttonScaleAnimationController.isAnimating) {
            buttonScaleAnimationController.reverse();
          }
          gradientAnimationController.reverse();
        },
        onPanDown: (details) {
          print("onPanDown");
          final renderObject = context.findRenderObject() as RenderBox;
          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          setState(() {
            isPanning = true;
            nextCenter = Alignment(
              (2 * xPercent - 1).clamp(-1, 1),
              (2 * yPercent - 1).clamp(-1, 1),
            );
            centerAnimationController.forward(from: 0);
          });
        },
        onPanStart: (details) {
          final renderObject = context.findRenderObject() as RenderBox;
          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          setState(() {
            isPanning = true;
            nextCenter = Alignment(
              (2 * xPercent - 1).clamp(-1, 1),
              (2 * yPercent - 1).clamp(-1, 1),
            );
          });
          centerAnimationController.forward(from: 0);
        },
        onPanUpdate: (details) {
          isPanning = true;
          print("onPanUpdate");
          final renderObject = context.findRenderObject() as RenderBox;
          final xPercent = details.localPosition.dx / renderObject.size.width;
          final yPercent = details.localPosition.dy / renderObject.size.height;
          if (centerAnimationController.isAnimating) {
            centerAnimationController.stop();
          }
          setState(() {
            nextCenter = null;
            center = Alignment(
              (2 * xPercent - 1).clamp(-1, 1),
              (2 * yPercent - 1).clamp(-1, 1),
            );
          });
        },
        onPanEnd: (details) {
          HapticFeedback.lightImpact();

          isPanning = false;
          print("onPanEnd");
          setState(() {
            nextCenter = Alignment.topLeft;
          });
          centerAnimationController.forward(from: 0);
          buttonScaleAnimationController.reverse();
          gradientAnimationController.reverse();
        },
        onPanCancel: () {
          isPanning = false;
          setState(() {
            nextCenter = Alignment.topLeft;
          });
          centerAnimationController.forward(from: 0);
          print("onPanCancel");
        },
        child: ScaleTransition(
          scale: buttonScaleAnimationController
              .drive(
                CurveTween(
                  curve: const Interval(0, 1, curve: Curves.easeInOut),
                ),
              )
              .drive(
                Tween(begin: 1, end: 0.95),
              ),
          child: AnimatedBuilder(
            animation: centerAnimationController,
            builder: (context, child) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: nextCenter != null
                        ? centerAnimationController
                            .drive(
                              Tween(begin: center, end: nextCenter),
                            )
                            .value
                        : center,
                    radius: 4,
                    colors: [
                      Colors.red.shade500,
                      Colors.pink.shade400,
                      Colors.pink.shade500,
                      Colors.pink.shade600,
                      Colors.purple.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Text(
                    "airbnb button",
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// class AirbnbButton extends StatefulWidget {
//   const AirbnbButton({Key? key}) : super(key: key);
//
//   @override
//   State<AirbnbButton> createState() => _AirbnbButtonState();
// }
//
// class _AirbnbButtonState extends State<AirbnbButton> with TickerProviderStateMixin {
//   Alignment center = Alignment.center;
//
//   num get baseStop => buttonScaleAnimationController
//       .drive(
//         CurveTween(
//           curve: const Interval(0, 1, curve: Curves.linear),
//         ),
//       )
//       .drive(
//         Tween(begin: 0, end: 0.02),
//       )
//       .value;
//
//   late final AnimationController buttonScaleAnimationController;
//
//   late final AnimationController gradientAnimationController;
//
//   @override
//   void initState() {
//     super.initState();
//     buttonScaleAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
//     gradientAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
//   }
//
//   @override
//   void dispose() {
//     buttonScaleAnimationController.dispose();
//     gradientAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTapDown: (details) {
//           print("onTapDown");
//           buttonScaleAnimationController.forward();
//           gradientAnimationController.forward();
//         },
//         onTapUp: (details) {
//           print("onTapUp");
//           buttonScaleAnimationController.reverse();
//           gradientAnimationController.reverse();
//         },
//         onPanDown: (details) {
//           print("onPanDown");
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanStart: (details) {
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanUpdate: (details) {
//           print("onPanUpdate");
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanEnd: (details) {
//           print("onPanEnd");
//           buttonScaleAnimationController.reverse();
//           gradientAnimationController.reverse();
//         },
//         onPanCancel: () {
//           print("onPanCancel");
//         },
//         child: ScaleTransition(
//           scale: buttonScaleAnimationController
//               .drive(
//                 CurveTween(
//                   curve: const Interval(0, 1, curve: Curves.easeInOut),
//                 ),
//               )
//               .drive(
//                 Tween(begin: 1, end: 0.95),
//               ),
//           child: AnimatedBuilder(
//             animation: buttonScaleAnimationController,
//             builder: (context, child) => ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Stack(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Colors.pink.shade300,
//                           Colors.pink.shade500,
//                           Colors.pink.shade600,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 12,
//                         horizontal: 20,
//                       ),
//                       child: Text(
//                         "airbnb button",
//                         style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                       ),
//                     ),
//                   ),
//                   Positioned.fill(
//                     child: Align(
//                       alignment: center,
//                       child: FadeTransition(
//                         opacity: gradientAnimationController.drive(
//                           Tween(begin: 0, end: 1),
//                         ),
//                         child: Transform.scale(
//                           scale: 40,
//                           child: Container(
//                             height: 10,
//                             width: 10,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(50),
//                               gradient: RadialGradient(
//                                 colors: [
//                                   Colors.orange.shade500.withOpacity(0.2),
//                                   Colors.orange.shade500.withOpacity(0.2),
//                                   Colors.orange.shade400.withOpacity(0.1),
//                                   Colors.transparent,
//                                   Colors.transparent,
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
// }

//
// class AirbnbButton extends StatefulWidget {
//   const AirbnbButton({Key? key}) : super(key: key);
//
//   @override
//   State<AirbnbButton> createState() => _AirbnbButtonState();
// }
//
// class _AirbnbButtonState extends State<AirbnbButton> with SingleTickerProviderStateMixin {
//   Gradient get defaultGradient => RadialGradient(
//         center: Alignment.center,
//         colors: [
//           Colors.pink.shade400,
//           Colors.pink.shade500,
//           Colors.pink.shade600,
//         ],
//         radius: 10,
//       );
//
//   List<Color> get colors => [
//         Colors.yellow.shade400.withOpacity(0.9),
//         Colors.pink.shade400,
//         Colors.pink.shade500,
//         Colors.pink.shade600,
//       ];
//
//   Alignment center = Alignment.center;
//
//   num get baseStop => animationController
//       .drive(
//         CurveTween(
//           curve: const Interval(0, 1, curve: Curves.linear),
//         ),
//       )
//       .drive(
//         Tween(begin: 0, end: 0.02),
//       )
//       .value;
//
//   late final AnimationController animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
//   }
//
//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTapDown: (details) {
//           print("onTapDown");
//           animationController.forward();
//         },
//         onTapUp: (details) {
//           print("onTapUp");
//           animationController.reverse();
//         },
//         onPanDown: (details) {
//           print("onPanDown");
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanStart: (details) {
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanUpdate: (details) {
//           print("onPanUpdate");
//           final renderObject = context.findRenderObject() as RenderBox;
//           final xPercent = details.localPosition.dx / renderObject.size.width;
//           final yPercent = details.localPosition.dy / renderObject.size.height;
//           setState(() {
//             center = Alignment(
//               2 * xPercent - 1,
//               2 * yPercent - 1,
//             );
//           });
//         },
//         onPanEnd: (details) {
//           print("onPanEnd");
//           animationController.reverse();
//         },
//         onPanCancel: () {
//           print("onPanCancel");
//         },
//         child: ScaleTransition(
//           scale: animationController
//               .drive(
//                 CurveTween(
//                   curve: const Interval(0, 1, curve: Curves.easeInOut),
//                 ),
//               )
//               .drive(
//                 Tween(begin: 1, end: 0.95),
//               ),
//           child: AnimatedBuilder(
//             animation: animationController,
//             builder: (context, child) => Container(
//               decoration: BoxDecoration(
//                 gradient: Gradient.lerp(
//                   defaultGradient,
//                   RadialGradient(
//                     center: center,
//                     colors: colors,
//                     radius: 100,
//                   ),
//                   animationController.value,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12,
//                   horizontal: 20,
//                 ),
//                 child: Text(
//                   "airbnb button",
//                   style: Theme.of(context).textTheme.bodyText1!.copyWith(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
// }
