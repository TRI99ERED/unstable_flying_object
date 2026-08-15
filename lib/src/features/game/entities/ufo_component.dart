import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoComponent extends BodyComponent with ContactCallbacks, StickyBody {
  static const double kBeamPull = 15;
  static const double kBeamDamping = 2;

  final Vector2 initialPosition;

  final BeamMarker beamMarker = BeamMarker();
  final Set<AttachableObjectComponent> beamedObjects = {};

  @override
  bool get isSticky => true;

  UfoComponent({required this.initialPosition}) {
    priority = 127;
    paint = Palette.color23.paint();
    bodyDef = BodyDef()
      ..userData = this
      ..allowSleep = false
      ..linearDamping = 0.5
      ..angularDamping = 1.0
      ..position = initialPosition
      ..type = BodyType.dynamic;
    fixtureDefs = [
      FixtureDef(
          PolygonShape()..set([
            Vector2(-2, 0),
            Vector2(-1, 0.85),
            Vector2(1, 0.85),
            Vector2(2, 0),
            Vector2(0, -1),
          ]),
        )
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1
        ..filter = (Filter()..groupIndex = kStickyGroupIndex),
      FixtureDef(
          PolygonShape()..set([
            Vector2(-1, 0.85),
            Vector2(1, 0.85),
            Vector2(20, 100),
            Vector2(-20, 100),
          ]),
        )
        ..userData = beamMarker
        ..isSensor = true
        ..density = 0
        ..friction = 0
        ..restitution = 0,
    ];
  }

  @override
  void renderFixture(Canvas canvas, Fixture fixture) {
    final previous = paint;
    paint = fixture.userData == beamMarker
        ? Palette.color19.withAlpha(32).paint()
        : Palette.color23.paint();
    super.renderFixture(canvas, fixture);
    paint = previous;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final gameRef = game as UfoGame;
    final attached = gameRef.weldManager.attached;

    var totalMass = body.mass;
    var weightedCenter = body.worldCenter * totalMass;
    for (final obj in attached) {
      final m = obj.body.mass;
      totalMass += m;
      weightedCenter += obj.body.worldCenter * m;
    }
    final com = weightedCenter / totalMass;
    var inertiaAboutCom =
        body.inertia + body.mass * (body.worldCenter - com).length2;
    for (final obj in attached) {
      final offset = obj.body.worldCenter - com;
      inertiaAboutCom += obj.body.inertia + obj.body.mass * offset.length2;
    }

    final moveScale = totalMass / body.mass * gameRef.weldManager.controlScale;
    final rollScale =
        inertiaAboutCom / body.inertia * gameRef.weldManager.controlScale;

    final rotatedIntent = Rot.mulVec2(body.transform.q, gameRef.moveIntent);
    body.applyForce(rotatedIntent * 100 * moveScale, point: com);
    body.applyTorque(gameRef.rollIntent * 10 * rollScale);

    beamedObjects.removeWhere((o) => o.attached);
    for (var obj in beamedObjects) {
      final delta = body.worldCenter - obj.body.worldCenter;
      if (delta.length2 < 0.01) continue;
      final dir = delta.normalized();
      obj.body.applyForce(
        dir * obj.body.mass * kBeamPull,
        point: obj.body.worldCenter,
      );
      obj.body.applyForce(
        -obj.body.linearVelocity * obj.body.mass * kBeamDamping,
        point: obj.body.worldCenter,
      );
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    if (other is AttachableObjectComponent && other.attached) return;

    if (contact.fixtureA.userData is BeamMarker ||
        contact.fixtureB.userData is BeamMarker) {
      if (other is AttachableObjectComponent) {
        beamedObjects.add(other);
      }
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);

    if (contact.fixtureA.userData is BeamMarker ||
        contact.fixtureB.userData is BeamMarker) {
      if (other is AttachableObjectComponent) {
        beamedObjects.remove(other);
      }
    }
  }
}

class BeamMarker {}
