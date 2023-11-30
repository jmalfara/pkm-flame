import 'dart:async';
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
  PlayerDirection nextPlayerDirection = PlayerDirection.idle;
  PlayerDirection playerDirection = PlayerDirection.idle;
  double moveSpeed;
  Vector2? movingToTile;
  Completer<bool>? moveToTileCompleter;
  Map<int, Rect> tileCollisionMap = {};

  TileActor({super.position, super.size, this.moveSpeed = 10});

  @override
  RectangleHitbox loadHitbox() {
    hitbox = RectangleHitbox(size: tileSize);
    hitbox.transform.x = 0;
    hitbox.transform.y = 5;
    hitbox.collisionType = CollisionType.active;
    return hitbox;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (movingToTile != null) {
      // print(movingToTile);
      // Check for collisions
      bool canMoveToTile = canMoveTo(movingToTile!);
      if (!canMoveToTile) {
        completeMoveToTile();
        return;
      }

      // Move to position
      Vector2 target = movingToTile!.clone();
      target.multiply(tileSize);
      position.moveToTarget(target, moveSpeed * dt);

      if (target == position) {
        completeMoveToTile();
      }
      return;
    }

    onTileUpdate();

    Vector2 currentTileVector = position.toTileVector(tileSize);
    Vector2 nextTile = currentTileVector + playerDirection.directionVector;
    moveToTile(nextTile, () {
      print("Tile Moved");
    });
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

  changeDirection(PlayerDirection direction) {
    nextPlayerDirection = direction;
  }

  void completeMoveToTile() {
    movingToTile = null;
    if (moveToTileCompleter?.isCompleted == false) {
      moveToTileCompleter?.complete(false);
    }
    onUpdateTileAnimation(playerDirection, nextPlayerDirection);
    playerDirection = nextPlayerDirection;
  }

  void moveToTile(Vector2 tile, Function callback) async {
    movingToTile = tile;
    moveToTileCompleter = Completer();
    await moveToTileCompleter?.future;
    moveToTileCompleter = null;
    callback();
  }

  void teleport(Vector2 tile, PlayerDirection direction) {
    current = direction;
    // onUpdateTileAnimation(direction, PlayerDirection.idle);
    hitbox.collisionType = CollisionType.inactive;
    position = Vector2(tile.x * tileSize.x, tile.y * tileSize.y);
    playerDirection = direction;
    nextPlayerDirection = PlayerDirection.idle;
    completeMoveToTile();
    moveToTile(tile, () {
      hitbox.collisionType = CollisionType.active;
    });
  }

  onTileUpdate() {}
  onUpdateTileAnimation(
      PlayerDirection oldDirection, PlayerDirection newDirection) {}
}
