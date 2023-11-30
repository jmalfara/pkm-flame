import 'package:app/objects/_base/tile.dart';
import 'package:app/objects/player/player.dart';
import 'package:app/objects/player/player_direction.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Teleport extends Tile with HasGameRef<FlameGame> {
  Vector2 toTile;

  Teleport({
    super.position,
    super.size,
    required this.toTile,
  });

  @override
  onTileEnter(PositionComponent other) {
    print(toTile);
    if (other is Player) {
      other.teleport(toTile, PlayerDirection.down);
    }
  }

  @override
  onTileExit(PositionComponent other) {
    // print("Tile Exit: $other");
  }
}
