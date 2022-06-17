import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class FlippingCardPage extends StatefulWidget {
  const FlippingCardPage({Key? key}) : super(key: key);

  @override
  _FlippingCardPageState createState() => _FlippingCardPageState();
}

final List<Color> _colors = [Colors.red, Colors.green, Colors.blue];

class _FlippingCardPageState extends State<FlippingCardPage> {
  int selectableColorIndex = 0;

  void _updateIndex(int index) {
    setState(() {
      selectableColorIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FlippingCard(
                    color: _colors[selectableColorIndex],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text('0'),
                      onPressed: () {
                        _updateIndex(0);
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('1'),
                      onPressed: () {
                        _updateIndex(1);
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('2'),
                      onPressed: () {
                        _updateIndex(2);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}

class FlippingCard extends StatefulWidget {
  const FlippingCard({
    required this.color,
    Key? key,
  }) : super(key: key);

  final Color color;

  @override
  _FlippingCardState createState() => _FlippingCardState();
}

class _FlippingCardState extends State<FlippingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Color color1;
  late Color color2;
  late Color currentColor;

  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    color1 = widget.color;
    currentColor = widget.color;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 5000))
      ..addListener(() {
        setState(() {
          _rotation = pi * Curves.elasticOut.transform(_animationController.value);
          if (currentColor == color1 && _rotation > pi / 2) {
            currentColor = color2;
          } else if (currentColor == color2 && _rotation < pi / 2) {
            currentColor = color1;
          } else if (currentColor == color2) {
            _rotation = _rotation - pi;
          }
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onRotationComplete();
        }
      });
  }

  @override
  void didUpdateWidget(covariant FlippingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color != oldWidget.color) {
      immediatelyFinishCurrentAnimation();
      color2 = widget.color;
      _flipCard();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void immediatelyFinishCurrentAnimation() {
    if (_animationController.isAnimating) {
      _animationController.stop();
      color1 = color2;
      currentColor = color2;
    }
  }

  void _flipCard() {
    currentColor = color1;
    _animationController.forward(from: 0);
  }

  void _onRotationComplete() {
    setState(() {
      _animationController.value = 0;
      color1 = color2;
      currentColor = color2;
    });
  }

  @override
  Widget build(BuildContext context) => Transform(
        transform: Matrix4.identity()..rotateY(_rotation * 3),
        alignment: Alignment.center,
        child: Container(
          height: 200,
          width: 200 * 1.612,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(currentColor == _colors[0]
                ? "red"
                : currentColor == _colors[1]
                    ? "green"
                    : "blue"),
          ),
        ),
      );
}
