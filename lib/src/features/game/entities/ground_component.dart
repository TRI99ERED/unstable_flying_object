import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:unstable_flying_object/src/core/utils/terrain.dart';

class GroundComponent extends BodyComponent {
  final double initialAngle;
  final List<Vector2> points;
  final double extrusionY;
  final double friction;
  final Paint initialPaint;
  final int initialPriority;

  GroundComponent(
    this.initialAngle,
    this.points,
    this.initialPaint, [
    this.extrusionY = 200,
    this.friction = 0.4,
    this.initialPriority = 0,
  ]) {
    priority = initialPriority;
    paint = initialPaint;
    bodyDef = BodyDef()
      ..userData = this
      ..angle = initialAngle
      ..type = BodyType.static;

    final segments = generateTerrainSegments(points, extrusionY);
    fixtureDefs = segments.map((verts) {
      final shape = PolygonShape()..set(verts);
      return FixtureDef(shape)
        ..density = 1.0
        ..friction = friction
        ..restitution = 0.1;
    }).toList();
  }
}
