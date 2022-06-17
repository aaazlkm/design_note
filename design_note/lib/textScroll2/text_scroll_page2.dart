import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextScrollPage2 extends StatefulWidget {
  const TextScrollPage2({Key? key}) : super(key: key);

  @override
  _TextScrollPage2State createState() => _TextScrollPage2State();
}

class _TextScrollPage2State extends State<TextScrollPage2> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final animationCurve = Interval(0.3, 0.7, curve: Curves.easeInOut);

  List<String> _labels = [
    "label1",
    "label2",
    "label3",
    "label4",
    "label5",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.forward(from: 0);
          _switchLabel();
        }
      })
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchLabel() {
    _labels = [..._labels.getRange(1, _labels.length), _labels.first];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ColoredBox(
            color: Colors.blueGrey[500]!,
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (availableSpace) => LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white,
                    Colors.white,
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.05, 0.3, 0.7, 0.95],
                ).createShader(availableSpace),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  color: Colors.blueGrey[500]!,
                  child: Stack(
                    children: [
                      FractionalTranslation(
                        translation: Offset(0, animationCurve.transform(_animationController.value) - 1),
                        child: Center(
                          child: Text(_labels[1]),
                        ),
                      ),
                      FractionalTranslation(
                        translation: Offset(0, animationCurve.transform(_animationController.value)),
                        child: Center(
                          child: Text(_labels.first),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
