import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';

import 'background.dart';
import 'ground.dart';

// Box2D 물리엔진 플러터 버전 == Forge2D
class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame()
      : super(
          gravity: Vector2(0, 10), // 초당 9.81미티의 중력값과 근접값
          camera: CameraComponent.withFixedResolution(width: 800, height: 600),
        );

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;

  // 디스크에서 이미지 에셋 로드하는 비동기 함수
  @override
  FutureOr<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    final spriteSheets = await Future.wait([
      XmlSpriteSheet.load(
          imagePath: 'spritesheet_aliens.png',
          xmlPath: 'spritesheet_aliens.xml'),
      XmlSpriteSheet.load(
          imagePath: 'spritesheet_elements.png',
          xmlPath: 'spritesheet_elements.xml'),
      XmlSpriteSheet.load(
          imagePath: 'spritesheet_tiles.png', xmlPath: 'spritesheet_tiles.xml'),
    ]);

    aliens = spriteSheets[0];
    elements = spriteSheets[1];
    tiles = spriteSheets[2];

    await world.add(Background(sprite: Sprite(backgroundImage)));
    await addGround();

    return super.onLoad();
  }

  Future<void> addGround() {
    return world.addAll([
      for (var x = camera.visibleWorldRect.left;
          x < camera.visibleWorldRect.right + groundSize;
          x += groundSize)
        Ground(
          Vector2(x, (camera.visibleWorldRect.height - groundSize) / 2),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }
}
