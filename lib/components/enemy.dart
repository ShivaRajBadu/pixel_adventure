import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventrue.dart';

enum EnemyState {
  idle,
  run,
  hit,
}

class Enemy extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Enemy({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const double stepTime = 0.05;
  static Vector2 textureSize = Vector2(32, 34);
  static const int runSpeed = 80;
  static const double _bounceHeight = 260.0;
  double rangeNeg = 0;
  double rangePos = 0;
  bool gotStomped = false;

  double moveDirection = 1;
  double targetDirection = -1;
  Vector2 velocity = Vector2.zero();
  static const tileSize = 16;

  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _runAnimation;
  late SpriteAnimation _hitAnimation;

  late final Player player;
  @override
  FutureOr<void> onLoad() {
    player = game.player;
    add(
      RectangleHitbox(
        position: Vector2(4, 6),
        size: Vector2(24, 26),
        collisionType: CollisionType.passive,
      ),
    );
    _loadAllAnimation();
    _calculateRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      _movement(dt);
      _updateState();
    }
    super.update(dt);
  }

  void _loadAllAnimation() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 5)..loop = false;

    animations = {
      EnemyState.idle: _idleAnimation,
      EnemyState.run: _runAnimation,
      EnemyState.hit: _hitAnimation,
    };
    current = EnemyState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: textureSize,
        ));
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) {
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      // go to the player
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? EnemyState.run : EnemyState.idle;
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void colliededWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play('chickenKill.wav', volume: game.soundVolume);
      }
      gotStomped = true;
      current = EnemyState.hit;
      player.velocity.y = -_bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}
