import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

enum _ParticleType { engineTrail, crashSpark, crashDust, attachSpark }

class _Particle {
  Vector2 position;
  Vector2 velocity;
  double lifetime;
  double maxLifetime;
  double size;
  final _ParticleType type;
  final Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.maxLifetime,
    required this.size,
    required this.type,
    required this.color,
  }) : lifetime = maxLifetime;

  double get progress => 1.0 - lifetime / maxLifetime;
}

class GameParticles extends Component with HasGameReference<UfoGame> {
  static const int kMaxParticles = 120;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void update(double dt) {
    super.update(dt);

    if (game.session.state == GameState.playing) {
      _spawnEngineTrail(dt);
    }

    _updateParticles(dt);
  }

  void _updateParticles(double dt) {
    _particles.removeWhere((p) {
      p.lifetime -= dt;
      p.position += p.velocity * dt;
      if (p.type == _ParticleType.crashDust) {
        p.velocity.y += 9.8 * dt * 0.3;
      }
      return p.lifetime <= 0;
    });
  }

  void _spawnEngineTrail(double dt) {
    final ufo = game.world.children.whereType<UfoComponent>().firstOrNull;
    if (ufo == null) return;
    if (!ufo.beamActive) return;

    final thrust = game.moveIntent.length2;
    if (thrust <= 0) return;

    final maxToSpawn = (thrust * 2).ceil().clamp(0, 2);
    if (_particles.length + maxToSpawn > kMaxParticles) return;

    for (var i = 0; i < maxToSpawn; i++) {
      final offset = Vector2(
        (_random.nextDouble() - 0.5) * 1.0,
        0.5 + _random.nextDouble() * 0.3,
      );
      final rotatedOffset = Rot.mulVec2(ufo.body.transform.q, offset);
      final position = ufo.body.worldCenter + rotatedOffset;

      _particles.add(
        _Particle(
          position: position,
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 2,
            1 + _random.nextDouble() * 2,
          ),
          maxLifetime: 0.4 + _random.nextDouble() * 0.4,
          size: 0.08 + thrust * 0.04,
          type: _ParticleType.engineTrail,
          color: Palette.color19.color,
        ),
      );
    }
  }

  void spawnCrashExplosion(Vector2 position) {
    const sparkCount = 30;
    const dustCount = 10;

    final sparkColors = [Palette.color12, Palette.color11, Palette.color9];
    final dustColors = [Palette.color22, Palette.color21];

    for (var i = 0; i < sparkCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 5 + _random.nextDouble() * 15;

      _particles.add(
        _Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 5),
          maxLifetime: 0.3 + _random.nextDouble() * 0.3,
          size: 0.06 + _random.nextDouble() * 0.08,
          type: _ParticleType.crashSpark,
          color: sparkColors[_random.nextInt(sparkColors.length)].color,
        ),
      );
    }

    for (var i = 0; i < dustCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 1 + _random.nextDouble() * 3;

      _particles.add(
        _Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, -1 - _random.nextDouble() * 3),
          maxLifetime: 0.8 + _random.nextDouble() * 0.7,
          size: 0.3 + _random.nextDouble() * 0.4,
          type: _ParticleType.crashDust,
          color: dustColors[_random.nextInt(dustColors.length)].color,
        ),
      );
    }
  }

  void spawnAttachSpark(Vector2 position) {
    const count = 8;
    final sparkColors = [Palette.color19, Palette.color20];

    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 3 + _random.nextDouble() * 6;

      _particles.add(
        _Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          maxLifetime: 0.2 + _random.nextDouble() * 0.2,
          size: 0.06 + _random.nextDouble() * 0.04,
          type: _ParticleType.attachSpark,
          color: sparkColors[_random.nextInt(sparkColors.length)].color,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (_particles.isEmpty) return;

    final paint = Paint();

    for (final p in _particles) {
      final alpha = _particleAlpha(p);
      if (alpha <= 0) continue;

      if (p.type == _ParticleType.crashDust) {
        paint.color = p.color.withValues(alpha: alpha * 0.5);
      } else {
        paint.color = p.color.withValues(alpha: alpha);
      }

      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size, paint);
    }
  }

  double _particleAlpha(_Particle p) {
    final progress = p.progress;
    if (progress < 0.15) {
      return progress / 0.15;
    }
    if (p.type == _ParticleType.engineTrail && progress > 0.5) {
      return (1.0 - progress) / 0.5;
    }
    if (progress > 0.6) {
      return (1.0 - progress) / 0.4;
    }
    return 1.0;
  }
}
