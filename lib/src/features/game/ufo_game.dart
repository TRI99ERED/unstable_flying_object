import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/features/data/repositories/progress/iprogress_repository.dart';
import 'package:unstable_flying_object/src/features/data/repositories/progress/progress_repository_impl.dart';
import 'package:unstable_flying_object/src/features/data/repositories/shared_preferences/shared_preferences_repository_impl.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/spawner_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/hud/game_over_overlay_component.dart';
import 'package:unstable_flying_object/src/features/game/hud/hud_component.dart';
import 'package:unstable_flying_object/src/features/game/hud/settling_overlay_component.dart';
import 'package:unstable_flying_object/src/features/game/scenes/title_scene.dart';
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

    if (session.state == GameState.menu) {
      if (keysPressed.contains(LogicalKeyboardKey.enter)) {
        world.spawnLevel();
        session.settle();
        camera.viewport.children.whereType<TitleScene>().forEach(
          (overlay) => overlay.removeFromParent(),
        );
        camera.viewport.add(SettlingOverlayComponent());
      }
    }

    if (session.state == GameState.settling) {
      return KeyEventResult.handled;
    }

    if (session.state == GameState.gameOver) {
      _heldKeys.clear();
      moveIntent
        ..x = 0
        ..y = 0;
      _rollIntent = 0;

      if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        weldManager.reset();
        world.spawnLevel();
        session.settle();
        camera.viewport.children.whereType<SettlingOverlayComponent>().forEach(
          (overlay) => overlay.removeFromParent(),
        );
        camera.viewport.add(SettlingOverlayComponent());
        return KeyEventResult.handled;
      } else if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        weldManager.reset();
        world.reset();
        session.menu();
        camera.viewport.add(TitleScene());
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      weldManager.reset();
      world.reset();
      session.menu();
      camera.viewport.add(TitleScene());
      return KeyEventResult.handled;
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
  static const double _settlingDuration = 0.75;

  final IProgressRepository progressRepository = ProgressRepositoryImpl(
    spRepository: SharedPreferencesRepositoryImpl(),
  );

  late UfoComponent ufo;

  double? _gameOverTimer;
  double? _settlingTimer;
  int? _pendingScore;
  int? _pendingBestScore;

  bool get isOnTitleScene =>
      children.any((component) => component is TitleScene);

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    (findGame() as UfoGame).camera.viewport.add(TitleScene());
    await progressRepository.load();
  }

  void spawnLevel() {
    reset();

    final spawner = SpawnerComponent();
    add(spawner);
    (findGame() as UfoGame).weldManager.spawner = spawner;

    final random = Random();
    final terrainPoints = List.generate(
      9,
      (int i) => Vector2(-128 + i * 32, random.nextDouble() * 5 + 25),
      growable: false,
    );
    terrainPoints.last.y = terrainPoints.first.y;

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

    _settlingTimer = _settlingDuration;
  }

  void _finishSettling() {
    ufo = UfoComponent(initialPosition: Vector2.zero());
    add(ufo);

    (findGame() as UfoGame).camera.viewport.children
        .whereType<SettlingOverlayComponent>()
        .forEach((overlay) => overlay.removeFromParent());
    (findGame() as UfoGame).camera.viewport.add(HudComponent());

    (findGame() as UfoGame).session.loadBestScore(progressRepository.bestScore);
    (findGame() as UfoGame).session.play();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_settlingTimer != null) {
      _settlingTimer = _settlingTimer! - dt;
      if (_settlingTimer! <= 0) {
        _settlingTimer = null;
        _finishSettling();
      }
    }

    if (_gameOverTimer != null) {
      _gameOverTimer = _gameOverTimer! - dt;
      if (_gameOverTimer! <= 0) {
        _gameOverTimer = null;
        children.whereType<WrapSystem>().forEach((c) => c.removeFromParent());
        children.whereType<SpawnerComponent>().forEach(
          (c) => c.removeFromParent(),
        );
        for (final body in children.whereType<BodyComponent>()) {
          body.body.setType(BodyType.static);
        }
        (findGame() as UfoGame).camera.viewport.add(
          GameOverOverlayComponent(
            score: _pendingScore!,
            bestScore: _pendingBestScore!,
          ),
        );
      }
    }
  }

  void showGameOverScreen(int score, int bestScore) {
    _pendingScore = score;
    _pendingBestScore = bestScore;
    _gameOverTimer ??= _gameOverDelaySeconds;
    SoundEffects.instance.stopGameplayAudio();
  }

  void reset() {
    removeAll(children);
    _gameOverTimer = null;
    _settlingTimer = null;
    _pendingScore = null;
    _pendingBestScore = null;
    (findGame() as UfoGame).camera.viewport.children
        .whereType<GameOverOverlayComponent>()
        .forEach((overlay) => overlay.removeFromParent());
    SoundEffects.instance.stopGameplayAudio();
  }
}
