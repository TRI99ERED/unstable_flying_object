import 'dart:math';

import 'package:flame/components.dart';
import 'package:unstable_flying_object/src/features/game/entities/power_up_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class PowerUpSpawner extends Component with HasGameReference<UfoGame> {
  static const double _minInterval = 8.0;
  static const double _maxInterval = 15.0;
  static const double _spawnAboveCamera = 5.0;

  double _timer = 0;
  double _nextInterval = 0;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _nextInterval = _random.nextDouble() * (_maxInterval - _minInterval) + _minInterval;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.session.state != GameState.playing) return;

    _timer += dt;
    if (_timer >= _nextInterval) {
      _timer = 0;
      _nextInterval =
          _random.nextDouble() * (_maxInterval - _minInterval) + _minInterval;
      _spawnPowerUp();
    }

    _wrapPowerUps();
  }

  void _spawnPowerUp() {
    final type = _randomType();

    final camX = game.camera.viewfinder.position.x;
    final camY = game.camera.viewfinder.position.y;
    final halfWidth = UfoGame.kGameWidth / 2 / 10;
    final halfHeight = UfoGame.kGameHeight / 2 / 10;
    final x = camX - halfWidth + _random.nextDouble() * halfWidth * 2;
    final y = camY - halfHeight - _spawnAboveCamera;

    final powerUp = PowerUpComponent(type: type, spawnPosition: Vector2(x, y));
    game.world.add(powerUp);
  }

  PowerUpType _randomType() {
    final weighted = <(PowerUpType, double)>[
      (PowerUpType.antiGravity, 1.0),
      (PowerUpType.beamBoost, 1.0),
      (PowerUpType.speedBoost, 1.0),
      (PowerUpType.scoreBoost, 0.3),
    ];
    final totalWeight = weighted.fold<double>(0, (sum, e) => sum + e.$2);
    final roll = _random.nextDouble() * totalWeight;
    var acc = 0.0;
    for (final (type, weight) in weighted) {
      acc += weight;
      if (roll < acc) return type;
    }
    return weighted[0].$1;
  }

  void _wrapPowerUps() {
    final halfWidth = UfoGame.kGameWidth / 2 / 10;
    final cameraX = game.camera.viewfinder.position.x;

    for (final powerUp in game.world.children.whereType<PowerUpComponent>()) {
      final dx = powerUp.body.position.x - cameraX;
      if (dx > halfWidth) {
        powerUp.body.setTransform(
          powerUp.body.position - Vector2(UfoWorld.kWorldWidth, 0),
          powerUp.body.angle,
        );
      } else if (dx < -halfWidth) {
        powerUp.body.setTransform(
          powerUp.body.position + Vector2(UfoWorld.kWorldWidth, 0),
          powerUp.body.angle,
        );
      }
    }
  }
}
