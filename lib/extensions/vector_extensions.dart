import 'package:flame/components.dart';

extension TileVector2 on Vector2 {
  Vector2 toTileVector(Vector2 tileSize) {
    double currentTileX = (x / tileSize.x).truncateToDouble();
    double currentTileY = (y / tileSize.y).truncateToDouble();
    return Vector2(currentTileX, currentTileY);
  }
}
