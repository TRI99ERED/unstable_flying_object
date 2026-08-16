import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';

class WeldManager {
  final Forge2DWorld world;
  final GameSession session;

  final Set<AttachableObjectComponent> _attached = {};
  final List<_PendingAttach> _pending = [];

  Set<AttachableObjectComponent> get attached => _attached;
  double get controlScale => 1 / (1 + 0.18 * _attached.length);

  WeldManager(this.world, this.session);

  void queueAttach(
    BodyComponent host,
    AttachableObjectComponent obj,
    Contact contact,
  ) {
    if (_attached.contains(obj)) return;
    if (_pending.any((p) => p.obj == obj)) return;
    if (contact.fixtureA.isSensor || contact.fixtureB.isSensor) return;

    final manifold = WorldManifold();
    contact.getWorldManifold(manifold);
    if (manifold.points.isEmpty) return;

    _pending.add(_PendingAttach(host, obj, manifold.points.first.clone()));
  }

  void processPending() {
    if (_pending.isEmpty) return;

    final pending = List.of(_pending);
    _pending.clear();
    for (final attach in pending) {
      if (attach.obj.attached) continue;
      _attach(attach.host, attach.obj, attach.anchor);
    }
  }

  void _attach(
    BodyComponent host,
    AttachableObjectComponent obj,
    Vector2 anchor,
  ) {
    if (_attached.contains(obj)) return;

    final hostVel = host.body.linearVelocity;
    final hostAng = host.body.angularVelocity;
    final offset = obj.body.worldCenter - host.body.worldCenter;
    obj.body
      ..linearVelocity =
          hostVel + Vector2(-hostAng * offset.y, hostAng * offset.x)
      ..angularVelocity = hostAng
      ..setAwake(true);

    for (final fixture in obj.body.fixtures) {
      final filter = fixture.filterData;
      filter.groupIndex = kStickyGroupIndex;
      fixture.filterData = filter;
    }

    final def = WeldJointDef<Body, Body>()
      ..initialize(host.body, obj.body, anchor)
      ..collideConnected = false;
    world.createJoint(WeldJoint(def));

    _attached.add(obj);
    obj.attached = true;
    session.addScore();
    obj.pop();
  }

  void checkCrash(Component component) {
    if (component is UfoComponent ||
        component is AttachableObjectComponent && component.attached) {
      session.gameOver();
    }
  }

  void reset() {
    _attached.clear();
  }
}

class _PendingAttach {
  final BodyComponent host;
  final AttachableObjectComponent obj;
  final Vector2 anchor;

  _PendingAttach(this.host, this.obj, this.anchor);
}
