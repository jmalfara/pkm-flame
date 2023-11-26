import 'package:flame/components.dart';

sealed class PlayerDirection {
  final Vector2 directionVector;
  PlayerDirection({required this.directionVector});

  static PlayerDirection left = PlayerDirectionLeft();
  static PlayerDirection right = PlayerDirectionRight();
  static PlayerDirection up = PlayerDirectionUp();
  static PlayerDirection down = PlayerDirectionDown();
  static PlayerDirection idle = PlayerDirectionIdle();
}

class PlayerDirectionLeft extends PlayerDirection {
  PlayerDirectionLeft() : super(directionVector: Vector2(-1, 0));
}

class PlayerDirectionRight extends PlayerDirection {
  PlayerDirectionRight() : super(directionVector: Vector2(1, 0));
}

class PlayerDirectionUp extends PlayerDirection {
  PlayerDirectionUp() : super(directionVector: Vector2(0, -1));
}

class PlayerDirectionDown extends PlayerDirection {
  PlayerDirectionDown() : super(directionVector: Vector2(0, 1));
}

class PlayerDirectionIdle extends PlayerDirection {
  PlayerDirectionIdle() : super(directionVector: Vector2(0, 0));
}
