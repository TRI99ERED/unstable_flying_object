import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class WrapSystem extends Component with HasGameReference<UfoGame> {
  @override
  void update(double dt) {
    final gameRef = game;
    final world = gameRef.world;
    final halfWidth = UfoWorld.kWorldWidth / 2;

    _wrapAssembly(gameRef, world, halfWidth);
    _wrapUnattached(gameRef, world, halfWidth);
  }

  void _wrapAssembly(UfoGame gameRef, UfoWorld world, double halfWidth) {
    final ufo = world.children.whereType<UfoComponent>().firstOrNull;
    if (ufo == null) return;

    final attached = gameRef.weldManager.attached;
    final beamed = ufo.beamedObjects;

    final bodies = <Body>[ufo.body];
    for (final obj in attached) {
      bodies.add(obj.body);
    }
    for (final obj in beamed) {
      if (!obj.attached) {
        bodies.add(obj.body);
      }
    }

    double? wrapOffset;
    for (final body in bodies) {
      if (body.position.x > halfWidth) {
        wrapOffset = -UfoWorld.kWorldWidth;
        break;
      } else if (body.position.x < -halfWidth) {
        wrapOffset = UfoWorld.kWorldWidth;
        break;
      }
    }

    if (wrapOffset != null) {
      final offset = Vector2(wrapOffset, 0);
      for (final body in bodies) {
        body.setTransform(body.position + offset, body.angle);
      }
    }
  }

  void _wrapUnattached(UfoGame gameRef, UfoWorld world, double halfWidth) {
    final spawner = gameRef.weldManager.spawner;
    if (spawner == null) return;

    final ufo = world.children.whereType<UfoComponent>().firstOrNull;
    final cameraX = ufo != null
        ? ufo.body.position.x
        : gameRef.camera.viewfinder.position.x;

    for (final obj in spawner.spawned) {
      if (obj.attached) continue;
      final dx = obj.body.position.x - cameraX;
      if (dx > halfWidth) {
        obj.body.setTransform(
          obj.body.position - Vector2(UfoWorld.kWorldWidth, 0),
          obj.body.angle,
        );
      } else if (dx < -halfWidth) {
        obj.body.setTransform(
          obj.body.position + Vector2(UfoWorld.kWorldWidth, 0),
          obj.body.angle,
        );
      }
    }
  }
}
