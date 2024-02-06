import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventrue.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({position, this.color = 'Gray'}) : super(position: position);
  final double scrollSpeed = 0.4;
  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2.all(65);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64;
    int scrollHeight = (game.size.y / tileSize).ceil() + 4;
    if (position.y > scrollHeight * tileSize) {
      position.y = -tileSize;
    }
    super.update(dt);
  }
}
