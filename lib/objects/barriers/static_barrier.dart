import 'package:app/objects/barriers/barrier.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class StaticBarrier extends PositionComponent with CollisionCallbacks, Barrier {
  StaticBarrier({super.position, super.size, bool debugMode = false}) {
    debugMode = debugMode;
  }

  @override
  void onLoad() {
    RectangleHitbox hitbox = RectangleHitbox();
    hitbox.collisionType = CollisionType.passive;
    add(hitbox);
  }
}
