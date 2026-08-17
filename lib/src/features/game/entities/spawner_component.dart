import 'dart:async';

import 'package:flame/components.dart';
import 'package:unstable_flying_object/src/features/game/entities/attachable_object_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

class SpawnerComponent extends Component with HasGameReference<UfoGame> {
  static const double kSpawnMargin = 0;
  static const double kGroundY = 25;
  static const int kSpawnCount = 20;

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
    final dir = game.moveIntent.x.sign; // idle => dir 0 => right
    final x = dir >= 0
        ? visible.right + kSpawnMargin
        : visible.left - kSpawnMargin;
    spawnAt(_wrapX(x)); // always offscreen
  }

  void onObjectAttached(AttachableObjectComponent obj) {
    spawned.remove(obj); // fixes bug #2
  }

  double _wrapX(double x) {
    final half = UfoWorld.kWorldWidth / 2;
    if (x > half) return x - UfoWorld.kWorldWidth;
    if (x <= -half) return x + UfoWorld.kWorldWidth;
    return x;
  }

  void spawnAt(double x, {double y = kGroundY}) {
    final obj = CrateComponent(initialPosition: Vector2(x, y));
    game.world.add(obj);
    spawned.add(obj);
  }

  @override
  void onRemove() {
    super.onRemove();
    spawned.clear();
  }
}
