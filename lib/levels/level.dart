import 'dart:async';

import 'package:app/actors/player.dart';
import 'package:app/levels/static_barrier.dart';
import 'package:app/pixel_adventure.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

class Level extends World
    with HasGameRef<PixelAdventure>, HasCollisionDetection {
  late TiledComponent level;
  final String levelName;
  final Player player;
  final int tileSetWidth = 88;

  ShapeHitbox? hitbox;
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

    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointLayer?.objects ?? []) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
      }
    }

    player.collisionDetection = collisionDetection;

    return super.onLoad();
  }

  Paint rayPaint = Paint()..color = Colors.red.withOpacity(0.6);

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    // print(player.directionVector);
    // final ray = Ray2(
    //   origin: player.position,
    //   direction: player.directionVector,
    // );
    // final result = collisionDetection.raycast(ray);
    // print(result?.distance);
    // hitbox = result?.hitbox;
    // hitbox?.paint = rayPaint;
    // print(result?.distance);
    // player.position = result?.intersectionPoint ?? Vector2(0, 0);
  }
}
