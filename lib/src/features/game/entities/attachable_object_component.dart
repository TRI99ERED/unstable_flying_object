import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/features/game/entities/ground_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

const int kStickyGroupIndex = -1;

mixin StickyBody on BodyComponent, ContactCallbacks {
  bool get isSticky;

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (isSticky &&
        other is AttachableObjectComponent &&
        !other.attached &&
        (game as UfoGame).session.state == GameState.playing) {
      (game as UfoGame).weldManager.queueAttach(this, other, contact);
    }

    if (isSticky &&
        other is GroundComponent &&
        (game as UfoGame).session.state == GameState.playing) {
      if (contact.fixtureA.userData is! BeamMarker &&
          contact.fixtureB.userData is! BeamMarker) {
        final ufoGame = game as UfoGame;
        (world as UfoWorld).ufo.beamActive = false;
        ufoGame.session.gameOver();
        if (ufoGame.session.score >= ufoGame.session.bestScore) {
          (world as UfoWorld).progressRepository.save(
            ufoGame.session.bestScore,
          );
        }
        ufoGame.weldManager.destroyAllJoints();
        ufoGame.shakeScreen();
        (world as UfoWorld).showGameOverScreen(
          ufoGame.session.score,
          ufoGame.session.bestScore,
        );
        SoundEffects.instance.playCrash();
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
  int get score => 0;
  String get name => '';

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

  @override
  int get score => 200;
  @override
  String get name => 'Crate';

  CrateComponent({required super.initialPosition}) {
    renderBody = false;
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

class CarComponent extends AttachableObjectComponent {
  late final PolygonShape polygon;
  late final _CarVisual _visual;

  @override
  int get score => 300;
  @override
  String get name => 'Car';

  CarComponent({required super.initialPosition}) {
    renderBody = false;
    polygon = PolygonShape()
      ..set([
        Vector2(-2, 0),
        Vector2(-0.8, -0.5),
        Vector2(1, -0.5),
        Vector2(2, 0),
        Vector2(2, 0.5),
        Vector2(-2, 0.5),
      ]);
    fixtureDefs = [
      FixtureDef(polygon)
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
    _visual = _CarVisual(polygon);
    _visual.paint = Palette.color24.paint();
    add(_visual);
  }

  @override
  void pop() {
    final controller = EffectController(duration: 0.06, reverseDuration: 0.15);
    _visual.add(ScaleEffect.to(Vector2.all(1.5), controller));
    _visual.add(ColorEffect(Palette.color23.color, controller));
  }
}

class _CarVisual extends PositionComponent with HasPaint {
  final PolygonShape polygon;

  _CarVisual(this.polygon);

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..addPolygon(
        polygon.vertices.map((v) => v.toOffset()).toList(growable: false),
        true,
      );
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(-1, 0.5), 0.35, paint);
    canvas.drawCircle(Offset(1, 0.5), 0.35, paint);
  }
}

class ConeComponent extends AttachableObjectComponent {
  late final PolygonShape polygon;
  late final _ConeVisual _visual;

  @override
  int get score => 100;
  @override
  String get name => 'Cone';

  ConeComponent({required super.initialPosition}) {
    renderBody = false;
    polygon = PolygonShape()
      ..set([Vector2(-0.25, 0.25), Vector2(-0, -0.5), Vector2(0.25, 0.25)]);
    fixtureDefs = [
      FixtureDef(polygon)
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
    _visual = _ConeVisual(polygon);
    _visual.paint = Palette.color10.paint();
    add(_visual);
  }

  @override
  void pop() {
    final controller = EffectController(duration: 0.06, reverseDuration: 0.15);
    _visual.add(ScaleEffect.to(Vector2.all(1.5), controller));
    _visual.add(ColorEffect(Palette.color11.color, controller));
  }
}

class _ConeVisual extends PositionComponent with HasPaint {
  final PolygonShape polygon;

  _ConeVisual(this.polygon);

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

class CowComponent extends AttachableObjectComponent {
  late final PolygonShape polygon;
  late final _CowVisual _visual;

  @override
  int get score => 500;
  @override
  String get name => 'Cow';

  CowComponent({required super.initialPosition}) {
    renderBody = false;
    polygon = PolygonShape()
      ..set([
        Vector2(-1, 0),
        Vector2(-1, -0.5),
        Vector2(0.5, -0.5),
        Vector2(1, 0),
        Vector2(1, 0.5),
        Vector2(0.5, 0.5),
        Vector2(-0.5, 0.5),
        Vector2(-1, 0.5),
      ]);
    fixtureDefs = [
      FixtureDef(polygon)
        ..userData = this
        ..density = 1
        ..friction = 0.4
        ..restitution = 0.1,
    ];
    _visual = _CowVisual(polygon);
    _visual.paint = Palette.color21.paint();
    add(_visual);
  }

  @override
  void pop() {
    final controller = EffectController(duration: 0.06, reverseDuration: 0.15);
    _visual.add(ScaleEffect.to(Vector2.all(1.5), controller));
    _visual.add(ColorEffect(Palette.color20.color, controller));
  }
}

class _CowVisual extends PositionComponent with HasPaint {
  final PolygonShape polygon;

  _CowVisual(this.polygon);

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..addPolygon(
        polygon.vertices.map((v) => v.toOffset()).toList(growable: false),
        true,
      );
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(-1, -0.5), 0.5, paint);

    final legWidth = 0.15;
    final legHeight = 0.3;
    canvas.drawRect(Rect.fromLTWH(-0.8, 0.5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-0.45, 0.5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(0.3, 0.5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(0.65, 0.5, legWidth, legHeight), paint);

    final spotPaint = Paint()..color = Palette.color22.color;
    canvas.drawOval(Rect.fromCenter(center: Offset(-0.5, -0.1), width: 0.4, height: 0.3), spotPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(0.3, 0.15), width: 0.35, height: 0.25), spotPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(-0.1, -0.3), width: 0.3, height: 0.2), spotPaint);
  }
}
