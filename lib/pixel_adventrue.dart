import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() {
    return const Color(0xFF211f30);
  }

  late final CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;
  bool showJoyStick = false;

  @override
  FutureOr<void> onLoad() async {
    // load all images into cache;
    await images.loadAllImages();
    final World world = Level(levelName: 'level-01', player: player);

    cam = CameraComponent.withFixedResolution(
        world: world, width: 740, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    if (showJoyStick) addJoyStick();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoyStick) _updateJoyStick();
    super.update(dt);
  }

  void addJoyStick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(
        left: 32,
        bottom: 32,
      ),
    );
    add(joystick);
  }

  void _updateJoyStick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;

      default:
        player.horizontalMovement = 0;
    }
  }
}
