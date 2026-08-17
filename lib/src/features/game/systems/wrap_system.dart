import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/features/game/entities/ufo_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class WrapSystem extends Component with HasGameReference<UfoGame> {
  static const double _kCameraHalfWidth =
      UfoGame.kGameWidth / (2 * 10); // 64 world units at zoom 10
  static const double _kGhostMargin = 4;

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

    for (final obj in spawner.spawned) {
      if (obj.attached) continue;
      final pos = obj.body.position;
      if (pos.x > halfWidth) {
        obj.body.setTransform(
          pos - Vector2(UfoWorld.kWorldWidth, 0),
          obj.body.angle,
        );
      } else if (pos.x < -halfWidth) {
        obj.body.setTransform(
          pos + Vector2(UfoWorld.kWorldWidth, 0),
          obj.body.angle,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderGhosts(canvas);
  }

  void _renderGhosts(Canvas canvas) {
    final gameRef = game;
    final world = gameRef.world;
    final cameraX = gameRef.camera.viewfinder.position.x;
    final halfWidth = UfoWorld.kWorldWidth / 2;

    for (final child in world.children) {
      if (child is BodyComponent &&
          child.body.bodyType == BodyType.dynamic) {
        _renderBodyGhost(canvas, child, cameraX, halfWidth);
      }
    }
  }

  void _renderBodyGhost(
    Canvas canvas,
    BodyComponent body,
    double cameraX,
    double halfWidth,
  ) {
    final bodyX = body.body.position.x;
    final rawDx = bodyX - cameraX;

    final ghostDx = rawDx > halfWidth
        ? -UfoWorld.kWorldWidth
        : rawDx < -halfWidth
            ? UfoWorld.kWorldWidth
            : 0.0;
    if (ghostDx == 0) return;

    final ghostX = bodyX + ghostDx;
    final ghostDistFromCamera = (ghostX - cameraX).abs();
    if (ghostDistFromCamera > _kCameraHalfWidth + _kGhostMargin) return;

    canvas.save();
    canvas.translate(ghostDx, 0);
    body.renderTree(canvas);
    canvas.restore();
  }
}
