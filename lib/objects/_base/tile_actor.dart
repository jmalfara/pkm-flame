import 'dart:collection';

import 'package:app/actors/player_direction.dart';
import 'package:app/extensions/vector_extensions.dart';
import 'package:app/objects/_base/tile.dart';
import 'package:app/objects/barriers/barrier.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class TileActor extends Tile {
  // Movement
  PlayerDirection playerDirection = PlayerDirection.idle;
  double moveSpeed;
  double newDirectionDelay = 0;
  Vector2? movingToTile;
  Map<int, Rect> tileCollisionMap = {};

  TileActor({position, required size, this.moveSpeed = 100})
      : super(position: position, size: size);

  @override
  RectangleHitbox loadHitbox() {
    RectangleHitbox hitbox = RectangleHitbox(size: tileSize);
    hitbox.transform.x = 0;
    hitbox.transform.y = 5;
    hitbox.collisionType = CollisionType.active;
    // hitbox.debugMode = true;
    return hitbox;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (movingToTile != null) {
      // Check for collisions
      bool canMoveToTile = canMoveTo(movingToTile!);
      if (!canMoveToTile) {
        movingToTile = null;
        return;
      }

      // Move to position
      Vector2 target = movingToTile!.clone();
      target.multiply(tileSize);
      position.moveToTarget(target, moveSpeed * dt);

      if (target == position) {
        movingToTile = null;
      }
      return;
    }

    onTileUpdate();
    if (newDirectionDelay > 0) {
      newDirectionDelay -= dt;
      return;
    } else {
      newDirectionDelay = 0;
    }

    double currentTileX = (position.x / tileSize.x).truncateToDouble();
    double currentTileY = (position.y / tileSize.y).truncateToDouble();
    Vector2 currentTileVector = Vector2(currentTileX, currentTileY);
    movingToTile = currentTileVector + playerDirection.directionVector;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Barrier) {
      Vector2 tileOrigin = other.position.toTileVector(tileSize);
      Vector2 numberOfTilesXY =
          Vector2(other.width, other.height).toTileVector(tileSize);

      Rect componentTileRect = Rect.fromLTRB(tileOrigin.x, tileOrigin.y,
          tileOrigin.x + numberOfTilesXY.x, tileOrigin.y + numberOfTilesXY.y);

      tileCollisionMap.putIfAbsent(other.hashCode, () => componentTileRect);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    tileCollisionMap.remove(other.hashCode);
  }

  bool canMoveTo(Vector2 tile) {
    dynamic collidedRec = tileCollisionMap.entries
        .map((e) => e.value)
        .where((element) => element.containsPoint(movingToTile!))
        .firstOrNull;

    return collidedRec == null;
  }

  onTileUpdate() {}
}
