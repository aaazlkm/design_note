import 'dart:math';
import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class PayPayCardPage extends StatefulWidget {
  const PayPayCardPage({Key? key}) : super(key: key);

  @override
  _PayPayCardPageState createState() => _PayPayCardPageState();
}

enum CardStatus { front, back }

class _PayPayCardPageState extends State<PayPayCardPage> {
  CardStatus cardStatus = CardStatus.front;

  int cardIndex = 1;

  Widget buildPayPayCard(BuildContext context, CardStatus cardStatus) {
    switch (cardStatus) {
      case CardStatus.front:
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          child: InkWell(
            onTap: () {
              setState(() {
                this.cardStatus = CardStatus.back;
              });
            },
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: 'https://pub.dev/packages/barcode_widget',
                      drawText: false,
                      height: 60,
                    ),
                    Expanded(
                      child: Icon(
                        Icons.adb,
                        size: 40,
                        color: Colors.grey.shade700,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      case CardStatus.back:
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          child: InkWell(
            onTap: () {
              setState(() {
                this.cardStatus = CardStatus.front;
              });
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Avaiable amount",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Text(
                        "343,439",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        "yen",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blueGrey.shade100,
        body: SafeArea(
          child: Center(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade900.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500),
                      tween: Tween(begin: 0, end: cardStatus == CardStatus.back ? 1 : 0),
                      curve: Curves.easeInOutCubic,
                      builder: (context, value, snapshot) => Opacity(
                        opacity: value,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade900.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(0, -3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) => PayPayCardAnimationBuilder(
                      cardStatus: cardStatus,
                      cardHeight: constraints.maxWidth * 0.8 / 1.618,
                      builder: (context, cardStatus) => Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 10,
                              blurRadius: 30,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.8,
                          height: constraints.maxWidth * 0.8 / 1.618,
                          child: buildPayPayCard(context, cardStatus),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500),
                      tween: Tween(begin: 0, end: cardStatus == CardStatus.front ? 1 : 0),
                      curve: Curves.easeInOutCubic,
                      builder: (context, value, snapshot) => Opacity(
                        opacity: value,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade900.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(0, -3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class PayPayCardAnimationBuilder extends StatefulWidget {
  const PayPayCardAnimationBuilder({
    required this.cardStatus,
    required this.builder,
    required this.cardHeight,
    Key? key,
  }) : super(key: key);

  final CardStatus cardStatus;
  final Widget Function(BuildContext context, CardStatus child) builder;
  final double cardHeight;

  @override
  _PayPayCardAnimationBuilderState createState() => _PayPayCardAnimationBuilderState();
}

class _PayPayCardAnimationBuilderState extends State<PayPayCardAnimationBuilder> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 500),
        tween: Tween(
          begin: 0.0,
          end: widget.cardStatus == CardStatus.front ? 0.0 : 1,
        ),
        builder: (context, value, child) => Transform(
          transform: Matrix4.translationValues(0, -sin(value * pi) * widget.cardHeight / 6, value * 100),
          alignment: Alignment.center,
          child: child,
        ),
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500),
          tween: Tween(
            begin: 0,
            end: widget.cardStatus == CardStatus.front ? 0.0 : 1,
          ),
          builder: (context, value, child) => Transform(
            transform: Matrix4.identity()..rotateX(value * pi),
            alignment: Alignment.center,
            child: value < 0.5
                ? widget.builder(context, CardStatus.front)
                : Transform(
                    transform: Matrix4.identity()..rotateX(pi),
                    alignment: Alignment.center,
                    child: widget.builder(context, CardStatus.back),
                  ),
          ),
        ),
      );
}
