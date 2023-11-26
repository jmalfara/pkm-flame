import 'dart:collection';

import 'package:app/objects/player/player_direction.dart';
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

  TileActor({super.position, super.size, this.moveSpeed = 100});

  @override
  RectangleHitbox loadHitbox() {
    RectangleHitbox hitbox = RectangleHitbox(size: tileSize);
    hitbox.transform.x = 0;
    hitbox.transform.y = 5;
    hitbox.collisionType = CollisionType.active;
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

    Vector2 currentTileVector = position.toTileVector(tileSize);
    moveToTile(currentTileVector + playerDirection.directionVector);
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

  void moveToTile(Vector2 tile) {
    // if (canMoveTo(tile)) {
    movingToTile = tile;
    // }
  }

  void movePlayer(PlayerDirection direction) {
    if (movingToTile != null) {
      return;
    }
    playerDirection = direction;
    Vector2 currentTileVector = position.toTileVector(tileSize);
    moveToTile(currentTileVector + playerDirection.directionVector);
  }

  bool canMoveTo(Vector2 tile) {
    dynamic collidedRec = tileCollisionMap.entries
        .map((e) => e.value)
        .where((element) => element.containsPoint(movingToTile!))
        .firstOrNull;

    return collidedRec == null;
  }

  void teleport(Vector2 tile, Vector2? moveToTile) {
    position = Vector2(tile.x * tileSize.x, tile.y * tileSize.y);
    if (moveToTile != null) {
      movingToTile = moveToTile;
    } else {
      movingToTile = tile;
    }
  }

  onTileUpdate() {}
}
