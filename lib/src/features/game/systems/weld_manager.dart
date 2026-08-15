import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/game_session.dart';

class WeldManager {
  final Forge2DWorld world;
  final GameSession session;

  final Set<AttachableObjectComponent> _attached = {};

  Set<AttachableObjectComponent> get attached => _attached;

  WeldManager(this.world, this.session);

  void attach(UfoComponent ufo, AttachableObjectComponent obj, Vector2 anchor) {
    if (_attached.contains(obj)) return;

    final ufoVel = ufo.body.linearVelocity;
    final ufoAng = ufo.body.angularVelocity;
    final offset = obj.body.worldCenter - ufo.body.worldCenter;
    obj.body
      ..linearVelocity = ufoVel + Vector2(-ufoAng * offset.y, ufoAng * offset.x)
      ..angularVelocity = ufoAng
      ..setAwake(true);

    final def = WeldJointDef<Body, Body>()
      ..initialize(ufo.body, obj.body, anchor)
      ..collideConnected = false;
    world.createJoint(WeldJoint(def));

    _attached.add(obj);
    obj.attached = true;
    ufo.beamedObjects.remove(obj);
    session.addScore();
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
