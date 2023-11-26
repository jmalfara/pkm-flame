import 'dart:async';

import 'package:app/extensions/vector_extensions.dart';
import 'package:app/objects/_base/tile_animated.dart';
import 'package:app/objects/_base/tile.dart' as BaseTile;
import 'package:app/objects/background/background.dart';
import 'package:app/objects/player/player.dart';
import 'package:app/objects/barriers/static_barrier.dart';
import 'package:app/objects/teleport/teleport.dart';
import 'package:app/pixel_adventure.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World
    with HasGameRef<PixelAdventure>, HasCollisionDetection {
  late TiledComponent level;
  final String levelName;
  final Player player;
  final int tileSetWidth = 88;
  final Vector2 tileSize = Vector2(16, 16);

  Background? background;

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    TiledComponent level =
        await TiledComponent.load(levelName, Vector2.all(16));

    renderTiles(level);
    renderBarriers(level);
    renderAnimatedTiles(level);
    renderTeleport(level);
    renderPlayer(level);
    renderLiftedObjects(level);

    return super.onLoad();
  }

  void renderTiles(TiledComponent level) {
    Image image = game.images.fromCache('Terrain/Terrain (16x16).png');
    final backgroundLayer = level.tileMap.getLayer<TileLayer>('Background')!;
    List<BackgroundTile> backgroundTiles = [];
    for (int x = 0; x < backgroundLayer.width; x++) {
      for (int y = 0; y < backgroundLayer.height; y++) {
        int tile =
            (level.tileMap.getTileData(layerId: 0, x: x, y: y)?.tile ?? 0) - 1;
        if (tile == -1) {
          continue;
        }

        // Find the tile to copy.
        int positionX = tile % 88;
        int positionY = (tile / 88).truncate();
        Vector2 backgroundVector =
            Vector2(positionX.toDouble(), positionY.toDouble());
        backgroundVector.multiply(tileSize);

        Sprite sprite = Sprite(
          image,
          srcPosition: backgroundVector,
          srcSize: Vector2.all(16),
        );

        // print(sprite.srcPosition);
        backgroundTiles.add(BackgroundTile(sprite, Vector2(x * 16, y * 16)));
      }
    }
    // print(backgroundTiles.length);
    background = Background(backgroundTiles);
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);
    background?.render(canvas);
  }

  void renderBarriers(TiledComponent level) {
    final barriersLayer = level.tileMap.getLayer<ObjectGroup>('Barriers');
    List<TiledObject> barrierObjects = barriersLayer?.objects ?? [];
    for (final object in barrierObjects) {
      Vector2 position = Vector2(object.x, object.y);
      StaticBarrier barrier = StaticBarrier(
          position: position, size: Vector2(object.width, object.height));
      add(barrier);
    }
  }

  void renderAnimatedTiles(TiledComponent level) {
    final animatedTiles = level.tileMap.getLayer<Group>('AnimatedTiles');
    List<Layer> layers = animatedTiles?.layers ?? [];
    String animatedObjectsSheet = 'Objects/AnimatedObjects.png';

    for (final layer in layers) {
      final objectLayer = level.tileMap.getLayer<ObjectGroup>(layer.name);
      List<TiledObject> objects = objectLayer?.objects ?? [];
      for (final object in objects) {
        Vector2 position = Vector2(object.x, object.y);
        TileAnimated? tile;
        switch (layer.name) {
          case 'Bush':
            tile = TileAnimated.fromSheet(
              position: position,
              size: tileSize,
              sheet: animatedObjectsSheet,
              row: 0,
            );
            break;
          case 'Flower1':
            tile = TileAnimated.fromSheet(
              position: position,
              size: tileSize,
              sheet: animatedObjectsSheet,
              row: 1,
            );
            break;
          case 'Flower2':
            tile = TileAnimated.fromSheet(
              position: position,
              size: tileSize,
              sheet: animatedObjectsSheet,
              row: 2,
            );
            break;
        }
        if (tile != null) {
          add(tile);
        }
      }
    }
  }

  void renderTeleport(TiledComponent level) {
    final layer = level.tileMap.getLayer<ObjectGroup>('Teleport');
    List<TiledObject> objects = layer?.objects ?? [];
    for (final object in objects) {
      int destinationX = object.properties.getValue('destinationX');
      int destinationY = object.properties.getValue('destinationY');
      print(destinationX);
      print(destinationY);
      Vector2 destination =
          Vector2(destinationX.toDouble(), destinationY.toDouble());
      Vector2 position = Vector2(object.x, object.y);

      Teleport tile = Teleport(
        position: position,
        size: tileSize,
        toTile: destination,
        moveToTile: destination,
      );
      add(tile);
    }
  }

  void renderPlayer(TiledComponent level) {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
      }
    }
  }

  void renderLiftedObjects(TiledComponent level) {
    final liftedLayers = level.tileMap.getLayer<ObjectGroup>('Lift');
    List<TiledObject> liftedObjects = liftedLayers?.objects ?? [];
    Vector2 tileSize = Vector2(16, 16);
    for (final object in liftedObjects) {
      Vector2 tileVector =
          Vector2(object.width, object.height).toTileVector(tileSize);

      for (int x = 0; x < tileVector.x; x++) {
        for (int y = 0; y < tileVector.y; y++) {
          // Find the tiles to copy.
          Vector2 position =
              Vector2(object.x + (x * tileSize.x), object.y + (y * tileSize.y));
          Vector2 tilePosition = position.toTileVector(tileSize);

          int tile = (level.tileMap
                      .getTileData(
                          layerId: 0,
                          x: tilePosition.x.toInt(),
                          y: tilePosition.y.toInt())
                      ?.tile ??
                  0) -
              1;

          // Find the tile to copy.
          int positionX = tile % 88;
          int positionY = (tile / 88).truncate();
          Vector2 backgroundVector =
              Vector2(positionX.toDouble(), positionY.toDouble());
          backgroundVector.multiply(tileSize);
          Image image = game.images.fromCache('Terrain/Terrain (16x16).png');
          Sprite sprite = Sprite(
            image,
            srcPosition: backgroundVector,
            srcSize: Vector2.all(16),
          );

          // Create components.
          SpriteComponent component =
              SpriteComponent(sprite: sprite, position: position);

          add(component);
        }
      }
    }
  }
}
