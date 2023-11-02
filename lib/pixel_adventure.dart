import 'dart:async';

import 'package:app/actors/player.dart';
import 'package:app/levels/level.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xff211f30);
  Vector2 mapSize = Vector2(640, 640);

  late final CameraComponent cam;
  late final Player player;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    player = Player();
    final world = Level(levelName: 'map.tmx', player: player);

    cam = CameraComponent.withFixedResolution(
        world: world, width: mapSize.x, height: mapSize.y);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    return super.onLoad();
  }
}
