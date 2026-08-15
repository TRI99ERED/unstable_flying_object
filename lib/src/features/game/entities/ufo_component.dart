import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoComponent extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;

  final BeamMarker beamMarker = BeamMarker();
  final Set<AttachableObjectComponent> beamedObjects = {};

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
            Vector2(0, 1),
            Vector2(1, 0.85),
            Vector2(2, 0),
            Vector2(0, -1),
          ]),
        )
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
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

    final rotatedIntent = Rot.mulVec2(
      body.transform.q,
      (game as UfoGame).moveIntent,
    );
    body.applyForce(rotatedIntent * 100, point: body.worldCenter);
    body.applyTorque((game as UfoGame).rollIntent * 10);

    for (var obj in beamedObjects) {
      obj.body.applyForce(
        (body.worldCenter - obj.body.worldCenter).normalized() *
            obj.body.mass *
            15,
        point: obj.body.worldCenter,
      );
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

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
