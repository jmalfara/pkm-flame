import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Tile extends SpriteAnimationGroupComponent with CollisionCallbacks {
  // Movement
  final Vector2 tileSize = Vector2(16, 16);
  bool entered = false;

  Tile({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    RectangleHitbox hitbox = loadHitbox();
    add(hitbox);
    return super.onLoad();
  }

  RectangleHitbox loadHitbox() {
    RectangleHitbox hitbox = RectangleHitbox(size: size - Vector2(1, 1));
    hitbox.transform.x = 0.5;
    hitbox.transform.y = 0.5;
    hitbox.collisionType = CollisionType.passive;
    return hitbox;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    reportEnteredState(other);
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    reportEnteredState(other);
    super.onCollisionEnd(other);
  }

  reportEnteredState(PositionComponent other) {
    bool enteredObject = other.containsPoint(center);
    if (enteredObject && !entered) {
      onTileEnter(other);
    } else if (!enteredObject && entered) {
      onTileExit(other);
    }
    entered = enteredObject;
  }

  onTileEnter(PositionComponent other) {}
  onTileExit(PositionComponent other) {}
}
