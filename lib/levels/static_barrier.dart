import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class StaticBarrier extends PositionComponent with CollisionCallbacks {
  StaticBarrier({required position, required size})
      : super(position: position, size: size) {
    debugMode = true;
    debugCoordinatesPrecision = 0;
  }

  @override
  void onLoad() {
    add(RectangleHitbox());
  }

  @override
  set onCollisionStartCallback(
      CollisionCallback<PositionComponent>? _onCollisionStartCallback) {
    super.onCollisionStartCallback = _onCollisionStartCallback;
    print("Collision");
  }
}
