import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class UfoComponent extends BodyComponent {
  final Vector2 initialPosition;

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
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
  }
}
