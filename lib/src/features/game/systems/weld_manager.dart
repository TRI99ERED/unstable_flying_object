import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/flying_number_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/spawner_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class WeldManager {
  final Forge2DWorld world;
  final GameSession session;

  final Set<AttachableObjectComponent> _attached = {};
  final List<_PendingAttach> _pending = [];
  final List<Joint> _joints = [];

  SpawnerComponent? spawner;

  Set<AttachableObjectComponent> get attached => _attached;
  double get controlScale {
    final totalMass = _attached.fold(0.0, (sum, obj) => sum + obj.body.mass);
    return 1 / (1 + 0.01 * totalMass);
  }

  WeldManager(this.world, this.session);

  void queueAttach(
    BodyComponent host,
    AttachableObjectComponent obj,
    Contact contact,
  ) {
    if (_attached.contains(obj)) return;
    if (_pending.any((p) => p.obj == obj)) return;
    if (contact.fixtureA.isSensor || contact.fixtureB.isSensor) return;

    _pending.add(_PendingAttach(host, obj));
  }

  void processPending() {
    if (_pending.isEmpty) return;

    final pending = List.of(_pending);
    _pending.clear();
    for (final attach in pending) {
      if (attach.obj.attached) continue;
      _attach(attach.host, attach.obj);
    }
  }

  void _attach(BodyComponent host, AttachableObjectComponent obj) {
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

    final anchor = obj.body.worldCenter.clone();
    final def = WeldJointDef<Body, Body>()
      ..initialize(host.body, obj.body, anchor)
      ..collideConnected = false;
    final joint = WeldJoint(def);
    world.createJoint(joint);
    _joints.add(joint);

    host.body.linearVelocity *= 0.8;
    host.body.angularVelocity *= 0.5;

    _attached.add(obj);
    obj.attached = true;
    session.onAttach(obj.score);
    (world as UfoWorld).progressRepository.save(session.bestScore);
    obj.pop();

    world.add(
      FlyingNumberComponent(
        position: obj.body.worldCenter.clone(),
        objectName: obj.name,
        objectScore: obj.score * session.comboLevel,
      ),
    );

    spawner?.onObjectAttached(obj);
    spawner?.respawnOne();

    SoundEffects.instance.playAttach();
  }

  void destroyAllJoints() {
    for (final joint in _joints) {
      world.destroyJoint(joint);
    }
    _joints.clear();
    _pending.clear();
  }

  void reset() {
    _attached.clear();
    _joints.clear();
    _pending.clear();
  }
}

class _PendingAttach {
  final BodyComponent host;
  final AttachableObjectComponent obj;

  _PendingAttach(this.host, this.obj);
}
