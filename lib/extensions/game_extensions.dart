import 'package:flame/components.dart';
import 'package:flame/game.dart';

extension GameExtensions on Game {
  SpriteAnimation buildAnimation(
      {required String asset, // Objects/Bushes/spriteSheet.png
      required int amount,
      int startFrame = 0,
      required double stepTime,
      required Vector2 textureSize,
      required int row,
      required int startColumn,
      bool loop = false}) {
    SpriteAnimation animation = SpriteAnimation.fromFrameData(
        images.fromCache(asset),
        SpriteAnimationData.sequenced(
            amount: amount,
            stepTime: stepTime,
            textureSize: textureSize,
            texturePosition:
                Vector2(startColumn * textureSize.x, row * textureSize.y),
            loop: loop));
    return animation;
  }
}
