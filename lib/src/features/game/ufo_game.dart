import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/spawner_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/hud/game_over_overlay_component.dart';
import 'package:unstable_flying_object/src/features/game/systems/weld_manager.dart';
import 'package:unstable_flying_object/src/features/game/systems/wrap_system.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoGame extends Forge2DGame<UfoWorld> with KeyboardEvents {
  static const double kGameWidth = 1280;
  static const double kGameHeight = 720;

  final GameSession session = GameSession();
  late final WeldManager weldManager = WeldManager(world, session);
  final Vector2 moveIntent = Vector2.zero();
  final Set<LogicalKeyboardKey> _heldKeys = {};

  double _rollIntent = 0;
  bool _ufoSoundPlaying = false;

  double get rollIntent => _rollIntent;

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
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.zoom = 10;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final ufo = world.children.whereType<UfoComponent>().firstOrNull;
    if (ufo != null) {
      camera.viewfinder.position = Vector2(
        ufo.body.position.x,
        camera.viewfinder.position.y,
      );
    }

    weldManager.processPending();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (session.state == GameState.gameOver) {
      _heldKeys.clear();
      moveIntent
        ..x = 0
        ..y = 0;
      _rollIntent = 0;

      if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        weldManager.reset();
        world.spawnLevel();
        session.start();
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

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

    final bool shouldBePlaying = moveIntent.length2 > 0 || _rollIntent != 0;
    if (shouldBePlaying && !_ufoSoundPlaying) {
      SoundEffects.instance.playUfoFloating();
      _ufoSoundPlaying = true;
    } else if (!shouldBePlaying && _ufoSoundPlaying) {
      SoundEffects.instance.stopUfoFloating();
      _ufoSoundPlaying = false;
    }

    return KeyEventResult.handled;
  }

  void shakeScreen() {
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(1, 1),
        NoiseEffectController(duration: 0.2, noise: PerlinNoise(frequency: 40)),
      ),
    );
  }
}

class UfoWorld extends Forge2DWorld {
  static const double kWorldWidth = 256;

  static const double _gameOverDelaySeconds = 3.0;

  late UfoComponent ufo;

  double? _gameOverTimer;
  int? _pendingScore;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    spawnLevel();
  }

  void spawnLevel() {
    removeAll(children);
    reset();

    final spawner = SpawnerComponent();
    add(spawner);
    (findGame() as UfoGame).weldManager.spawner = spawner;

    ufo = UfoComponent(initialPosition: Vector2.zero());
    add(ufo);

    final terrainPoints = [
      Vector2(-128, 25),
      Vector2(-96, 35),
      Vector2(-64, 30),
      Vector2(-32, 35),
      Vector2(0, 25),
      Vector2(64, 30),
      Vector2(96, 30),
      Vector2(128, 25),
    ];
    final terrainPaint = Palette.color14.paint();
    add(GroundComponent(0, terrainPoints, terrainPaint));
    add(
      GroundComponent(
        0,
        terrainPoints.map((p) => Vector2(p.x - kWorldWidth, p.y)).toList(),
        terrainPaint,
      ),
    );
    add(
      GroundComponent(
        0,
        terrainPoints.map((p) => Vector2(p.x + kWorldWidth, p.y)).toList(),
        terrainPaint,
      ),
    );

    add(WrapSystem());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameOverTimer != null) {
      _gameOverTimer = _gameOverTimer! - dt;
      if (_gameOverTimer! <= 0) {
        _gameOverTimer = null;
        children.whereType<WrapSystem>().forEach((c) => c.removeFromParent());
        children.whereType<SpawnerComponent>().forEach((c) => c.removeFromParent());
        for (final body in children.whereType<BodyComponent>()) {
          body.body.setType(BodyType.static);
        }
        (findGame() as UfoGame).camera.viewport.add(
          GameOverOverlayComponent(score: _pendingScore!),
        );
      }
    }
  }

  void showGameOverScreen(int score) {
    _pendingScore = score;
    _gameOverTimer ??= _gameOverDelaySeconds;
  }

  void reset() {
    _gameOverTimer = null;
    _pendingScore = null;
    (findGame() as UfoGame).camera.viewport.children
        .whereType<GameOverOverlayComponent>()
        .forEach((overlay) => overlay.removeFromParent());
  }
}
