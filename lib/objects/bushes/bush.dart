import 'dart:async';

import 'package:app/objects/_base/tile.dart';
import 'package:app/pixel_adventure.dart';
import 'package:flame/components.dart';

enum BushState { idle, shake }

class Bush extends Tile with HasGameRef<PixelAdventure> {
  final double stepTime = 0.1;
  String asset;

  Bush({position, required size, this.asset = 'Bush_Green (16x16)'})
      : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    size = Vector2(16, 16);
    return super.onLoad();
  }

  void _loadAllAnimations() {
    animations = {
      BushState.idle: _buildAnimation(amount: 1, textureSize: Vector2(16, 16)),
      BushState.shake: _buildAnimation(amount: 3, textureSize: Vector2(16, 16))
    };
    current = BushState.idle;
  }

  SpriteAnimation _buildAnimation(
      {required int amount, required Vector2 textureSize}) {
    SpriteAnimation animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Objects/Bushes/$asset.png'),
        SpriteAnimationData.sequenced(
            amount: amount,
            stepTime: stepTime,
            textureSize: textureSize,
            loop: false));
    return animation;
  }

  @override
  onTileEnter(PositionComponent other) {
    current = BushState.shake;
    animationTicker?.reset();
    animationTicker?.completed.whenComplete(() {
      current = BushState.idle;
    });
  }

  @override
  onTileExit(PositionComponent other) {
    // print("Tile Exit: $other");
  }
}
