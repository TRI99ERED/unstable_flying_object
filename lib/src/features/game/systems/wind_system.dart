import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class _WindParticle {
  Vector2 position;
  double lifetime;
  double maxLifetime;
  double speed;
  double length;

  _WindParticle({
    required this.position,
    required this.maxLifetime,
    required this.speed,
    required this.length,
  }) : lifetime = maxLifetime;

  double get progress => 1.0 - lifetime / maxLifetime;
}

class WindSystem extends Component with HasGameReference<UfoGame> {
  static const double kBaseStrength = 8.0;
  static const double kRampRate = 0.003;
  static const double kOscillationPeriod = 20.0;
  static const double kGroundY = 28.0;
  static const double kVisibleHeight = 64.0;
  static const int kParticleMaxCount = 40;
  static const double kParticleLifetime = 20.0;

  double _elapsedTime = 0;
  double _direction = 1;
  double _spawnAccumulator = 0;

  final List<_WindParticle> _particles = [];
  final _paint = Paint()
    ..color = Palette.color21.color
    ..strokeWidth = 0.15
    ..strokeCap = StrokeCap.round;

  double get windStrength {
    final rampMultiplier = 1 + kRampRate * _elapsedTime;
    return kBaseStrength * rampMultiplier * _altitudeFactor;
  }

  Vector2 get windForce {
    return Vector2(windStrength * _direction, 0);
  }

  double get _altitudeFactor {
    final ufoGame = game;
    final ufo = ufoGame.world.children.whereType<UfoComponent>().firstOrNull;
    if (ufo == null) return 0;
    return ((kGroundY - ufo.body.position.y) / kVisibleHeight).clamp(0.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    _direction = sin(_elapsedTime * 2 * pi / kOscillationPeriod) >= 0
        ? 1.0
        : -1.0;

    _applyWind();

    if (game.session.state == GameState.playing) {
      _updateParticles(dt);
      _spawnParticles(dt);
    }
  }

  void _applyWind() {
    if (_altitudeFactor <= 0) return;

    final force = windForce;

    final ufo = game.world.children.whereType<UfoComponent>().firstOrNull;
    if (ufo == null) return;

    ufo.body.applyForce(force * ufo.body.mass, point: ufo.body.worldCenter);

    for (final obj in game.weldManager.attached) {
      obj.body.applyForce(force * obj.body.mass, point: obj.body.worldCenter);
    }
  }

  void _updateParticles(double dt) {
    final dirVec = Vector2(_direction, 0);
    _particles.removeWhere((p) {
      p.lifetime -= dt;
      final altitudeFactor = ((kGroundY - p.position.y) / kVisibleHeight).clamp(
        0.0,
        1.0,
      );
      p.position += dirVec * p.speed * altitudeFactor * dt;
      return p.lifetime <= 0;
    });
  }

  void _spawnParticles(double dt) {
    if (_particles.length >= kParticleMaxCount) return;
    if (_altitudeFactor <= 0.01) return;

    final spawnRate = _altitudeFactor * 15.0;
    _spawnAccumulator += spawnRate * dt;

    while (_spawnAccumulator >= 1 && _particles.length < kParticleMaxCount) {
      _spawnAccumulator -= 1;
      _particles.add(_createParticle());
    }
  }

  _WindParticle _createParticle() {
    final random = Random();
    final camera = game.camera.viewfinder;
    final camX = camera.position.x;
    final camY = camera.position.y;
    final halfWidth = UfoGame.kGameWidth / 2 / 10;
    final halfHeight = UfoGame.kGameHeight / 2 / 10;

    final y =
        (camY - halfHeight + random.nextDouble() * UfoGame.kGameHeight / 10)
            .clamp(camY - halfHeight, kGroundY - 0.5);
    final x = _direction > 0 ? camX - halfWidth : camX + halfWidth;

    final strength = windStrength;
    final speed = 10 + strength / kBaseStrength * 8;
    final length = 0.3 + strength / kBaseStrength * 0.7;

    return _WindParticle(
      position: Vector2(x, y),
      maxLifetime: kParticleLifetime,
      speed: speed,
      length: length,
    );
  }

  @override
  void render(Canvas canvas) {
    if (_particles.isEmpty) return;

    for (final p in _particles) {
      final alpha = _particleAlpha(p);
      if (alpha <= 0) continue;

      _paint.color = Color.fromRGBO(192, 203, 220, alpha);

      final halfLen = p.length / 2;
      final startX = p.position.x - halfLen * _direction;
      final endX = p.position.x + halfLen * _direction;

      canvas.drawLine(
        Offset(startX, p.position.y),
        Offset(endX, p.position.y),
        _paint,
      );
    }
  }

  double _particleAlpha(_WindParticle p) {
    final progress = p.progress;
    if (progress < 0.2) {
      return progress / 0.2;
    }
    if (progress > 0.7) {
      return (1.0 - progress) / 0.3;
    }
    return 1.0;
  }
}
