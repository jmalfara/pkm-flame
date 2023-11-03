import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class StaticBarrier extends PositionComponent with CollisionCallbacks {
  StaticBarrier({required position, required size})
      : super(position: position, size: size) {
    debugMode = true;
  }

  @override
  void onLoad() {
    add(RectangleHitbox());
  }
}
