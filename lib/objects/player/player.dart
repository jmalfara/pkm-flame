// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';

import 'package:app/extensions/game_extensions.dart';
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

  Player(
      {super.position,
      super.size,
      super.moveSpeed = 100,
      this.character = 'Player'});

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    size = Vector2(16, 21);
    transform.offset = Vector2(0, -5);
    return super.onLoad();
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

    final isShiftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.shiftLeft);

    bool bothVHorizontalPressed = isLeftKeysPressed && isRightKeysPressed;
    bool bothVerticalPressed = isUpKeyPressed && isDownKeyPressed;

    if (isShiftKeyPressed) {
      if (isLeftKeysPressed) {
        changeIdleDirection(PlayerDirection.left);
      } else if (isRightKeysPressed) {
        changeIdleDirection(PlayerDirection.right);
      } else if (isUpKeyPressed) {
        changeIdleDirection(PlayerDirection.up);
      } else if (isDownKeyPressed) {
        changeIdleDirection(PlayerDirection.down);
      }
    } else {
      if (keysPressed.isEmpty ||
          bothVerticalPressed ||
          bothVHorizontalPressed) {
        changeDirection(PlayerDirection.idle);
      } else if (isLeftKeysPressed) {
        changeDirection(PlayerDirection.left);
      } else if (isRightKeysPressed) {
        changeDirection(PlayerDirection.right);
      } else if (isUpKeyPressed) {
        changeDirection(PlayerDirection.up);
      } else if (isDownKeyPressed) {
        changeDirection(PlayerDirection.down);
      } else {
        changeDirection(PlayerDirection.idle);
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    Vector2 playerSize = Vector2(16, 21);
    animations = {
      PlayerState.walkDown: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Down (16x21).png',
        amount: 3,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
        loop: true,
      ),
      PlayerState.walkUp: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Up (16x21).png',
        amount: 3,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
        loop: true,
      ),
      PlayerState.walkLeft: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Left (16x21).png',
        amount: 3,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
        loop: true,
      ),
      PlayerState.walkRight: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Right (16x21).png',
        amount: 3,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
        loop: true,
      ),
      PlayerState.idleDown: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Down (16x21).png',
        amount: 1,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
      ),
      PlayerState.idleUp: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Up (16x21).png',
        amount: 1,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
      ),
      PlayerState.idleLeft: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Left (16x21).png',
        amount: 1,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
      ),
      PlayerState.idleRight: game.buildAnimation(
        asset: 'Main Characters/$character/Walk_Right (16x21).png',
        amount: 1,
        row: 0,
        startColumn: 0,
        textureSize: playerSize,
        stepTime: stepTime,
      ),
    };
    current = PlayerState.idleDown;
  }

  @override
  onUpdateTileAnimation(
      PlayerDirection oldDirection, PlayerDirection newDirection) {
    if (newDirection == oldDirection) return;
    print("$oldDirection -> $newDirection");

    if (newDirection == PlayerDirection.idle) {
      dynamic stateSelector = {
        PlayerDirection.down: PlayerState.idleDown,
        PlayerDirection.up: PlayerState.idleUp,
        PlayerDirection.right: PlayerState.idleRight,
        PlayerDirection.left: PlayerState.idleLeft,
      };
      current = stateSelector[oldDirection];
    } else {
      dynamic stateSelector = {
        PlayerDirection.down: PlayerState.walkDown,
        PlayerDirection.up: PlayerState.walkUp,
        PlayerDirection.right: PlayerState.walkRight,
        PlayerDirection.left: PlayerState.walkLeft,
      };
      current = stateSelector[newDirection];
      animationTicker?.currentIndex = 1;
    }
  }

  changeIdleDirection(PlayerDirection direction) {
    changeDirection(PlayerDirection.idle);
    dynamic stateSelector = {
      PlayerDirection.down: PlayerState.idleDown,
      PlayerDirection.up: PlayerState.idleUp,
      PlayerDirection.right: PlayerState.idleRight,
      PlayerDirection.left: PlayerState.idleLeft,
    };
    dynamic newState = stateSelector[direction];
    current = newState;
  }
}
