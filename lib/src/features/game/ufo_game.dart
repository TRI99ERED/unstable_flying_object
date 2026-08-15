import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/systems/weld_manager.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoGame extends Forge2DGame<UfoWorld> with KeyboardEvents {
  static const double kGameWidth = 1280;
  static const double kGameHeight = 720;

  final GameSession session = GameSession();
  late final WeldManager weldManager = WeldManager(world, session);
  final Vector2 moveIntent = Vector2.zero();
  final Set<LogicalKeyboardKey> _heldKeys = {};

  double _rollIntent = 0;

  double get rollIntent => _rollIntent;

  @override
  void update(double dt) {
    super.update(dt);
    weldManager.processPending();
  }

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

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (event is KeyDownEvent) {
      _heldKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _heldKeys.remove(event.logicalKey);
    }

    moveIntent
      ..x =
          _heldKeys.contains(LogicalKeyboardKey.arrowRight) ||
              _heldKeys.contains(LogicalKeyboardKey.keyD)
          ? 1
          : _heldKeys.contains(LogicalKeyboardKey.arrowLeft) ||
                _heldKeys.contains(LogicalKeyboardKey.keyA)
          ? -1
          : 0
      ..y =
          _heldKeys.contains(LogicalKeyboardKey.arrowDown) ||
              _heldKeys.contains(LogicalKeyboardKey.keyS)
          ? 1
          : _heldKeys.contains(LogicalKeyboardKey.arrowUp) ||
                _heldKeys.contains(LogicalKeyboardKey.keyW)
          ? -1
          : 0;
    if (moveIntent.length2 > 0) {
      moveIntent.normalize();
    }

    _rollIntent = _heldKeys.contains(LogicalKeyboardKey.keyQ)
        ? -1
        : _heldKeys.contains(LogicalKeyboardKey.keyE)
        ? 1
        : 0;

    return KeyEventResult.handled;
  }
}

class UfoWorld extends Forge2DWorld {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(UfoComponent(initialPosition: Vector2.zero()));
    add(
      GroundComponent(0, [
        Vector2(-64, 30),
        Vector2(-32, 35),
        Vector2(0, 25),
        Vector2(64, 30),
      ], Palette.color14.paint()),
    );
    add(CrateComponent(initialPosition: Vector2(10, 25)));
    add(CrateComponent(initialPosition: Vector2(15, 25)));
    add(CrateComponent(initialPosition: Vector2(20, 25)));
    add(CrateComponent(initialPosition: Vector2(25, 25)));
    add(CrateComponent(initialPosition: Vector2(30, 25)));
    add(CrateComponent(initialPosition: Vector2(35, 25)));
  }
}
