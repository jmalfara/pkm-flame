import 'package:app/pixel_adventure.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final game = PixelAdventure();
  runApp(
    GameWidget(
      game: kDebugMode ? PixelAdventure() : game,
    ),
  );
}
