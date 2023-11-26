// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'dart:ui';

import 'package:app/objects/player/player_direction.dart';
import 'package:app/objects/_base/tile_actor.dart';
import 'package:app/pixel_adventure.dart';
import 'package:flame/components.dart';
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

class Player extends TileActor
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  final double stepTime = 0.1;
  String character;

  Player({super.position, super.size, this.character = 'Player'});

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    size = Vector2(16, 21);
    transform.offset = Vector2(0, -5);
    return super.onLoad();
  }

  @override
  onTileUpdate() {
    super.onTileUpdate();

    Map<PlayerState, PlayerState> idleStates = {
      PlayerState.walkDown: PlayerState.idleDown,
      PlayerState.walkUp: PlayerState.idleUp,
      PlayerState.walkRight: PlayerState.idleRight,
      PlayerState.walkLeft: PlayerState.idleLeft,
    };

    switch (playerDirection.runtimeType) {
      case PlayerDirectionLeft:
        triggerMovement(PlayerState.walkLeft);
        break;
      case PlayerDirectionRight:
        triggerMovement(PlayerState.walkRight);
        break;
      case PlayerDirectionUp:
        triggerMovement(PlayerState.walkUp);
        break;
      case PlayerDirectionDown:
        triggerMovement(PlayerState.walkDown);
        break;
      case PlayerDirectionIdle:
        current = idleStates[current] ?? current;
        return;
    }
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

  void triggerMovement(PlayerState newState) {
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
      current = newState;
    } else {
      // Just change the state. We want to be able to just move direction with a single tap.
      newDirectionDelay = 0.08;
      Map<PlayerState, PlayerState> stateSelector = {
        PlayerState.walkDown: PlayerState.idleDown,
        PlayerState.walkUp: PlayerState.idleUp,
        PlayerState.walkRight: PlayerState.idleRight,
        PlayerState.walkLeft: PlayerState.idleLeft,
      };
      current = stateSelector[newState];
    }
  }
}
