import 'dart:async';

// import 'package:app/actors/player.dart';
import 'package:app/objects/player/player.dart';
import 'package:app/levels/level.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

// Vector2 mapTiles = Vector2(40, 40);
// Vector2 tileSize = Vector2(16, 16);
// Vector2 mapSize = Vector2(16 * mapTiles.x, 16 * mapTiles.y);

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  @override
  // Color backgroundColor() => const Color(0xff211f30);
  Vector2 mapSize = Vector2(360, 360);
  late final CameraComponent cam;
  late final Player player;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    player = Player(size: Vector2(16, 16));
    final world = Level(levelName: 'map.tmx', player: player);

    cam = CameraComponent.withFixedResolution(
        world: world, width: mapSize.x, height: mapSize.y);
    cam.viewfinder.anchor = Anchor.center;
    // cam.setBounds(Rect.fromLTRB(0, 0, 10, 10));
    cam.follow(player);

    FpsTextComponent fps = FpsTextComponent();
    addAll([cam, world, fps]);

    return super.onLoad();
  }
}
