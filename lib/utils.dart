import 'package:pixel_adventure/components/collisions_block.dart';
import 'package:pixel_adventure/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;
  // we flip the player so
  final fixedX = player.scale.x < 0 ? playerX - playerWidth : player.x;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;
  return (fixedY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedX < blockX + blockWidth &&
      fixedX + playerWidth > blockX);
  // if (playerX + playerWidth >= blockX &&
  //     playerX <= blockX + blockWidth &&
  //     playerY + playerHeight >= blockY &&
  //     playerY <= blockY + blockHeight) {
  //   return true;
  // } else {
  //   return false;
  // }
}
