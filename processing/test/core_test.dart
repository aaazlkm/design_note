import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:processing/src/_core.dart';

void main() {
  group(
    'core',
    () {
      testGoldens(
        'user can paint with background in draw()',
        (tester) async {
          tester.binding.window
            ..physicalSizeTestValue = Size.square(100)
            ..devicePixelRatioTestValue = 1.0;

          await tester.pumpWidget(Processing(
            sketch: Sketch.simple(
              setup: (s) {
                s.background(color: Colors.red);
              },
              draw: (s) {
                s.background(color: Colors.green);
              },
            ),
          ));

          await screenMatchesGolden(tester, 'core_draw_background');
        },
      );
    },
  );
}
