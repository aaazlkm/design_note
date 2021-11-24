import 'dart:math';

import 'package:flutter/material.dart';

class Lesson5Page extends StatefulWidget {
  const Lesson5Page({Key? key}) : super(key: key);

  @override
  Lesson5PageState createState() => Lesson5PageState();
}

class Lesson5PageState extends State<Lesson5Page> {
  Color _backgroundColor = selectableColors.first;

  void onColorChanged(Color spectrumColor, Color selectedColor) {
    setState(() {
      _backgroundColor = spectrumColor;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              height: 40,
              child: _ColorPicker(
                selectableColors: selectableColors,
                onColorChanged: onColorChanged,
              ),
            ),
          ),
        ),
      );
}

final selectableColors = [
  Colors.red.shade300,
  Colors.yellow.shade300,
  Colors.green.shade300,
  Colors.blue.shade300,
  Colors.purple.shade300,
];

class _ColorPicker extends StatefulWidget {
  const _ColorPicker({
    required this.selectableColors,
    required this.onColorChanged,
    Key? key,
  }) : super(key: key);

  final List<Color> selectableColors;
  final Function(Color spectrumColor, Color selectedColor) onColorChanged;

  @override
  __ColorPickerState createState() => __ColorPickerState();
}

class __ColorPickerState extends State<_ColorPicker> {
  void selectColors(Offset touchPosition) {
    // | |---| |---| |---| |---| |
    final renderBox = context.findRenderObject() as RenderBox;
    final colorBlobSpectrum =
        ColorBlobSpectrum.fromPhysicalDimensions(size: renderBox.size, selectableColors: widget.selectableColors);

    widget.onColorChanged(
      colorBlobSpectrum.calculateSpectrumColor(touchPosition.dx),
      colorBlobSpectrum.calculateSelectedColor(touchPosition.dx),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onPanDown: (details) {
          selectColors(details.localPosition);
        },
        onHorizontalDragUpdate: (details) {
          selectColors(details.localPosition);
        },
        child: ClipPath(
          clipper: BlobSpectrumClipper(
            colorCount: selectableColors.length,
            lineThickness: 10,
          ),
          child: _ColorSpectrum(
            colors: widget.selectableColors,
          ),
        ),
      );
}

class BlobSpectrumClipper extends CustomClipper<Path> {
  BlobSpectrumClipper({
    required this.colorCount,
    required this.lineThickness,
  });

  final int colorCount;
  final double lineThickness;

  @override
  Path getClip(Size size) {
    final path = Path();
    final blobDiameter = size.height;
    final separatorSpace = (size.width - blobDiameter * colorCount) / (colorCount - 1);

    for (var i = 0; i < colorCount; i++) {
      _addOval(path, size, blobDiameter, separatorSpace, i);

      if (i > 0) {
        _addTopLeftCurve(path, size, blobDiameter, separatorSpace, i);
        _addBottomLeftCurve(path, size, blobDiameter, separatorSpace, i);
      }

      if (i < colorCount - 1) {
        _addTopRightCurve(path, size, blobDiameter, separatorSpace, i);
        _addBottomRightCurve(path, size, blobDiameter, separatorSpace, i);
      }
    }

    _addHorizontalLine(path, size, lineThickness);

    return path;
  }

  void _addOval(Path path, Size availableSpace, double blobDiameter, double separatorSpace, int index) {
    final blobRadius = blobDiameter / 2;
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          blobRadius + (index * (blobDiameter + separatorSpace)),
          availableSpace.height / 2,
        ),
        radius: blobRadius,
      ),
    );
  }

  void _addTopRightCurve(Path path, Size availableSpace, double blobDiameter, double separatorSpace, int index) {
    final blobRadius = blobDiameter / 2;
    final circleCenter = Offset(
      blobRadius + (index * (blobDiameter + separatorSpace)),
      availableSpace.height / 2,
    );

    final pointOnCircle = Offset(blobRadius * cos(pi / 4), -blobRadius * cos(pi / 4)) + circleCenter;
    final pointOnLine = Offset(blobRadius * 2, -(lineThickness / 2)) + circleCenter;
    final connectingPoint = Offset(pointOnCircle.dx, pointOnLine.dy);
    final curvedControlPoint = Offset((connectingPoint.dy - pointOnCircle.dy).abs() * tan(pi / 4), 0) + connectingPoint;

    final curvedPath = Path()
      ..moveTo(pointOnCircle.dx, pointOnCircle.dy)
      ..quadraticBezierTo(curvedControlPoint.dx, curvedControlPoint.dy, pointOnLine.dx, pointOnLine.dy)
      ..lineTo(connectingPoint.dx, connectingPoint.dy)
      ..close();
    path.addPath(curvedPath, Offset.zero);
  }

  void _addBottomRightCurve(Path path, Size availableSpace, double blobDiameter, double separatorSpace, int index) {
    final blobRadius = blobDiameter / 2;
    final circleCenter = Offset(
      blobRadius + (index * (blobDiameter + separatorSpace)),
      availableSpace.height / 2,
    );

    final pointOnCircle = Offset(blobRadius * cos(pi / 4), blobRadius * cos(pi / 4)) + circleCenter;
    final pointOnLine = Offset(blobRadius * 2, lineThickness / 2) + circleCenter;
    final connectingPoint = Offset(pointOnCircle.dx, pointOnLine.dy);
    final curvedControlPoint = Offset((connectingPoint.dy - pointOnCircle.dy).abs() * tan(pi / 4), 0) + connectingPoint;

    final curvedPath = Path()
      ..moveTo(connectingPoint.dx, connectingPoint.dy)
      ..lineTo(pointOnLine.dx, pointOnLine.dy)
      ..quadraticBezierTo(curvedControlPoint.dx, curvedControlPoint.dy, pointOnCircle.dx, pointOnCircle.dy)
      ..close();
    path.addPath(curvedPath, Offset.zero);
  }

  void _addTopLeftCurve(Path path, Size availableSpace, double blobDiameter, double separatorSpace, int index) {
    final blobRadius = blobDiameter / 2;
    final circleCenter = Offset(
      blobRadius + (index * (blobDiameter + separatorSpace)),
      availableSpace.height / 2,
    );

    final pointOnCircle = Offset(-blobRadius * cos(pi / 4), -blobRadius * cos(pi / 4)) + circleCenter;
    final pointOnLine = Offset(-blobRadius * 2, -(lineThickness / 2)) + circleCenter;
    final connectingPoint = Offset(pointOnCircle.dx, pointOnLine.dy);
    final curvedControlPoint =
        Offset(-(connectingPoint.dy - pointOnCircle.dy).abs() * tan(pi / 4), 0) + connectingPoint;

    final curvedPath = Path()
      ..moveTo(pointOnLine.dx, pointOnLine.dy)
      ..quadraticBezierTo(curvedControlPoint.dx, curvedControlPoint.dy, pointOnCircle.dx, pointOnCircle.dy)
      ..lineTo(connectingPoint.dx, connectingPoint.dy)
      ..close();
    path.addPath(curvedPath, Offset.zero);
  }

  void _addBottomLeftCurve(Path path, Size availableSpace, double blobDiameter, double separatorSpace, int index) {
    final blobRadius = blobDiameter / 2;
    final circleCenter = Offset(
      blobRadius + (index * (blobDiameter + separatorSpace)),
      availableSpace.height / 2,
    );

    final pointOnCircle = Offset(-blobRadius * cos(pi / 4), blobRadius * cos(pi / 4)) + circleCenter;
    final pointOnLine = Offset(-blobRadius * 2, lineThickness / 2) + circleCenter;
    final connectingPoint = Offset(pointOnCircle.dx, pointOnLine.dy);
    final curvedControlPoint =
        Offset(-(connectingPoint.dy - pointOnCircle.dy).abs() * tan(pi / 4), 0) + connectingPoint;

    final curvedPath = Path()
      ..moveTo(pointOnCircle.dx, pointOnCircle.dy)
      ..quadraticBezierTo(curvedControlPoint.dx, curvedControlPoint.dy, pointOnLine.dx, pointOnLine.dy)
      ..lineTo(connectingPoint.dx, connectingPoint.dy)
      ..close();
    path.addPath(curvedPath, Offset.zero);
  }

  void _addHorizontalLine(Path path, Size availableSpace, double lineThickness) {
    path.addRect(
      Rect.fromLTWH(
        0,
        (availableSpace.height - lineThickness) / 2,
        availableSpace.width,
        lineThickness,
      ),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _ColorSpectrum extends StatelessWidget {
  const _ColorSpectrum({
    required this.colors,
    Key? key,
  }) : super(key: key);

  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
          ),
        ),
      );
}

class ColorBlobSpectrum {
  ColorBlobSpectrum({
    required this.blobDiameter,
    required this.spectrumWidth,
    required this.selectableColors,
  }) : blobRadius = blobDiameter / 2;

  factory ColorBlobSpectrum.fromPhysicalDimensions({
    required Size size,
    required List<Color> selectableColors,
  }) =>
      ColorBlobSpectrum(
        blobDiameter: size.height,
        spectrumWidth: size.width,
        selectableColors: selectableColors,
      );

  final double blobDiameter;
  final double blobRadius;
  final double spectrumWidth;
  final List<Color> selectableColors;
  late final colorCount = selectableColors.length;
  late final double separatorSpace = (spectrumWidth - blobDiameter * colorCount) / (colorCount - 1);

  Color calculateSelectedColor(double touchX) {
    final separatorSpace = (spectrumWidth - blobDiameter * colorCount) / (colorCount - 1);
    final position = touchX.clamp(0.0, spectrumWidth);
    final fractionalTouchPosition =
        ((position - blobRadius) / (blobDiameter + separatorSpace)).clamp(0.0, (colorCount - 1).toDouble());

    final leftSideIndex = fractionalTouchPosition.floor();
    final rightSideIndex = fractionalTouchPosition.ceil();

    final leftColor = selectableColors[leftSideIndex];
    final rightColor = selectableColors[rightSideIndex];

    final percent = fractionalTouchPosition - leftSideIndex;

    return percent <= 0.5 ? leftColor : rightColor;
  }

  Color calculateSpectrumColor(double touchX) {
    final position = touchX.clamp(0.0, spectrumWidth);
    final fractionalTouchPosition =
        ((position - blobRadius) / (blobDiameter + separatorSpace)).clamp(0.0, (colorCount - 1).toDouble());

    final leftSideIndex = fractionalTouchPosition.floor();
    final rightSideIndex = fractionalTouchPosition.ceil();

    final leftColor = selectableColors[leftSideIndex];
    final rightColor = selectableColors[rightSideIndex];

    final percent = fractionalTouchPosition - leftSideIndex;

    final spectrumColor = Color.lerp(leftColor, rightColor, percent);
    if (spectrumColor == null) {
      throw Exception("fialed to lefp color");
    }

    return spectrumColor;
  }
}
