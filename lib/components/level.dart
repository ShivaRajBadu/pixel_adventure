import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/collisions_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventrue.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({
    required this.levelName,
    required this.player,
  });
  late TiledComponent level;
  List<CollisionBlock> collisionBlock = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2(16, 16));

    add(level);

    _scrollingBackground();
    _spawnPointerLayer();
    _collisionsLayer();

    return super.onLoad();
  }

  void _spawnPointerLayer() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnpoint in spawnPointsLayer.objects) {
        switch (spawnpoint.class_) {
          case 'Player':
            player.position = Vector2(spawnpoint.x, spawnpoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnpoint.name,
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnpoint.properties.getValue('isVertical');
            final offNeg = spawnpoint.properties.getValue('offNeg');
            final offPos = spawnpoint.properties.getValue('offPos');
            final saw = Saw(
              position: Vector2(spawnpoint.x, spawnpoint.y),
              size: Vector2(spawnpoint.width, spawnpoint.height),
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
            );
            add(saw);
            break;
          default:
        }
      }
    }
  }

  void _collisionsLayer() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platforms':
            final platform = CollisionBlock(
              isPlatform: true,
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlock.add(platform);
            add(platform);
            break;

          default:
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlock.add(platform);
            add(platform);
        }
      }
    }
    player.collisionBlock = collisionBlock;
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('background');
    const tileSize = 64;

    final numTileY = (game.size.y / tileSize).ceil();
    final numTileX = (game.size.x / tileSize).ceil() + 3;
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTileY; y++) {
        for (double x = 0; x < numTileX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );
          add(backgroundTile);
        }
      }
    }
  }
}
