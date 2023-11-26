import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/layers.dart';

class BackgroundTile {
  Sprite sprite;
  Vector2 position;

  BackgroundTile(this.sprite, this.position);
}

class Background extends PreRenderedLayer {
  final List<BackgroundTile> tiles;
  Background(this.tiles);

  @override
  void drawLayer() {
    Paint paint = Paint();
    paint.filterQuality = FilterQuality.none;
    paint.isAntiAlias = false;
    for (BackgroundTile tile in tiles) {
      tile.sprite.render(canvas, position: tile.position, overridePaint: paint);
    }
  }
}
