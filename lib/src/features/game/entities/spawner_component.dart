import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class SpawnerComponent extends Component with HasGameReference<UfoGame> {
  static const double kSpawnMargin = 6;
  static const double kGroundY = 25;
  static const int kSpawnCount = 20;
  static const double kMinSpawnDistance = 5;

  final Set<AttachableObjectComponent> spawned = {};

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    populate();
  }

  void populate() {
    for (var i = 0; i < kSpawnCount; i++) {
      final x =
          -UfoWorld.kWorldWidth / 2 +
          kSpawnMargin +
          i * (UfoWorld.kWorldWidth - 2 * kSpawnMargin) / kSpawnCount;
      spawnAt(x);
    }
  }

  void respawnOne() {
    final visible = game.camera.visibleWorldRect;
    final dir = game.moveIntent.x.sign;
    final x = dir >= 0
        ? visible.right + kSpawnMargin
        : visible.left - kSpawnMargin;
    spawnAt(_wrapX(x));
  }

  void onObjectAttached(AttachableObjectComponent obj) {
    spawned.remove(obj);
  }

  double _wrapX(double x) {
    final half = UfoWorld.kWorldWidth / 2;
    if (x > half) return x - UfoWorld.kWorldWidth;
    if (x <= -half) return x + UfoWorld.kWorldWidth;
    return x;
  }

  bool _isPositionClear(double x) {
    for (final obj in spawned) {
      if ((obj.initialPosition.x - x).abs() < kMinSpawnDistance) {
        return false;
      }
    }
    return true;
  }

  void spawnAt(double x, {double y = kGroundY}) {
    if (!_isPositionClear(x)) {
      return;
    }

    final weighted = <(AttachableObjectComponent Function(Vector2), double)>[
      ((p) => CrateComponent(initialPosition: p), 2.5),
      ((p) => CarComponent(initialPosition: p), 1.5),
      ((p) => ConeComponent(initialPosition: p), 5.0),
      ((p) => CowComponent(initialPosition: p), 1.0),
    ];
    final totalWeight = weighted.fold<double>(0, (sum, e) => sum + e.$2);
    final roll = Random().nextDouble() * totalWeight;
    var acc = 0.0;
    AttachableObjectComponent Function(Vector2) builder = weighted[0].$1;
    for (final (b, w) in weighted) {
      acc += w;
      if (roll < acc) {
        builder = b;
        break;
      }
    }

    final obj = builder(Vector2(x, y));
    game.world.add(obj);
    spawned.add(obj);
  }

  @override
  void onRemove() {
    super.onRemove();
    spawned.clear();
  }
}
