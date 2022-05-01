import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PhotoshopColorPickerPage extends StatefulWidget {
  const PhotoshopColorPickerPage({Key? key}) : super(key: key);

  @override
  PhotoshopColorPickerPageState createState() =>
      PhotoshopColorPickerPageState();
}

class PhotoshopColorPickerPageState extends State<PhotoshopColorPickerPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: PhotoShopColorPicker(),
        ),
      );
}

class PhotoShopColorPicker extends StatefulWidget {
  const PhotoShopColorPicker({
    Key? key,
  }) : super(key: key);

  @override
  State<PhotoShopColorPicker> createState() => _PhotoShopColorPickerState();
}

class _PhotoShopColorPickerState extends State<PhotoShopColorPicker> {
  HSVColor _selectedColor = const HSVColor.fromAHSV(1, 3, 1, 1);

  @override
  Widget build(BuildContext context) => Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constrains) => SizedBox(
                  height: constrains.maxWidth * 0.6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: constrains.maxWidth * 0.1,
                        color: _selectedColor.toColor(),
                      ),
                      SizedBox(width: 16),
                      SizedBox.fromSize(
                        size: Size.square(constrains.maxWidth * 0.6),
                        child: _ColorPicker(
                          hsvColor: _selectedColor,
                          onColorUpdated: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: constrains.maxWidth * 0.1,
                        color: Colors.red,
                        child: _HuePicker(
                          hue: _selectedColor.hue,
                          onHueUpdated: (hue) {
                            setState(() {
                              _selectedColor = _selectedColor.withHue(hue);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "r: ${_selectedColor.toColor().red}, b: ${_selectedColor.toColor().blue}, g: ${_selectedColor.toColor().green}",
              ),
              Text(
                "h: ${_selectedColor.hue.ceil()}, s: ${_selectedColor.saturation}, v: ${_selectedColor.value}",
              ),
            ],
          ),
        ),
      );
}

class _ColorPicker extends StatefulWidget {
  const _ColorPicker({
    required this.hsvColor,
    required this.onColorUpdated,
    Key? key,
  }) : super(key: key);

  final HSVColor hsvColor;
  final Function(HSVColor) onColorUpdated;

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  void _onDragStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final size = renderBox.size;
    final saturationPercent =
        (details.localPosition.dx / size.width).clamp(0.0, 1.0);
    final brightPercent =
        1 - (details.localPosition.dy / size.height).clamp(0.0, 1.0);
    widget.onColorUpdated(
      widget.hsvColor
          .withSaturation(saturationPercent)
          .withValue(brightPercent),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final size = renderBox.size;
    final saturationPercent =
        (details.localPosition.dx / size.width).clamp(0.0, 1.0);
    final brightPercent =
        1 - (details.localPosition.dy / size.height).clamp(0.0, 1.0);
    widget.onColorUpdated(
      widget.hsvColor
          .withSaturation(saturationPercent)
          .withValue(brightPercent),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constriants) => GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _ColorPainter(color: widget.hsvColor),
                ),
                Positioned(
                  top: constriants.maxHeight * (1 - widget.hsvColor.value),
                  left: constriants.maxWidth * widget.hsvColor.saturation,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
              ],
            ),
          ));
}

class _ColorPainter extends CustomPainter {
  _ColorPainter({required this.color});

  final HSVColor color;

  @override
  void paint(Canvas canvas, Size size) {
    final saturationShader = LinearGradient(
      colors: [
        HSVColor.fromAHSV(1, color.hue, 0, 1).toColor(),
        HSVColor.fromAHSV(1, color.hue, 1, 1).toColor(),
      ],
    ).createShader(Offset.zero & size);
    final saturationPaint = Paint()..shader = saturationShader;
    canvas.drawRect(Offset.zero & size, saturationPaint);

    final brightShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.black,
      ],
    ).createShader(Offset.zero & size);
    final brightPaint = Paint()
      ..shader = brightShader
      ..blendMode = BlendMode.modulate;
    canvas.drawRect(Offset.zero & size, brightPaint);
  }

  @override
  bool shouldRepaint(covariant _ColorPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _HuePicker extends StatefulWidget {
  const _HuePicker({
    required this.hue,
    required this.onHueUpdated,
    Key? key,
  }) : super(key: key);

  final double hue;
  final Function(double) onHueUpdated;

  @override
  State<_HuePicker> createState() => _HuePickerState();
}

class _HuePickerState extends State<_HuePicker> {
  void _onDragStart(DragStartDetails details) {
    final renderObject = context.findRenderObject() as RenderBox?;
    if (renderObject == null) {
      return;
    }
    final huePercent =
        (details.localPosition.dy / renderObject.size.height).clamp(0, 1);
    widget.onHueUpdated(huePercent * 360);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final renderObject = context.findRenderObject() as RenderBox?;
    if (renderObject == null) {
      return;
    }
    final huePercent =
        (details.localPosition.dy / renderObject.size.height).clamp(0, 1);
    widget.onHueUpdated(huePercent * 360);
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          GestureDetector(
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            child: CustomPaint(
              size: Size.infinite,
              painter: HuePickerPainter(),
            ),
          ),
          Align(
            alignment: Alignment(0, (widget.hue / 360) * 2 - 1),
            child: Container(
              width: double.infinity,
              height: 3,
              color: Colors.white,
            ),
          ),
        ],
      );
}

class HuePickerPainter extends CustomPainter {
  final numberOfColors = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ...List.generate(
          numberOfColors,
          (i) => HSVColor.fromAHSV(1, 360 / numberOfColors * i, 1, 1),
        ).map((e) => e.toColor()).toList(),
        const HSVColor.fromAHSV(1, 0, 1, 1).toColor(),
      ],
    ).createShader(Offset.zero & size);
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
