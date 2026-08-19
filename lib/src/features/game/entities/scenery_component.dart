import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class SceneryComponent extends PositionComponent {
  final Vector2 initialPosition;
  final int seed;

  SceneryComponent(this.initialPosition, {this.seed = 1337}) {
    priority = -1;
    position = initialPosition;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final random = Random(seed);

    for (
      double x = -UfoWorld.kWorldWidth / 2;
      x < UfoWorld.kWorldWidth / 2;
      x += 20
    ) {
      add(_HouseComponent(Vector2(x, random.nextDouble() * 5 + 20)));
    }
  }
}

class _HouseComponent extends PositionComponent {
  final Vector2 initialPosition;

  _HouseComponent(this.initialPosition) {
    priority = -1;
    position = initialPosition;
  }

  @override
  void render(Canvas canvas) {
    final houseBodyRect = Rect.fromLTWH(0, 0, 10, 10);
    canvas.drawRect(houseBodyRect, Palette.color3.paint());

    final houseRoofPath = Path();
    houseRoofPath.addPolygon([
      Offset(0, 0),
      Offset(5, -5),
      Offset(10, 0),
    ], true);
    canvas.drawPath(houseRoofPath, Palette.color7.paint());

    final houseWindowRect = Rect.fromLTWH(4, 2, 2, 2);
    canvas.drawRect(houseWindowRect, Palette.color19.paint());
  }
}
