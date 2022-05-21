import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class DynamicSpringsPage extends StatefulWidget {
  const DynamicSpringsPage({Key? key}) : super(key: key);

  @override
  DynamicSpringsPageState createState() => DynamicSpringsPageState();
}

class DynamicSpringsPageState extends State<DynamicSpringsPage> with SingleTickerProviderStateMixin {
  final SpringDescription _springDescription = const SpringDescription(
    mass: 1,
    stiffness: 500,
    damping: 25,
  );
  Offset anchorOffset = Offset.zero;
  Offset iconOffset = Offset.zero;
  Ticker? springTicker;
  SpringSimulation? _springSimulationX;
  SpringSimulation? _springSimulationY;

  void _onTapDown(BoxConstraints constraints, TapDownDetails details) {
    setState(() {
      final touchOffset = details.localPosition - Size(constraints.maxWidth, constraints.maxHeight).center(Offset.zero);
      anchorOffset = touchOffset;
    });
    _endSpring();
    _startSpring();
  }

  void onDragStart(DragStartDetails details) {
    _endSpring();
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      iconOffset += details.delta;
    });
  }

  void onDragEnd(DragEndDetails details) {
    _startSpring();
  }

  void _startSpring() {
    _springSimulationX = SpringSimulation(
      _springDescription,
      iconOffset.dx,
      anchorOffset.dx,
      1,
    );
    _springSimulationY = SpringSimulation(
      _springDescription,
      iconOffset.dy,
      anchorOffset.dy,
      1,
    );
    springTicker ??= createTicker(_onTick);
    if (!(springTicker?.isTicking ?? true)) {
      springTicker?.start();
    }
  }

  void _endSpring() {
    springTicker?.stop();
    _springSimulationX = null;
    _springSimulationY = null;
  }

  void _onTick(Duration elapsed) {
    final springSimulationX = _springSimulationX;
    if (springSimulationX == null) {
      return;
    }
    final springSimulationY = _springSimulationY;
    if (springSimulationY == null) {
      return;
    }

    final elapsedSeconds = elapsed.inMilliseconds / 1000;
    setState(() {
      iconOffset = Offset(
        springSimulationX.x(elapsedSeconds),
        springSimulationY.x(elapsedSeconds),
      );
    });
    if (springSimulationX.isDone(elapsedSeconds) && springSimulationY.isDone(elapsedSeconds)) {
      _endSpring();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTapDown: (details) => _onTapDown(constraints, details),
                onPanStart: onDragStart,
                onPanUpdate: onDragUpdate,
                onPanEnd: onDragEnd,
                child: Stack(
                  children: [
                    const _Background(),
                    CustomPaint(
                      painter: SpringLinePainter(
                        anchorOffset: anchorOffset,
                        iconOffset: iconOffset,
                      ),
                      size: Size.infinite,
                    ),
                    Transform.translate(
                      offset: iconOffset,
                      child: const Align(
                        child: _Icon(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _Background extends StatelessWidget {
  const _Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Material(
          color: Colors.blue.shade400,
        ),
      );
}

class _Icon extends StatelessWidget {
  const _Icon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox.square(
        dimension: 64,
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
      );
}

class SpringLinePainter extends CustomPainter {
  SpringLinePainter({
    required this.anchorOffset,
    required this.iconOffset,
  });

  final Offset anchorOffset;
  final Offset iconOffset;
  final Paint springLinePaint = Paint()
    ..color = Colors.grey.shade700
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      size.center(Offset.zero) + anchorOffset,
      size.center(Offset.zero) + iconOffset,
      springLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
