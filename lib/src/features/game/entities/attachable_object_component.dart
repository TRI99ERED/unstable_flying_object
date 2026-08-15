import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

const int kStickyGroupIndex = -1;

mixin StickyBody on BodyComponent, ContactCallbacks {
  bool get isSticky;

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (isSticky && other is AttachableObjectComponent && !other.attached) {
      (game as UfoGame).weldManager.queueAttach(this, other, contact);
    }
  }
}

class AttachableObjectComponent extends BodyComponent
    with ContactCallbacks, StickyBody {
  final Vector2 initialPosition;

  bool attached = false;

  @override
  bool get isSticky => attached;

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
