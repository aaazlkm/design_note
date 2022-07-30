import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MaterialDesignChipPage extends StatefulWidget {
  const MaterialDesignChipPage({Key? key}) : super(key: key);

  @override
  State<MaterialDesignChipPage> createState() => _MaterialDesignChipPageState();
}

class _MaterialDesignChipPageState extends State<MaterialDesignChipPage> {
  bool isSelected = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: Center(
            child: _Chip(
              isChecked: isSelected,
              text: "chip chip",
              onChecked: (checked) {
                print("checked $checked");
                setState(() {
                  isSelected = checked;
                });
              },
            ),
          ),
        ),
      );
}

class _Chip extends StatefulWidget {
  _Chip({
    required this.isChecked,
    required this.text,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    Color? backgroundColor,
    Color? backgroundColorChecked,
    this.onChecked,
    Key? key,
  })  : backgroundColor = backgroundColor ?? Colors.grey.shade200,
        backgroundColorChecked = backgroundColorChecked ?? Colors.grey.shade400,
        super(key: key);

  final bool isChecked;
  final String text;
  final Color backgroundColor;
  final Color backgroundColorChecked;
  final BorderRadius borderRadius;
  final Duration duration;
  final Function(bool)? onChecked;

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: widget.isChecked ? widget.backgroundColor : widget.backgroundColorChecked,
        end: widget.isChecked ? widget.backgroundColorChecked : widget.backgroundColor,
      ),
      curve: Curves.easeInOut,
      duration: widget.duration,
      builder: (context, value, child) => Material(
            color: value,
            borderRadius: widget.borderRadius,
            child: InkWell(
              borderRadius: widget.borderRadius,
              onTap: () => widget.onChecked?.call(!widget.isChecked),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: widget.isChecked ? 1 : 0,
                      duration: widget.duration,
                      curve: Curves.easeInOut,
                      child: AnimatedSize(
                        duration: widget.duration,
                        curve: Curves.easeInOut,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.black,
                              size: widget.isChecked ? 16 : 0,
                            ),
                            SizedBox(width: widget.isChecked ? 4 : 0),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
}
