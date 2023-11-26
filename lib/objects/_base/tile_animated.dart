import 'dart:async';

import 'package:app/extensions/game_extensions.dart';
import 'package:app/objects/_base/tile.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum AnimatedTileState { idle, collision }

class TileAnimated extends Tile with HasGameRef<FlameGame> {
  SpriteAnimation Function(Game) collision;
  SpriteAnimation Function(Game) idle;

  TileAnimated(
      {super.position,
      super.size,
      required this.idle,
      required this.collision});

  static TileAnimated fromSheet(
      {required Vector2 position,
      required Vector2 size,
      required String sheet,
      required int row}) {
    Vector2 tileSize = Vector2(16, 16);
    double stepTime = 0.2;
    return TileAnimated(
        position: position,
        size: tileSize,
        idle: (game) {
          return game.buildAnimation(
            asset: sheet,
            amount: 10,
            stepTime: stepTime,
            textureSize: tileSize,
            row: row,
            startColumn: 0,
            loop: true,
          );
        },
        collision: (game) {
          return game.buildAnimation(
            asset: sheet,
            amount: 10,
            stepTime: stepTime,
            textureSize: tileSize,
            row: row,
            startColumn: 10,
          );
        });
  }

  @override
  FutureOr<void> onLoad() {
    // size = Vector2(16, 16);
    animations = {
      AnimatedTileState.idle: idle(game),
      AnimatedTileState.collision: collision(game)
    };
    current = AnimatedTileState.idle;

    return super.onLoad();
  }

  @override
  onTileEnter(PositionComponent other) {
    current = AnimatedTileState.collision;
    animationTicker?.reset();
    animationTicker?.completed.whenComplete(() {
      current = AnimatedTileState.idle;
    });
  }

  @override
  onTileExit(PositionComponent other) {
    // print("Tile Exit: $other");
  }
}
