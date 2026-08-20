import 'dart:ui';

import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

enum PowerUpType {
  antiGravity(Palette.color29, 'Anti-Gravity'),
  beamBoost(Palette.color19, 'Beam Boost'),
  speedBoost(Palette.color12, 'Speed Boost'),
  scoreBoost(Palette.color13, 'Score Boost');

  final PaletteEntry color;
  final String label;

  const PowerUpType(this.color, this.label);
}

class PowerUpComponent extends BodyComponent with ContactCallbacks {
  static const double _size = 0.8;
  static const double _despawnY = 35;

  final PowerUpType type;
  final Vector2 spawnPosition;

  bool _collected = false;

  PowerUpComponent({required this.type, required this.spawnPosition}) {
    priority = 1;
    bodyDef = BodyDef()
      ..userData = this
      ..allowSleep = false
      ..linearDamping = 0.3
      ..angularDamping = 0.5
      ..position = spawnPosition
      ..type = BodyType.dynamic;

    final shape = _createShape();
    fixtureDefs = [
      FixtureDef(shape)
        ..userData = this
        ..isSensor = true
        ..density = 1
        ..friction = 0
        ..restitution = 0
        ..filter = (Filter()..groupIndex = kStickyGroupIndex - 1),
    ];
  }

  Shape _createShape() {
    switch (type) {
      case PowerUpType.antiGravity:
        return PolygonShape()..set([
          Vector2(0, -_size),
          Vector2(_size, 0),
          Vector2(0, _size),
          Vector2(-_size, 0),
        ]);
      case PowerUpType.beamBoost:
        return CircleShape(radius: _size * 0.6);
      case PowerUpType.speedBoost:
        return PolygonShape()
          ..setAsBox(_size * 0.55, _size * 0.55, Vector2.zero(), 0);
      case PowerUpType.scoreBoost:
        return CircleShape(radius: _size * 0.6);
    }
  }

  @override
  void renderFixture(Canvas canvas, Fixture fixture) {
    final paint = Paint()..color = type.color.color;

    switch (type) {
      case PowerUpType.antiGravity:
        _drawRhombus(canvas, paint);
        break;
      case PowerUpType.beamBoost:
        canvas.drawCircle(Offset.zero, _size * 0.6, paint);
        break;
      case PowerUpType.speedBoost:
        final half = _size * 0.55;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: half * 2,
            height: half * 2,
          ),
          paint,
        );
        break;
      case PowerUpType.scoreBoost:
        canvas.drawCircle(Offset.zero, _size * 0.6, paint);
        final holePaint = Paint()..color = Palette.color18.color;
        canvas.drawCircle(Offset.zero, _size * 0.3, holePaint);
        break;
    }
  }

  void _drawRhombus(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(0, -_size)
      ..lineTo(_size, 0)
      ..lineTo(0, _size)
      ..lineTo(-_size, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (body.position.y > _despawnY) {
      removeFromParent();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    if (_collected) return;

    final ufoGame = game as UfoGame;
    if (ufoGame.session.state != GameState.playing) return;

    if (other is! UfoComponent) return;
    if (contact.fixtureA.userData is BeamMarker ||
        contact.fixtureB.userData is BeamMarker) {
      return;
    }

    _collected = true;
    ufoGame.powerUpManager.collect(this);
    SoundEffects.instance.playPowerUp();
    removeFromParent();
  }
}
