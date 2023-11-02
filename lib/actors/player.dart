import 'dart:async';
import 'dart:ui';

import 'package:app/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  walkRight,
  idleRight,
  walkLeft,
  idleLeft,
  walkUp,
  idleUp,
  walkDown,
  idleDown
}

enum PlayerDirection { left, right, up, down, idle }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.1;
  final Vector2 tileSize = Vector2(16, 16);
  double moveSpeed = 100; //Tiles Per Second.
  Vector2? movingToTile;

  String character;
  PlayerDirection playerDirection = PlayerDirection.idle;
  Vector2 directionVector = Vector2(0, 1);
  Vector2 playerBase = Vector2.zero();

  // Raycasting
  CollisionDetection<ShapeHitbox, Broadphase<ShapeHitbox>>? collisionDetection;
  Paint rayPaint = Paint()..color = Colors.red.withOpacity(0.6);
  late Offset rayOrigin;
  late Offset rayPosition;
  Vector2? intersection;

  Player({position, this.character = 'Player'}) : super(position: position) {
    // debugMode = true;
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    rayOrigin = Offset(tileSize.x / 2, 24);
    transform.offset = Vector2(0, 11);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    rayPosition =
        ((directionVector * 100) + Vector2(tileSize.x / 2, tileSize.y))
            .toOffset();

    // print("Position: $position");
    // print("RayOrigin: ${position + rayOrigin.toVector2()}");
    final ray = Ray2(
      origin: position + rayOrigin.toVector2(),
      direction: directionVector,
    );
    RaycastResult<ShapeHitbox>? result = collisionDetection?.raycast(ray);
    if (result != null) {
      print(result.distance);
      print(result.intersectionPoint);
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeysPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeysPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    bool bothVHorizontalPressed = isLeftKeysPressed && isRightKeysPressed;
    bool bothVerticalPressed = isUpKeyPressed && isDownKeyPressed;

    if (keysPressed.isEmpty || bothVerticalPressed || bothVHorizontalPressed) {
      playerDirection = PlayerDirection.idle;
    } else if (isLeftKeysPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeysPressed) {
      playerDirection = PlayerDirection.right;
    } else if (isUpKeyPressed) {
      playerDirection = PlayerDirection.up;
    } else if (isDownKeyPressed) {
      playerDirection = PlayerDirection.down;
    } else {
      playerDirection = PlayerDirection.idle;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    animations = {
      PlayerState.walkDown: _buildAnimation(
          state: 'Walk_Down (16x21)', amount: 3, textureSize: Vector2(16, 21)),
      PlayerState.walkUp: _buildAnimation(
          state: 'Walk_Up (16x21)', amount: 3, textureSize: Vector2(16, 21)),
      PlayerState.walkLeft: _buildAnimation(
          state: 'Walk_Left (16x21)', amount: 3, textureSize: Vector2(16, 21)),
      PlayerState.walkRight: _buildAnimation(
          state: 'Walk_Right (16x21)', amount: 3, textureSize: Vector2(16, 21)),
      PlayerState.idleDown: _buildAnimation(
          state: 'Walk_Down (16x21)', amount: 1, textureSize: Vector2(16, 21)),
      PlayerState.idleUp: _buildAnimation(
          state: 'Walk_Up (16x21)', amount: 1, textureSize: Vector2(16, 21)),
      PlayerState.idleLeft: _buildAnimation(
          state: 'Walk_Left (16x21)', amount: 1, textureSize: Vector2(16, 21)),
      PlayerState.idleRight: _buildAnimation(
          state: 'Walk_Right (16x21)', amount: 1, textureSize: Vector2(16, 21)),
    };

    current = PlayerState.walkDown;
  }

  SpriteAnimation _buildAnimation(
      {required state, required int amount, required Vector2 textureSize}) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state.png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: textureSize));
  }

  void _updatePlayerMovement(double dt) {
    if (movingToTile != null) {
      // Move to position
      Vector2 target = movingToTile!.clone();
      target.multiply(tileSize);
      position.moveToTarget(target, moveSpeed * dt);

      if (target == position) {
        movingToTile = null;
      }
      return;
    }

    double currentTileX = (position.x / tileSize.x).truncateToDouble();
    double currentTileY = (position.y / tileSize.y).truncateToDouble();
    double nextTileX = currentTileX;
    double nextTileY = currentTileY;

    switch (playerDirection) {
      case PlayerDirection.left:
        current = PlayerState.walkLeft;
        directionVector = Vector2(-1, 0);
        nextTileX--;
        break;
      case PlayerDirection.right:
        current = PlayerState.walkRight;
        directionVector = Vector2(1, 0);
        nextTileX++;
        break;
      case PlayerDirection.up:
        current = PlayerState.walkUp;
        directionVector = Vector2(0, -1);
        nextTileY--;
        break;
      case PlayerDirection.down:
        current = PlayerState.walkDown;
        directionVector = Vector2(0, 1);
        nextTileY++;
        break;
      case PlayerDirection.idle:
        switch (current) {
          case PlayerState.walkDown:
            current = PlayerState.idleDown;
            break;
          case PlayerState.walkUp:
            current = PlayerState.idleUp;
            break;
          case PlayerState.walkRight:
            current = PlayerState.idleRight;
            break;
          case PlayerState.walkLeft:
            current = PlayerState.idleLeft;
            break;
        }
        break;
    }
    movingToTile = Vector2(nextTileX, nextTileY);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Offset center = rayOrigin.translate(0, -8);
    canvas.drawLine(
      center,
      rayPosition,
      rayPaint,
    );
    canvas.drawCircle(center, 1, rayPaint);
  }
}
