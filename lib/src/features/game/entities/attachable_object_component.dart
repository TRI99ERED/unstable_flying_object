import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class AttachableObjectComponent extends BodyComponent {
  final Vector2 initialPosition;

  AttachableObjectComponent({required this.initialPosition}) {
    priority = 0;
    bodyDef = BodyDef()
      ..userData = this
      ..linearDamping = 0.5
      ..angularDamping = 1.0
      ..position = initialPosition
      ..type = BodyType.dynamic;
  }
}

class CrateComponent extends AttachableObjectComponent {
  CrateComponent({required super.initialPosition}) {
    paint = Palette.color6.paint();
    fixtureDefs = [
      FixtureDef(PolygonShape()..setAsBox(0.5, 0.5, Vector2.zero(), 0))
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
  }
}
