import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MacDockPage extends StatefulWidget {
  const MacDockPage({Key? key}) : super(key: key);

  @override
  MacDockPageState createState() => MacDockPageState();
}

class MacDockPageState extends State<MacDockPage> with TickerProviderStateMixin {
  static final items = List.generate(10, (index) => index);
  static const horizontalPaddingPerItem = 2.0;
  static const paddingPerItem = horizontalPaddingPerItem * 2;
  static const maxLengthScale = 1.3;
  static const animatedItemsCount = 2;

  late final AnimationController startEndAnimationController;

  @override
  void initState() {
    super.initState();
    startEndAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        final localPositionX = this.latestLocalPositionX;
        if (localPositionX == null) {
          return;
        }
        final maxWidth = (context.findRenderObject() as RenderBox?)?.size.width;
        if (maxWidth == null) {
          return;
        }
        final touchPositionInItemWidth = localPositionX / (maxWidth / items.length);
        final currentIndex = touchPositionInItemWidth.floor();
        final defaultItemWidth = _calculateDefaultItemWidth(maxWidth);
        final animatedItemLength = Tween<double>(begin: defaultItemWidth, end: defaultItemWidth * maxLengthScale)
            .transform(startEndAnimationController.value);

        final otherItemLength = (maxWidth - paddingPerItem * items.length - animatedItemLength) / (items.length - 1);
        setState(() {
          // widthを更新する
          itemWidths = items
              .mapIndexed((index, element) => index == currentIndex ? animatedItemLength : otherItemLength)
              .toList();
          print("anim: ${startEndAnimationController.value}");
        });
      });
  }

  @override
  void dispose() {
    startEndAnimationController.dispose();
    super.dispose();
  }

  List<double> itemWidths = [];

  double? latestLocalPositionX;

  double? latestPercent;

  double _calculateDefaultItemWidth(double allWidth) =>
      (allWidth - horizontalPaddingPerItem * 2 * items.length) / items.length;

  List<double> calculateItemWidths(double maxWidth, double localPositionX) {
    final defaultItemWidth = _calculateDefaultItemWidth(maxWidth);
    final touchPositionInItemWidth = localPositionX / (maxWidth / items.length);
    final currentIndex = touchPositionInItemWidth.floor();
    final itemBoundWidth = maxWidth / items.length;
    final currentPercent = 1 - (touchPositionInItemWidth - (currentIndex + 0.5)).abs() / 0.5;
    final animatedItemLengths = List.generate(items.length, (index) => index).map((index) {
      final distanceFromIndexToTouchPosition = (touchPositionInItemWidth - (index + 0.5)).abs();
      if (distanceFromIndexToTouchPosition <= animatedItemsCount) {
        final currentIndexLocalPositionX = itemBoundWidth * (index + 0.5);
        final currentPercentTemp = (localPositionX - currentIndexLocalPositionX).abs() / (2 * itemBoundWidth);
        final startScale = (1 - (currentIndex - index).abs() / animatedItemsCount) * maxLengthScale;
        final endScale =
            ((1 - (currentIndex - index).abs() + (animatedItemsCount - 1)) / animatedItemsCount) * maxLengthScale;
        final animatedItemLength = Tween<double>(
          begin: defaultItemWidth + defaultItemWidth * startScale,
          end: defaultItemWidth + defaultItemWidth * endScale,
        ).transform(currentPercentTemp);
        return animatedItemLength;
      } else {
        return null;
      }
    }).toList();
    final otherItemLength = (maxWidth - paddingPerItem * items.length - animatedItemLengths.whereNotNull().sum) /
        (items.length - animatedItemLengths.length);
    return animatedItemLengths.map((e) => e ?? otherItemLength).toList();
  }

  void _onDragStart(DragStartDetails details) {
    latestLocalPositionX = details.localPosition.dx;
    startEndAnimationController.forward(from: 0);
  }

  void _onDragUpdate(double maxWidth, DragUpdateDetails details) {
    if (startEndAnimationController.isAnimating) {
      return;
    }
    latestLocalPositionX = details.localPosition.dx;
    setState(() {
      itemWidths = calculateItemWidths(maxWidth, details.localPosition.dx);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final latestPercent = this.latestPercent;
    if (latestPercent == null) {
      return;
    }
    startEndAnimationController.reverse(from: latestPercent);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SizedBox(
            height: 100,
            child: LayoutBuilder(
              builder: (context, constrains) => GestureDetector(
                onPanStart: _onDragStart,
                onPanUpdate: (details) => _onDragUpdate(constrains.maxWidth, details),
                onPanEnd: _onDragEnd,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: items
                      .mapIndexed(
                        (index, _) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPaddingPerItem),
                          child: Container(
                            width: itemWidths.isNotEmpty
                                ? itemWidths[index]
                                : _calculateDefaultItemWidth(constrains.maxWidth),
                            height: itemWidths.isNotEmpty
                                ? itemWidths[index]
                                : _calculateDefaultItemWidth(constrains.maxWidth),
                            color: Colors.redAccent,
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      );
}

Widget _calculateItemWidth({
  required double viewWidth,
  required int itemCount,
  required double horizontalPaddingPerItem,
  required int itemIndex,
  required double? touchPercent,
  required Widget child,
}) {
  final paddingPerItem = horizontalPaddingPerItem * 2;
  final defaultItemWidth = (viewWidth - paddingPerItem * itemCount) / itemCount;
  if (touchPercent == null) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: child,
      ),
    );
  }
  final distanceFromCurrentIndexToTouchPosition = (touchPercent - (itemIndex + 0.5)).abs();
  if (distanceFromCurrentIndexToTouchPosition <= 3) {
    final percent = 1 - distanceFromCurrentIndexToTouchPosition / 3;
    final squareLength = Tween<double>(begin: defaultItemWidth, end: defaultItemWidth * 1.4)
        .transform(Curves.easeOut.transform(percent));
    print("touchPercent: ${touchPercent}");
    print("itemIndex: ${itemIndex}");
    print("distanceFromCurrentIndexToTouchPosition: ${distanceFromCurrentIndexToTouchPosition}");
    return SizedBox.square(
      dimension: squareLength,
      child: child,
    );
  }
  return Expanded(
    child: AspectRatio(
      aspectRatio: 1,
      child: child,
    ),
  );
}
