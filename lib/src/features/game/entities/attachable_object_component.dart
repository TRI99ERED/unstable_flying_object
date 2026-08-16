import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
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

    if (isSticky && other is GroundComponent) {
      if (contact.fixtureA.userData is! BeamMarker &&
          contact.fixtureB is! BeamMarker) {
        final ufoGame = game as UfoGame;
        ufoGame.session.gameOver();
        ufoGame.shakeScreen();
      }
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

  void pop() {}
}

class CrateComponent extends AttachableObjectComponent {
  late final PolygonShape polygon;
  late final _CrateVisual _visual;

  CrateComponent({required super.initialPosition}) {
    renderBody = false; // don't let BodyComponent re-draw the fixture
    polygon = PolygonShape()..setAsBox(0.5, 0.5, Vector2.zero(), 0);
    fixtureDefs = [
      FixtureDef(polygon)
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
    _visual = _CrateVisual(polygon);
    _visual.paint = Palette.color6.paint();
    add(_visual);
  }

  @override
  void pop() {
    final controller = EffectController(duration: 0.06, reverseDuration: 0.15);
    _visual.add(ScaleEffect.to(Vector2.all(1.5), controller));
    _visual.add(ColorEffect(Palette.color5.color, controller));
  }
}

class _CrateVisual extends PositionComponent with HasPaint {
  final PolygonShape polygon;

  _CrateVisual(this.polygon);

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..addPolygon(
        polygon.vertices.map((v) => v.toOffset()).toList(growable: false),
        true,
      );
    canvas.drawPath(path, paint);
  }
}
