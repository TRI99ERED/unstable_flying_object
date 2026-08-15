import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoGame extends Forge2DGame<UfoWorld> {
  static const double kGameWidth = 1280;
  static const double kGameHeight = 720;

  @override
  Color backgroundColor() => Palette.color27.color;

  UfoGame()
    : super(
        gravity: Vector2(0, 9.8),
        camera: CameraComponent.withFixedResolution(
          width: kGameWidth,
          height: kGameHeight,
          backdrop: RectangleComponent(
            size: Vector2(kGameWidth, kGameHeight),
            paint: Palette.color18.paint(),
          ),
        ),
        world: UfoWorld(),
      );
}

class UfoWorld extends Forge2DWorld {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(UfoComponent(initialPosition: Vector2.zero()));
    add(
      GroundComponent(0, [
        Vector2(-64, 30),
        Vector2(64, 30),
      ], Palette.color14.paint()),
    );
  }
}
