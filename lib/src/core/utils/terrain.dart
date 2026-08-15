import 'package:flame/components.dart';

List<List<Vector2>> generateTerrainSegments(
  List<Vector2> points,
  double extrusionY,
) {
  assert(points.isNotEmpty, 'points must not be empty');
  assert(
    points.length >= 2,
    'points must have at least 2 points to create segments',
  );
  assert(extrusionY > 0, 'extrusionY must be positive (extruding downward)');

  final sorted = List<Vector2>.from(points)
    ..sort((a, b) => a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));

  final segments = <List<Vector2>>[];
  for (var i = 0; i < sorted.length - 1; i++) {
    final p1 = sorted[i];
    final p2 = sorted[i + 1];
    segments.add([
      Vector2(p1.x, p1.y),
      Vector2(p2.x, p2.y),
      Vector2(p2.x, p2.y + extrusionY),
      Vector2(p1.x, p1.y + extrusionY),
    ]);
  }
  return segments;
}
