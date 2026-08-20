import 'package:unstable_flying_object/src/features/game/entities/flying_number_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/power_up_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class PowerUpManager {
  static const double _effectDuration = 10.0;
  static const double _scoreBoostMultiplier = 3.0;

  final UfoGame _game;

  final Map<PowerUpType, double> _activeTimers = {};

  PowerUpManager(this._game);

  Set<PowerUpType> get activeTypes => _activeTimers.keys.toSet();

  bool isActive(PowerUpType type) =>
      _activeTimers.containsKey(type) && _activeTimers[type]! > 0;

  double getTimerNormalized(PowerUpType type) {
    final timer = _activeTimers[type];
    if (timer == null || timer <= 0) return 0;
    return (timer / _effectDuration).clamp(0.0, 1.0);
  }

  void collect(PowerUpComponent powerUp) {
    _activeTimers[powerUp.type] = _effectDuration;

    _game.world.add(
      FlyingNumberComponent(
        position: powerUp.body.position.clone(),
        objectName: powerUp.type.label,
        objectScore: 0,
      ),
    );

    _syncScoreMultiplier();
  }

  void update(double dt) {
    final expired = <PowerUpType>[];
    for (final entry in _activeTimers.entries) {
      final remaining = entry.value - dt;
      if (remaining <= 0) {
        expired.add(entry.key);
      } else {
        _activeTimers[entry.key] = remaining;
      }
    }
    for (final type in expired) {
      _activeTimers.remove(type);
    }
    _syncScoreMultiplier();
  }

  void _syncScoreMultiplier() {
    _game.session.scoreMultiplier =
        isActive(PowerUpType.scoreBoost) ? _scoreBoostMultiplier : 1.0;
  }

  void reset() {
    _activeTimers.clear();
    _game.session.scoreMultiplier = 1.0;
  }
}
