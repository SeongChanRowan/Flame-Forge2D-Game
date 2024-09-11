import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';

import 'background.dart';
import 'brick.dart';
import 'ground.dart';
import 'player.dart';

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
    unawaited(addBricks());
    await addPlayer();
    // 게임 자체가 아닌 world에 요소를 추가해야 합니다.
    // 게임 인스턴스에 직접 추가하면 cameraComponent에서 올바르게 변환되지 않고
    // Forge2D 시뮬레이션에 포함이 안됩니다.
    // Forge2D를 시뮬레이션 하려면 world의 직속 하위 요소여야 합니다.

    return super.onLoad();
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 5; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;

      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          position: Vector2(
              camera.visibleWorldRect.right / 3 +
                  (_random.nextDouble() * 5 - 2.5),
              0),
          sprites: brickFileNames(type, size).map(
            (key, filename) => MapEntry(
              key,
              elements.getSprite(filename),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
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

  Future<void> addPlayer() async => world.add(
        Player(
          Vector2(camera.visibleWorldRect.left * 2 / 3, 0),
          aliens.getSprite(PlayerColor.randomColor.fileName),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (isMounted && world.children.whereType<Player>().isEmpty) {
      addPlayer();
    }
  }
}
