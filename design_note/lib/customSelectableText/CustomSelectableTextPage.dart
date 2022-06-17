import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSelectableTextPage extends StatefulWidget {
  const CustomSelectableTextPage({Key? key}) : super(key: key);

  @override
  _CustomSelectableTextStatePage createState() => _CustomSelectableTextStatePage();
}

class _CustomSelectableTextStatePage extends State<CustomSelectableTextPage> {
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _CustomSelectableText(
                text:
                    'Flutter is Google\'s UI toolkit for building beautiful,\n natively compiled applications for mobile, web, and\n desktop from a single codebase',
              ),
            ),
          ),
        ),
      );
}

class _CustomSelectableText extends StatefulWidget {
  const _CustomSelectableText({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  State<_CustomSelectableText> createState() => _CustomSelectableTextState();
}

class _CustomSelectableTextState extends State<_CustomSelectableText> {
  final textKey = GlobalKey();
  final List<Rect> _textRectangles = [];
  final List<Rect> _selectionRectangles = [];
  Rect _caretRectangle = Rect.zero;
  MouseCursor mouseCursor = SystemMouseCursors.basic;

  int _selectionBaseOffset = 0;
  TextSelection _textSelection = TextSelection.collapsed(offset: -1);

  RenderParagraph get _renderParagraph => textKey.currentContext!.findRenderObject() as RenderParagraph;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      updateAllTextRectangles();
    });
  }

  void updateAllTextRectangles() {
    setState(() {
      _textRectangles
        ..clear()
        ..addAll(
          _computeRectanglesForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: widget.text.length,
            ),
          ),
        );
    });
  }

  List<Rect> _computeRectanglesForSelection(TextSelection textSelection) {
    final textBoxes = _renderParagraph.getBoxesForSelection(textSelection);
    return textBoxes.map((e) => e.toRect()).toList();
  }

  void _onPointerHover(PointerHoverEvent event) {
    final allTextRectangle = _computeRectanglesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: widget.text.length,
      ),
    );
    var isTextOver = false;
    for (final textRectangle in allTextRectangle) {
      if (textRectangle.contains(event.localPosition)) {
        isTextOver = true;
      }
    }
    final newMouseCursor = isTextOver ? SystemMouseCursors.text : SystemMouseCursors.basic;
    if (mouseCursor != newMouseCursor) {
      setState(() {
        mouseCursor = newMouseCursor;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    _selectionBaseOffset = _renderParagraph.getPositionForOffset(details.localPosition).offset;
    _textSelection = TextSelection.collapsed(offset: _selectionBaseOffset);
    _updateTextSelectionDisplay();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final selectionExtentOffset = _renderParagraph.getPositionForOffset(details.localPosition).offset;
    _textSelection = TextSelection(
      baseOffset: _selectionBaseOffset,
      extentOffset: selectionExtentOffset,
    );
    _updateTextSelectionDisplay();
  }

  void _onPanEnd(DragEndDetails details) {
    // TODO
  }

  void _onPanCancel() {
    // TODO
  }

  void _updateTextSelectionDisplay() {
    final caretOffset = _renderParagraph.getOffsetForCaret(_textSelection.extent, Rect.zero);
    final caretHeight = _renderParagraph.getFullHeightForCaret(_textSelection.extent);
    setState(() {
      _caretRectangle = Rect.fromLTWH(caretOffset.dx - 1, caretOffset.dy, 1, caretHeight!);
      _selectionRectangles
        ..clear()
        ..addAll(_computeRectanglesForSelection(_textSelection));
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Listener(
          onPointerHover: _onPointerHover,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onPanCancel: _onPanCancel,
            child: MouseRegion(
              cursor: mouseCursor,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _SelectionPainter(
                      color: Colors.grey,
                      rects: _textRectangles,
                      fill: false,
                    ),
                  ),
                  CustomPaint(
                    painter: _SelectionPainter(
                      color: Colors.yellowAccent,
                      rects: _selectionRectangles,
                    ),
                  ),
                  Text(
                    'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase',
                    key: textKey,
                  ),
                  CustomPaint(
                    painter: _SelectionPainter(
                      color: Colors.blue,
                      rects: [_caretRectangle],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required Color color,
    required List<Rect> rects,
    bool fill = true,
  })  : _color = color,
        _rects = rects,
        _fill = fill,
        _paint = Paint()..color = color;

  final Color _color;
  final bool _fill;
  final List<Rect> _rects;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.style = _fill ? PaintingStyle.fill : PaintingStyle.stroke;
    for (final rect in _rects) {
      canvas.drawRect(rect, _paint);
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter other) => true;
}
