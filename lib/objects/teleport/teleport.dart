import 'package:app/objects/_base/tile.dart';
import 'package:app/objects/player/player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Teleport extends Tile with HasGameRef<FlameGame> {
  Vector2 toTile;
  Vector2? moveToTile;

  Teleport({
    super.position,
    super.size,
    required this.toTile,
    required this.moveToTile,
  });

  @override
  onTileEnter(PositionComponent other) {
    print(toTile);
    if (other is Player) {
      other.teleport(toTile, moveToTile);
    }
  }

  @override
  onTileExit(PositionComponent other) {
    // print("Tile Exit: $other");
  }
}
