import 'dart:async';

import 'package:app/actors/player.dart';
import 'package:app/objects/barriers/static_barrier.dart';
import 'package:app/objects/bushes/Bush.dart';
import 'package:app/pixel_adventure.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World
    with HasGameRef<PixelAdventure>, HasCollisionDetection {
  late TiledComponent level;
  final String levelName;
  final Player player;
  final int tileSetWidth = 88;

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2.all(16));
    add(level);

    final barriersLayer = level.tileMap.getLayer<ObjectGroup>('Barriers');
    List<TiledObject> barrierObjects = barriersLayer?.objects ?? [];
    for (final object in barrierObjects) {
      Vector2 position = Vector2(object.x, object.y);
      StaticBarrier barrier = StaticBarrier(
          position: position, size: Vector2(object.width, object.height));
      add(barrier);
    }

    final bushesLayer = level.tileMap.getLayer<ObjectGroup>('Bushes');
    List<TiledObject> bushObjects = bushesLayer?.objects ?? [];
    for (final object in bushObjects) {
      Vector2 position = Vector2(object.x, object.y);
      Bush bush =
          Bush(position: position, size: Vector2(object.width, object.height));
      add(bush);
    }

    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
      }
    }
    return super.onLoad();
  }
}
