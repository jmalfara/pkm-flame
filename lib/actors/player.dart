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

  // Movement
  double movementDelay = 0;
  Vector2? barrierInView;

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
    _updatePlayerDirection(dt);

    rayPosition =
        ((directionVector * 100) + Vector2(tileSize.x / 2, tileSize.y))
            .toOffset();

    final ray = Ray2(
      origin: position + rayOrigin.toVector2(),
      direction: directionVector,
    );
    RaycastResult<ShapeHitbox>? result = collisionDetection?.raycast(ray);

    bool canMove = (result?.distance ?? double.infinity) > 8;
    _updatePlayerMovement(canMove, dt);

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

  void _updatePlayerDirection(double dt) {
    if (movingToTile != null) {
      // Player is moving. Wait until the movement is done.
      return;
    }

    if (movementDelay > 0) {
      movementDelay -= dt;
      return;
    } else {
      movementDelay = 0;
    }

    Map<PlayerState, PlayerState> idleStates = {
      PlayerState.walkDown: PlayerState.idleDown,
      PlayerState.walkUp: PlayerState.idleUp,
      PlayerState.walkRight: PlayerState.idleRight,
      PlayerState.walkLeft: PlayerState.idleLeft,
    };

    switch (playerDirection) {
      case PlayerDirection.left:
        triggerMovement(PlayerState.walkLeft, Vector2(-1, 0));
        break;
      case PlayerDirection.right:
        triggerMovement(PlayerState.walkRight, Vector2(1, 0));
        break;
      case PlayerDirection.up:
        triggerMovement(PlayerState.walkUp, Vector2(0, -1));
        break;
      case PlayerDirection.down:
        triggerMovement(PlayerState.walkDown, Vector2(0, 1));
        break;
      case PlayerDirection.idle:
        current = idleStates[current] ?? current;
        return;
    }
  }

  void _updatePlayerMovement(bool canMove, double dt) {
    if (!canMove) {
      movingToTile = null;
      return;
    }

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
  }

  void triggerMovement(PlayerState newState, Vector2 direction) {
    directionVector = direction;

    bool isIdle = current == PlayerState.idleDown ||
        current == PlayerState.idleUp ||
        current == PlayerState.idleLeft ||
        current == PlayerState.idleRight;

    bool isDirectionSame = current == newState ||
        current == PlayerState.idleDown && newState == PlayerState.walkDown ||
        current == PlayerState.idleUp && newState == PlayerState.walkUp ||
        current == PlayerState.idleLeft && newState == PlayerState.walkLeft ||
        current == PlayerState.idleRight && newState == PlayerState.walkRight;

    if (!isIdle || isDirectionSame) {
      // Move the player
      double currentTileX = (position.x / tileSize.x).truncateToDouble();
      double currentTileY = (position.y / tileSize.y).truncateToDouble();
      Vector2 currentTileVector = Vector2(currentTileX, currentTileY);
      movingToTile = currentTileVector + directionVector;
      current = newState;
    } else {
      // Just change the state. We want to be able to just move direction with a single tap.
      movementDelay = 0.08;
      Map<PlayerState, PlayerState> stateSelector = {
        PlayerState.walkDown: PlayerState.idleDown,
        PlayerState.walkUp: PlayerState.idleUp,
        PlayerState.walkRight: PlayerState.idleRight,
        PlayerState.walkLeft: PlayerState.idleLeft,
      };
      current = stateSelector[newState];
    }
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
