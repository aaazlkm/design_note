import 'package:flutter/material.dart';

class FilterChipPage extends StatelessWidget {
  const FilterChipPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterChip(
                text: "FilterChip",
                color: Colors.blueGrey[200]!,
                duration: Duration(milliseconds: 200),
              ),
              SizedBox(width: 10),
              FilterChip(
                text: "FilterChip",
                color: Colors.greenAccent[200]!,
                duration: Duration(milliseconds: 300),
              ),
              SizedBox(width: 10),
              FilterChip(
                text: "FilterChip",
                color: Colors.purple[200]!,
                duration: Duration(milliseconds: 1000),
              ),
            ],
          ),
        ),
      );
}

class FilterChip extends StatefulWidget {
  FilterChip({
    required this.text,
    required this.color,
    this.duration = const Duration(milliseconds: 500),
    this.chipHeight = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    Key? key,
  }) : super(key: key);

  final String text;
  final Color color;
  final double chipHeight;
  final BorderRadius borderRadius;
  final Duration duration;

  @override
  State<FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<FilterChip> {
  double get horizontalPadding => 16;

  double get circleSize => 12;

  bool isSelected = true;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: isSelected ? 10 : 0),
        duration: widget.duration,
        curve: Curves.easeInOut,
        builder: (context, value, child) => Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: value,
              ),
            ],
          ),
          child: child,
        ),
        child: Material(
          color: Colors.grey[200],
          borderRadius: widget.borderRadius,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              children: [
                Positioned(
                  left: horizontalPadding - circleSize / 2,
                  top: widget.chipHeight / 2 - circleSize / 2,
                  child: AnimatedScale(
                    duration: widget.duration,
                    scale: isSelected ? 20 : 1,
                    curve: Curves.easeInOut,
                    child: Material(
                      color: widget.color,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: SizedBox(
                        width: circleSize,
                        height: circleSize,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: widget.borderRadius,
                  onTap: () => setState(() => isSelected = !isSelected),
                  child: SizedBox(
                    height: widget.chipHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: horizontalPadding),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: isSelected ? 0 : circleSize),
                          duration: widget.duration,
                          curve: Curves.easeInOut,
                          builder: (context, value, chid) => SizedBox(
                            width: value,
                          ),
                        ),
                        Text(
                          widget.text,
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                color: Colors.black.withOpacity(0.8),
                              ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: isSelected ? 4 : 0),
                          duration: widget.duration,
                          curve: Curves.easeInOut,
                          builder: (context, value, chid) => SizedBox(
                            width: value,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: isSelected ? 14 : 0),
                          duration: widget.duration,
                          curve: Curves.easeInOut,
                          builder: (context, value, chid) => Icon(
                            Icons.close,
                            size: value,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(width: horizontalPadding),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
